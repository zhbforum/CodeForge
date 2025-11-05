import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/features/leaderboard/presentation/viewmodels/leaderboard_providers.dart';
import 'package:mobile_app/features/leaderboard/presentation/widgets/hero_stats_card.dart';
import 'package:mobile_app/features/leaderboard/presentation/widgets/leaderboard_list.dart';
import 'package:mobile_app/features/leaderboard/presentation/widgets/podium_top3.dart';

class LeaderboardPage extends ConsumerWidget {
  const LeaderboardPage({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    await Future.wait([
      ref.refresh(userStatsProvider.future),
      ref.refresh(topLeaderboardProvider.future),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userStats = ref.watch(userStatsProvider);
    final topList = ref.watch(topLeaderboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboards'),
        actions: [
          IconButton(
            onPressed: () => _refresh(ref),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            userStats.when(
              loading: () => const _LoadingCard(height: 160),
              error: (e, _) =>
                  _ErrorCard(message: 'Failed to load user stats: $e'),
              data: (data) => HeroStatsCard(stats: data),
            ),

            const SizedBox(height: 16),

            Text(
              'Top 20',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            topList.when(
              loading: () => const _LoadingList(items: 6),
              error: (e, _) =>
                  _ErrorCard(message: 'Failed to load leaderboard: $e'),
              data: (entries) {
                final top3 = entries.take(3).toList();
                final others = entries.skip(3).toList();
                return Column(
                  children: [
                    if (top3.isNotEmpty) PodiumTop3(top3: top3),
                    if (others.isNotEmpty) const SizedBox(height: 8),
                    if (others.isNotEmpty) LeaderboardList(entries: others),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard({required this.height});
  final double height;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        height: height,
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}

class _LoadingList extends StatelessWidget {
  const _LoadingList({required this.items});
  final int items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(items, (i) {
        return const Card(
          margin: EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            leading: CircleAvatar(),
            title: SizedBox(
              height: 14,
              child: ColoredBox(color: Color(0x11000000)),
            ),
            subtitle: SizedBox(
              height: 12,
              child: ColoredBox(color: Color(0x0F000000)),
            ),
          ),
        );
      }),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}
