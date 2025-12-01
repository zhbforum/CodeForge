import 'package:flutter/material.dart';

class HelpCenterSearchSection extends StatelessWidget {
  const HelpCenterSearchSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    final bg = colors.surfaceContainerHighest;
    final hint = colors.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Icon(Icons.search, color: hint),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                style: textTheme.bodyMedium?.copyWith(color: colors.onSurface),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  hintText: 'How can we help?',
                  hintStyle: textTheme.bodyMedium?.copyWith(color: hint),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}
