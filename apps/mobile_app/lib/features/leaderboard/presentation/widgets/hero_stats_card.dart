import 'package:flutter/material.dart';
import 'package:mobile_app/core/models/leaderboard.dart';

class HeroStatsCard extends StatelessWidget {
  const HeroStatsCard({required this.stats, super.key});
  final UserStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final xpInLevel = stats.totalExp % 1000;
    const nextLevelXp = 1000;
    final progress = (xpInLevel / nextLevelXp).clamp(0.0, 1.0);

    final onHigh = theme.colorScheme.onSurface.withValues(alpha: .87);
    final onMed = theme.colorScheme.onSurface.withValues(alpha: .68);

    final bgA = isDark
        ? theme.colorScheme.primary.withValues(alpha: .20)
        : theme.colorScheme.primaryContainer.withValues(alpha: .28);
    final bgB = isDark
        ? theme.colorScheme.secondary.withValues(alpha: .12)
        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: .50);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [bgA, bgB],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(
            alpha: isDark ? .15 : .45,
          ),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isDark
                  ? theme.colorScheme.surface.withValues(alpha: .30)
                  : theme.colorScheme.surface.withValues(alpha: .92),
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(
                  alpha: isDark ? .30 : .55,
                ),
                width: 1.2,
              ),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${stats.level}',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: onHigh,
                  ),
                ),
                Text(
                  'lvl',
                  style: theme.textTheme.titleMedium?.copyWith(color: onMed),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Level',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: onMed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 12,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: isDark ? .35 : .55),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '$xpInLevel / $nextLevelXp',
                    style: theme.textTheme.bodyMedium?.copyWith(color: onMed),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _StatChip(label: 'Global XP', value: stats.totalExp),
                    _StatChip(label: 'Season XP', value: stats.seasonExp),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: .60)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: .80),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: .40),
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 20, maxWidth: 320),
        child: Text(
          '$label: $value',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
