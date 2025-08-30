part of 'package:mobile_app/features/onboarding/onboarding_page.dart';

class _CompanionBlink extends StatefulWidget {
  const _CompanionBlink({required this.asset});

  final String asset;
  static const double _kSize = 120;

  @override
  State<_CompanionBlink> createState() => _CompanionBlinkState();
}

class _CompanionBlinkState extends State<_CompanionBlink>
    with TickerProviderStateMixin {
  static const double kFloatAmplitude = -4;
  static const double kTiltRadians = 0.02;
  static const Duration kCycle = Duration(seconds: 3);

  late final AnimationController _floatCtrl = AnimationController(
    vsync: this,
    duration: kCycle,
  )..repeat(reverse: true);

  late final Animation<double> _floatDy = Tween<double>(
    begin: 0,
    end: kFloatAmplitude,
  ).animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

  late final Animation<double> _tilt = Tween<double>(
    begin: -kTiltRadians,
    end: kTiltRadians,
  ).animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

  @override
  void dispose() {
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Companion',
      child: AnimatedBuilder(
        animation: _floatCtrl,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _floatDy.value),
            child: Transform.rotate(
              angle: _tilt.value,
              child: SizedBox(
                width: _CompanionBlink._kSize,
                height: _CompanionBlink._kSize,
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
