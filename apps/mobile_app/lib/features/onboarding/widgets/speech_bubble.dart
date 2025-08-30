part of 'package:mobile_app/features/onboarding/onboarding_page.dart';

class _SpeechBubble extends StatelessWidget {
  const _SpeechBubble({
    required this.text,
    required this.fill,
    required this.border,
    this.anchor = .35,
  });

  final String text;
  final Color fill;
  final Color border;
  final double anchor;

  static const double _kRadius = 50;
  static const EdgeInsets _kPadding = EdgeInsets.all(18);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final clamped = anchor.clamp(0.0, 1.0);
    final align = Alignment(-1, clamped * 2 - 1);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Align(
          alignment: align,
          child: Transform.translate(
            offset: const Offset(-10, 0),
            child: _CurvedTail(fill: fill, stroke: border),
          ),
        ),
        Container(
          padding: _kPadding,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(_kRadius),
            border: Border.all(color: border),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                offset: const Offset(0, 2),
                color: Colors.black.withValues(alpha: 0.06),
              ),
            ],
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.2),
          ),
        ),
      ],
    );
  }
}
