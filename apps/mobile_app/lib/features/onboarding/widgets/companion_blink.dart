part of 'package:mobile_app/features/onboarding/onboarding_page.dart';

class _CompanionBlink extends ConsumerStatefulWidget {
  const _CompanionBlink({
    required this.asset,
    this.size = 120,
    this.semanticsLabel = 'Companion',
  });

  final String asset;
  final double size;
  final String semanticsLabel;

  @override
  ConsumerState<_CompanionBlink> createState() => _CompanionBlinkState();
}

class _CompanionBlinkState extends ConsumerState<_CompanionBlink>
    with SingleTickerProviderStateMixin {
  static const double _tiltRadians = 0.02;
  static const Duration _cycle = Duration(seconds: 3);

  late final AnimationController _floatCtrl;
  late final Animation<double> _floatDy;
  late final Animation<double> _tilt;

  bool? _lastReduce;

  @override
  void initState() {
    super.initState();

    _floatCtrl = AnimationController(vsync: this, duration: _cycle);

    _floatDy = Tween<double>(
      begin: 0,
      end: -0.035,
    ).animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

    _tilt = Tween<double>(
      begin: -_tiltRadians,
      end: _tiltRadians,
    ).animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
  }

  void _applyReduce(bool reduce) {
    if (reduce) {
      if (_floatCtrl.isAnimating) _floatCtrl.stop();
      _floatCtrl.value = 0.0;
    } else {
      if (!_floatCtrl.isAnimating) _floatCtrl.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = ref.watch(reduceMotionProvider);

    if (reduce != _lastReduce) {
      _lastReduce = reduce;
      _applyReduce(reduce);
    }

    return Semantics(
      label: widget.semanticsLabel,
      child: AnimatedBuilder(
        animation: _floatCtrl,
        builder: (context, child) {
          final dy = _floatDy.value * widget.size;

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
