part of 'package:mobile_app/features/onboarding/onboarding_page.dart';

class _CurvedTail extends StatelessWidget {
  const _CurvedTail({required this.fill, required this.stroke});

  final Color fill;
  final Color stroke;

  static const Size _kSize = Size(32, 20);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: _kSize,
      painter: _CurvedTailPainter(fill: fill, stroke: stroke),
    );
  }
}

class _CurvedTailPainter extends CustomPainter {
  _CurvedTailPainter({required this.fill, required this.stroke});

  final Color fill;
  final Color stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(w, h * 0.50)
      ..quadraticBezierTo(w * 0.55, h * 0.15, 0, h * 0.25)
      ..quadraticBezierTo(w * 0.52, h * 0.75, w, h)
      ..close();

    final fillPaint = Paint()
      ..color = fill
      ..isAntiAlias = true;

    final strokePaint = Paint()
      ..color = stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    canvas
      ..drawPath(path, fillPaint)
      ..drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _CurvedTailPainter old) =>
      old.fill != fill || old.stroke != stroke;
}
