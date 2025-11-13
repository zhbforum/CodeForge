import 'package:mobile_app/core/models/leaderboard.dart';
import 'package:mobile_app/core/services/api_service.dart';
import 'package:mobile_app/features/leaderboard/domain/leaderboard_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseLeaderboardRepository implements LeaderboardRepository {
  SupabaseLeaderboardRepository(this._api, this._sb);

  final ApiService _api;
  final SupabaseClient _sb;

  int _levelFromExp(int xp) => (xp ~/ 1000) + 1;

  @override
  Future<UserStats> fetchUserStats() async {
    final session = _sb.auth.currentSession;
    if (session == null) {
      throw StateError('User not logged in');
    }
    final uid = session.user.id;

    final ugpRows = await _api.query(
      table: 'user_global_progress',
      select: 'total_exp',
      filters: {
        'user_id': uid,
      },
      limit: 1,
    );

    final ugp = ugpRows.isEmpty ? null : ugpRows.first;
    final totalExp = (ugp?['total_exp'] as num?)?.toInt() ?? 0;

    final uspRows = await _api.query(
      table: 'user_season_progress',
      select: 'season_exp',
      filters: {
        'user_id': uid,
      },
      orderBy: 'season_exp',
      ascending: false,
      limit: 1,
    );

    final usp = uspRows.isEmpty ? null : uspRows.first;
    final seasonExp = (usp?['season_exp'] as num?)?.toInt() ?? 0;

    return UserStats(
      totalExp: totalExp,
      seasonExp: seasonExp,
      level: _levelFromExp(totalExp),
    );
  }

  @override
  Future<List<LeaderboardEntry>> fetchTop({int limit = 20}) async {
    final raw = await _api.query(
      table: 'leaderboard_v',
      select: '''
        display_name,
        avatar_url,
        level,
        league_name,
        season_exp,
        total_exp,
        rank
      ''',
      orderBy: 'rank',
      limit: limit,
    );

    return raw.map((e) {
      int toInt(Object? v, [int fallback = 0]) =>
          (v as num?)?.toInt() ?? fallback;
      String toStr(Object? v, [String fallback = '']) =>
          (v as String?) ?? fallback;

      return LeaderboardEntry(
        rank: toInt(e['rank']),
        displayName: toStr(e['display_name']),
        avatarUrl: e['avatar_url'] as String?,
        level: toInt(e['level'], 1),
        leagueName: toStr(e['league_name']),
        seasonExp: toInt(e['season_exp']),
        totalExp: toInt(e['total_exp']),
      );
    }).toList();
  }
}
