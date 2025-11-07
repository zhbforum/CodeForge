import 'package:flutter/material.dart';
import 'package:mobile_app/features/leaderboard/domain/models.dart';
import 'package:mobile_app/features/leaderboard/presentation/widgets/leaderboard_tile.dart';

class LeaderboardList extends StatelessWidget {
  const LeaderboardList({required this.entries, super.key});
  final List<LeaderboardEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text('No data')),
      );
    }

    final top3 = entries.take(3).toList();
    final others = entries.skip(3).toList();

    return Column(
      children: [
        if (top3.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: top3.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) => LeaderboardTile(entry: top3[i]),
            ),
          ),
        if (others.isNotEmpty) const SizedBox(height: 8),
        if (others.isNotEmpty)
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: others.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) => LeaderboardTile(entry: others[i]),
          ),
      ],
    );
  }
}
