import 'package:flutter/material.dart';
import 'package:mobile_app/features/leaderboard/domain/models.dart';

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

    final bgA = isDark
        ? theme.colorScheme.primary.withValues(alpha: .20)
        : theme.colorScheme.primaryContainer.withValues(alpha: .35);
    final bgB = isDark
        ? theme.colorScheme.secondary.withValues(alpha: .12)
        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: .60);

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
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: isDark
                  ? theme.colorScheme.surface.withValues(alpha: .28)
                  : theme.colorScheme.surface.withValues(alpha: .85),
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(
                  alpha: isDark ? .3 : .6,
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
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text('lvl', style: theme.textTheme.labelMedium),
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
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: .6),
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: isDark ? .35 : .55),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _StatChip(label: 'Global XP', value: stats.totalExp),
                    const SizedBox(width: 8),
                    _StatChip(label: 'Season XP', value: stats.seasonExp),
                    const Spacer(),
                    Text(
                      '$xpInLevel / $nextLevelXp',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: .55,
                        ),
                      ),
                    ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: .6)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: .8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: .4),
        ),
      ),
      child: Text(
        '$label: $value',
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
