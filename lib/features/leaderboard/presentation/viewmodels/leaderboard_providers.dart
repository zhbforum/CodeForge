import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/models/leaderboard.dart';
import 'package:mobile_app/features/leaderboard/data/leaderboard_repository_provider.dart';

final userStatsProvider = FutureProvider<UserStats>((ref) async {
  final repo = ref.watch(leaderboardRepositoryProvider);
  return repo.fetchUserStats();
});

final topLeaderboardProvider =
    FutureProvider.autoDispose<List<LeaderboardEntry>>((ref) async {
      final repo = ref.watch(leaderboardRepositoryProvider);
      return repo.fetchTop();
    });
