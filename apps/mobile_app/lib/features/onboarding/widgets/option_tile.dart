part of 'package:mobile_app/features/onboarding/onboarding_page.dart';

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.leading,
    required this.title,
    required this.onTap,
    this.subtle = false,
  });

  final Widget leading; 
  final String title;
  final VoidCallback onTap;
  final bool subtle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: subtle ? cs.surfaceContainerHigh : cs.surfaceContainerHighest,
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: cs.primary.withValues(alpha: 0.12),
              child: IconTheme(
                data: IconThemeData(color: cs.primary, size: 22),
                child: leading,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title)),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
