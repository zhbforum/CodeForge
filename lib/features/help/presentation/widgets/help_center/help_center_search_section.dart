import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HelpCenterContactSection extends StatelessWidget {
  const HelpCenterContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 480;

          final contentText = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Can't find an answer?",
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Reach out to our team for personalized support.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          );

          final button = SizedBox(
            width: isWide ? null : double.infinity,
            height: 40,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              onPressed: () {
                context.pushNamed('contactUs');
              },
              child: const Text('Contact Us', overflow: TextOverflow.ellipsis),
            ),
          );

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.outlineVariant),
              boxShadow: [
                BoxShadow(
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                  color: colors.shadow.withValues(alpha: 0.15),
                ),
              ],
            ),
            child: isWide
                ? Row(
                    children: [
                      Expanded(child: contentText),
                      const SizedBox(width: 16),
                      button,
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [contentText, const SizedBox(height: 12), button],
                  ),
          );
        },
      ),
    );
  }
}
