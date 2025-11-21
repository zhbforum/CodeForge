import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/services/api_service_provider.dart';
import 'package:mobile_app/features/leaderboard/data/supabase_leaderboard_repository.dart';
import 'package:mobile_app/features/leaderboard/domain/leaderboard_repository.dart';

final leaderboardRepositoryProvider = Provider<LeaderboardRepository>((ref) {
  final api = ref.read(apiServiceProvider);
  final client = ref.read(supabaseClientProvider);

  return SupabaseLeaderboardRepository(api, client);
});
