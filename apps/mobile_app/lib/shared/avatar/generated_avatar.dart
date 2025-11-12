import 'package:flutter/material.dart';

class GeneratedAvatar extends StatelessWidget {
  const GeneratedAvatar({
    required this.size,
    required this.seed,
    super.key,
    this.url,
    this.shape = BoxShape.circle,
    this.border,
    @visibleForTesting this.debugForceMinFill = false,
  });

  final double size;
  final String seed;
  final String? url;
  final BoxShape shape;
  final BoxBorder? border;
  @visibleForTesting
  final bool debugForceMinFill;

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(shape: shape, border: border);

    if (url != null && url!.isNotEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: decoration,
        clipBehavior: Clip.antiAlias,
        child: Image.network(
          url!,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: decoration,
      clipBehavior: Clip.antiAlias,
      child: CustomPaint(
        painter: _IdenticonPainter(
          seed: seed,
          debugForceMinFill: debugForceMinFill,
        ),
        child: _InitialsFallback(seed: seed),
      ),
    );
  }
}

class _SeedRng {
  _SeedRng(String seed) : _state = seed.hashCode;
  int _state;

  int nextInt([int max = 1 << 31]) {
    var x = _state;
    x ^= x << 13;
    x ^= x >> 17;
    x ^= x << 5;
    _state = x;
    final res = x & 0x7fffffff;
    return max <= 0 ? res : res % max;
  }

  double nextDouble() => nextInt() / 0x7fffffff;
}

class _IdenticonPainter extends CustomPainter {
  _IdenticonPainter({required this.seed, this.debugForceMinFill = false});

  final String seed;
  final bool debugForceMinFill;

  @override
  void paint(Canvas canvas, Size size) {
    final rng = _SeedRng(seed);

    final hue = rng.nextDouble() * 360.0;
    final color = HSLColor.fromAHSL(1, hue, 0.55, 0.55).toColor();

    final bg = HSLColor.fromAHSL(1, hue, 0.15, 0.92).toColor();
    final paintBg = Paint()..color = bg;
    final paintFg = Paint()..color = color;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(999),
    );
    canvas.drawRRect(rrect, paintBg);

    const n = 5;
    final pad = size.width * 0.08;
    final scale = (size.width - pad * 2) / n;
    final origin = Offset(pad, pad);

    final filled = List<List<bool>>.generate(
      n,
      (_) => List<bool>.filled(n, false),
    );

    for (var row = 0; row < n; row++) {
      for (var col = 0; col < (n / 2).ceil(); col++) {
        final isOn = rng.nextDouble() > 0.5;
        filled[row][col] = isOn;
        filled[row][n - 1 - col] = isOn;
      }
    }

    var onCount = filled.fold<int>(
      0,
      (acc, r) => acc + r.where((e) => e).length,
    );

    if (debugForceMinFill) {
      onCount = 0;
    }

    for (; onCount < 3; onCount++) {
      final rr = rng.nextInt(n);
      final cc = rng.nextInt(n);
      filled[rr][cc] = true;
    }

    for (var r = 0; r < n; r++) {
      for (var c = 0; c < n; c++) {
        if (!filled[r][c]) continue;
        final rect = Rect.fromLTWH(
          origin.dx + c * scale + scale * 0.12,
          origin.dy + r * scale + scale * 0.12,
          scale * 0.76,
          scale * 0.76,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(scale * 0.18)),
          paintFg,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _IdenticonPainter oldDelegate) =>
      oldDelegate.seed != seed ||
      oldDelegate.debugForceMinFill != debugForceMinFill;
}

class _InitialsFallback extends StatelessWidget {
  const _InitialsFallback({required this.seed});

  final String seed;

  @override
  Widget build(BuildContext context) {
    final parts = seed.trim().split(RegExp(r'\s+'));
    final initials = parts.length == 1
        ? parts.first.characters.take(2).toString().toUpperCase()
        : ((parts[0].isNotEmpty ? parts[0][0] : '') +
                  (parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : ''))
              .toUpperCase();

    return Center(
      child: Text(
        initials,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 20,
          letterSpacing: 1,
          color: Colors.black54,
        ),
      ),
    );
  }
}
