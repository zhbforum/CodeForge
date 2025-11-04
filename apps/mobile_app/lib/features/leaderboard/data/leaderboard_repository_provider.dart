import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/features/leaderboard/data/supabase_leaderboard_repository.dart';
import 'package:mobile_app/features/leaderboard/domain/models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final leaderboardRepositoryProvider = Provider<LeaderboardRepository>((ref) {
  final sb = Supabase.instance.client;
  return SupabaseLeaderboardRepository(sb);
});
