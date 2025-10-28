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

  @override
  void initState() {
    super.initState();
    _sb = Supabase.instance.client;
    _future = _load();
  }

  Future<_UserXP> _load() async {
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

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboards'),
        actions: [
          IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<_UserXP>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(child: Text('Error: ${snap.error}'));
            }
            final data = snap.data!;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Your Level', style: TextStyle(fontSize: 14,
                           color: Colors.grey)),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${data.level}', 
                              style: const TextStyle(fontSize: 48, 
                                fontWeight: FontWeight.bold)),
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
                ),
              ],
            );
          },
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
        Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
        Text('$value', style: const TextStyle(fontSize: 18, 
          fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _UserXP {
  const _UserXP({required this.totalExp, required this.seasonExp, 
    required this.level});
  const _UserXP.empty() : totalExp = 0, seasonExp = 0, level = 1;
  final int totalExp;
  final int seasonExp;
  final int level;
}
