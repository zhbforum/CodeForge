import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  late final SupabaseClient _sb;
  Future<_UserXP> _future = Future.value(const _UserXP.empty());
  Future<List<_LbRow>> _lbFuture = Future.value(const <_LbRow>[]);

  @override
  void initState() {
    super.initState();
    _sb = Supabase.instance.client;
    _future = _loadUserStats();
    _lbFuture = _loadTop20();
  }

  Future<_UserXP> _loadUserStats() async {
    final session = _sb.auth.currentSession;
    if (session == null) throw Exception('User not logged in');
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

    int levelFromExp(int xp) => (xp ~/ 1000) + 1;

    return _UserXP(
      totalExp: totalExp,
      seasonExp: seasonExp,
      level: levelFromExp(totalExp),
    );
  }

  Future<List<_LbRow>> _loadTop20() async {
    final raw = await _sb
        .from('leaderboard_v')
        .select(
          'display_name, avatar_url, level, '
          'league_name, season_exp, total_exp, rank',
        )
        .order('rank', ascending: true)
        .limit(20);

    final rows = (raw as List).cast<Map<String, dynamic>>();

    return rows
        .map(
          (e) => _LbRow(
            displayName: (e['display_name'] ?? '') as String,
            avatarUrl: e['avatar_url'] as String?,
            level: (e['level'] as num?)?.toInt() ?? 1,
            leagueName: (e['league_name'] ?? '') as String,
            seasonExp: (e['season_exp'] as num?)?.toInt() ?? 0,
            totalExp: (e['total_exp'] as num?)?.toInt() ?? 0,
            rank: (e['rank'] as num?)?.toInt() ?? 0,
          ),
        )
        .toList();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _loadUserStats();
      _lbFuture = _loadTop20();
    });
    await Future.wait([_future, _lbFuture]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboards'),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            FutureBuilder<_UserXP>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (snap.hasError) {
                  return Center(child: Text('Error: ${snap.error}'));
                }
                final data = snap.data!;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Level',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${data.level}',
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('lvl', style: TextStyle(fontSize: 18)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        _StatLine(label: 'Global XP', value: data.totalExp),
                        const SizedBox(height: 8),
                        _StatLine(label: 'Seasonal XP', value: data.seasonExp),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Top 20',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<_LbRow>>(
              future: _lbFuture,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (snap.hasError) {
                  return Center(child: Text('Error: ${snap.error}'));
                }
                final list = snap.data!;
                if (list.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text('No data'),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final r = list[i];
                    return ListTile(
                      isThreeLine: true,
                      leading: CircleAvatar(
                        foregroundImage: (r.avatarUrl != null 
                          && r.avatarUrl!.isNotEmpty)
                            ? NetworkImage(r.avatarUrl!)
                            : null,
                        onForegroundImageError: (_, __) {},
                        child: Text(
                          r.displayName.isNotEmpty 
                            ? r.displayName[0].toUpperCase() : '?',
                        ),
                      ),
                      title: Text(
                        '${r.rank}. ${r.displayName}',
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${r.leagueName} • lvl ${r.level}',
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Season ${r.seasonExp}', style: 
                              const TextStyle(fontWeight: FontWeight.w600)),
                            Text('Total ${r.totalExp}', 
                              style: const TextStyle(fontSize: 12, 
                                color: Colors.grey)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatLine extends StatelessWidget {
  const _StatLine({required this.label, required this.value});
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(fontSize: 16)),
        ),
        Text(
          '$value',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _UserXP {
  const _UserXP({
    required this.totalExp,
    required this.seasonExp,
    required this.level,
  });
  const _UserXP.empty()
      : totalExp = 0,
        seasonExp = 0,
        level = 1;
  final int totalExp;
  final int seasonExp;
  final int level;
}

class _LbRow {
  const _LbRow({
    required this.displayName,
    required this.avatarUrl,
    required this.level,
    required this.leagueName,
    required this.seasonExp,
    required this.totalExp,
    required this.rank,
  });
  final String displayName;
  final String? avatarUrl;
  final int level;
  final String leagueName;
  final int seasonExp;
  final int totalExp;
  final int rank;
}
