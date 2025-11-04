import 'package:flutter/material.dart';
import 'package:mobile_app/features/leaderboard/domain/models.dart';
import 'package:mobile_app/features/leaderboard/presentation/widgets/xp_chip.dart';

class UserStatsCard extends StatelessWidget {
  const UserStatsCard({required this.stats, super.key});

  final UserStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Level',
              style: theme.textTheme.labelLarge?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${stats.level}',
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text('lvl', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                XpChip(label: 'Global XP', value: stats.totalExp),
                const SizedBox(width: 8),
                XpChip(label: 'Season XP', value: stats.seasonExp),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
