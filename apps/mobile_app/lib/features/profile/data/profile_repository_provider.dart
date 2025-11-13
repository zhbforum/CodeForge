import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/services/api_service_provider.dart';
import 'package:mobile_app/features/profile/data/profile_repository.dart';
import 'package:mobile_app/features/profile/data/supabase_profile_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final api = ref.watch(apiServiceProvider);
  final client = Supabase.instance.client;
  return SupabaseProfileRepository(api, client);
});
