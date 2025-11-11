import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/features/leaderboard/data/supabase_leaderboard_repository.dart';
import 'package:mobile_app/features/leaderboard/domain/models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClientProvider = Provider<SupabaseClient>(
  (_) => Supabase.instance.client,
);

final leaderboardRepositoryProvider = Provider<LeaderboardRepository>((ref) {
  final sb = ref.read(supabaseClientProvider);
  return SupabaseLeaderboardRepository(sb);
});
