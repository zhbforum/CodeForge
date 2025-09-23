import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/features/auth/presentation/viewmodels/auth_view_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final currentSessionProvider = Provider<Session?>((ref) {
  final st = ref.watch(authStateStreamProvider).valueOrNull;
  return st?.session;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(currentSessionProvider) != null;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(currentSessionProvider)?.user;
});

final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(currentUserProvider)?.id;
});

final authSessionProvider = Provider<AsyncValue<Session?>>((ref) {
  final authState = ref.watch(authStateStreamProvider);
  return authState.whenData((s) => s.session);
});
