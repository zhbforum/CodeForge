import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/app/supabase_init.dart';
import 'package:mobile_app/core/error/error_handler.dart';
import 'package:mobile_app/core/services/auth_service.dart';
import 'package:mobile_app/features/auth/data/auth_repository.dart';
import 'package:mobile_app/features/auth/presentation/viewmodels/auth_view_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authClientProvider = Provider<AuthClient>((ref) {
  return SupabaseAuthClient(AppSupabase.client.auth);
});

final authServiceProvider = Provider<AuthService>((ref) {
  final authClient = ref.read(authClientProvider);
  final errorHandler = ref.read(errorHandlerProvider);

  return AuthService(auth: authClient, errorHandler: errorHandler);
});

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.read(authServiceProvider)),
);

final authStateStreamProviderAlias = StreamProvider<AuthState>(
  (ref) => ref.read(authServiceProvider).onAuthStateChange,
);

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AsyncValue<void>>(
      (ref) => AuthViewModel(ref.read(authRepositoryProvider)),
    );

final authStateStreamProvider = StreamProvider<AuthState>(
  (ref) => ref.read(authServiceProvider).onAuthStateChange,
);

final authSessionProvider = Provider<AsyncValue<Session?>>((ref) {
  final authState = ref.watch(authStateStreamProvider);
  return authState.whenData((s) => s.session);
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateStreamProvider);
  final session = authState.valueOrNull?.session;
  return session != null;
});

final currentSessionProvider = Provider<Session?>((ref) {
  final authState = ref.watch(authStateStreamProvider);
  return authState.valueOrNull?.session;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(currentSessionProvider)?.user;
});

final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(currentUserProvider)?.id;
});
