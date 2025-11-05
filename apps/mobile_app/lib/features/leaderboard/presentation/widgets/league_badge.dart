import 'package:flutter/material.dart';

class LeagueBadge extends StatelessWidget {
  const LeagueBadge(this.leagueName, {super.key});
  final String leagueName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = _palette(leagueName, theme);

    final bg = isDark
        ? color.withValues(alpha: .20)
        : color.withValues(alpha: .25);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: isDark ? .45 : .35)),
      ),
      child: Text(
        leagueName,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: isDark ? color : color.withValues(alpha: .95),
          fontWeight: FontWeight.w700,
          letterSpacing: .2,
        ),
      ),
    );
  }

  Color _palette(String name, ThemeData theme) {
    final n = name.toLowerCase();
    if (n.contains('bronze')) return const Color(0xFF996038);
    if (n.contains('silver')) return const Color(0xFF7A7A7A);
    if (n.contains('gold')) return const Color(0xFFB58900);
    if (n.contains('platinum')) return const Color(0xFF3DA1C9);
    if (n.contains('diamond')) return const Color(0xFF2AAED3);
    return theme.colorScheme.primary;
  }
}
