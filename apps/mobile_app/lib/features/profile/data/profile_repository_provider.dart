import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/features/profile/data/profile_repository.dart';
import 'package:mobile_app/features/profile/data/supabase_profile_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  name: 'profileRepositoryProvider',
  (ref) => SupabaseProfileRepository(Supabase.instance.client),
);
