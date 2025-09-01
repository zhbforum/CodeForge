part of 'package:mobile_app/features/onboarding/onboarding_page.dart';

class _CompanionBlink extends StatefulWidget {
  const _CompanionBlink({
    required this.asset,
    this.size = 120,
    this.semanticsLabel = 'Companion',
  });

  final String asset;
  final double size;
  final String semanticsLabel;

  @override
  State<_CompanionBlink> createState() => _CompanionBlinkState();
}

class _CompanionBlinkState extends State<_CompanionBlink>
    with TickerProviderStateMixin {
  static const double _tiltRadians = 0.02;
  static const Duration _cycle = Duration(seconds: 3);

  late final AnimationController _floatCtrl = AnimationController(
    vsync: this,
    duration: _cycle,
  )..repeat(reverse: true);

  late final Animation<double> _floatDy = Tween<double>(
    begin: 0,
    end: -0.035,
  ).animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

  late final Animation<double> _tilt = Tween<double>(
    begin: -_tiltRadians,
    end: _tiltRadians,
  ).animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

  @override
  void dispose() {
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dy = _floatDy.value * widget.size;

    return Semantics(
      label: widget.semanticsLabel,
      child: AnimatedBuilder(
        animation: _floatCtrl,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, dy),
            child: Transform.rotate(
              angle: _tilt.value,
              child: SizedBox(
                width: widget.size,
                height: widget.size,
                child: SvgPicture.asset(
                  widget.asset,
                  placeholderBuilder: (_) => const SizedBox.shrink(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
