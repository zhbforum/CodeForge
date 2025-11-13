import 'package:mobile_app/core/models/leaderboard.dart';

abstract class LeaderboardRepository {
  Future<UserStats> fetchUserStats();
  Future<List<LeaderboardEntry>> fetchTop({int limit = 20});
}
