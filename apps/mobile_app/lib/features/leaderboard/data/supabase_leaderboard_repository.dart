import 'package:mobile_app/features/leaderboard/domain/models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseLeaderboardRepository implements LeaderboardRepository {
  SupabaseLeaderboardRepository(this._sb);

  final SupabaseClient _sb;

  int _levelFromExp(int xp) => (xp ~/ 1000) + 1;

  @override
  Future<UserStats> fetchUserStats() async {
    final session = _sb.auth.currentSession;
    if (session == null) {
      throw StateError('User not logged in');
    }
    final uid = session.user.id;

    final ugp = await _sb
        .from('user_global_progress')
        .select('total_exp')
        .eq('user_id', uid)
        .maybeSingle();

    final totalExp = (ugp?['total_exp'] as num?)?.toInt() ?? 0;

    final usp = await _sb
        .from('user_season_progress')
        .select('season_exp')
        .eq('user_id', uid)
        .order('season_exp', ascending: false)
        .limit(1)
        .maybeSingle();

    final seasonExp = (usp?['season_exp'] as num?)?.toInt() ?? 0;

    return UserStats(
      totalExp: totalExp,
      seasonExp: seasonExp,
      level: _levelFromExp(totalExp),
    );
  }

  @override
  Future<List<LeaderboardEntry>> fetchTop({int limit = 20}) async {
    final raw = await _sb
        .from('leaderboard_v')
        .select(
          'display_name, avatar_url, level, league_name, season_exp, total_exp, rank',
        )
        .order('rank', ascending: true)
        .limit(limit);

    final rows = (raw as List).cast<Map<String, dynamic>>();

    return rows.map((e) {
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
