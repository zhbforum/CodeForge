import 'package:meta/meta.dart';

@immutable
class UserStats {
  const UserStats({
    required this.totalExp,
    required this.seasonExp,
    required this.level,
  });
  factory UserStats.empty() =>
      const UserStats(totalExp: 0, seasonExp: 0, level: 1);

  final int totalExp;
  final int seasonExp;
  final int level;
}

@immutable
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.displayName,
    required this.avatarUrl,
    required this.level,
    required this.leagueName,
    required this.seasonExp,
    required this.totalExp,
  });

  final int rank;
  final String displayName;
  final String? avatarUrl;
  final int level;
  final String leagueName;
  final int seasonExp;
  final int totalExp;
}

abstract class LeaderboardRepository {
  Future<UserStats> fetchUserStats();
  Future<List<LeaderboardEntry>> fetchTop({int limit = 20});
}
