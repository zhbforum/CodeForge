part of 'package:mobile_app/features/onboarding/onboarding_page.dart';

class _ReasonStep extends StatelessWidget {
  const _ReasonStep({required this.onPick});
  final void Function(String code) onPick;

  @override
  Widget build(BuildContext context) {
    Widget tile(IconData icon, String title, String code) {
      return _OptionTile(
        leading: Icon(icon),
        title: title,
        onTap: () => onPick(code),
      );
    }

    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return _OnbFrame(
      message: 'Why do you want to learn coding?',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          tile(Icons.code, 'To become a professional developer', 'pro'),
          const SizedBox(height: 10),
          tile(Icons.trending_up, 'To advance my current career', 'advance'),
          const SizedBox(height: 10),
          tile(Icons.celebration, 'Just for fun', 'fun'),
          const SizedBox(height: 10),
          _OptionTile(
            leading: const Icon(Icons.more_horiz),
            title: 'None of these',
            subtle: true,
            onTap: () => onPick('none'),
          ),
          const SizedBox(height: 14),
          Text(
            'I’ll tailor the journey based on your choice.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
