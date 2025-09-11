import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/features/auth/data/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authRepositoryProvider =
    Provider<AuthRepository>((ref) => AuthRepository.supabase());

final authStateStreamProvider = StreamProvider<AuthState>(
  (ref) => ref.read(authRepositoryProvider).onAuthStateChange(),
);

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AsyncValue<void>>((ref) {
  return AuthViewModel(ref.read(authRepositoryProvider));
});

class AuthViewModel extends StateNotifier<AsyncValue<void>> {
  AuthViewModel(this._repo) : super(const AsyncData(null));

  final AuthRepository _repo;

  static const _redirect = 'codeforge://auth-callback';

  Session? get currentSession => _repo.currentSession;
  User? get currentUser => _repo.currentUser;

  // Email/Password

  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      await _repo.signInWithPassword(email: email, password: password);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> signUpWithPassword({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      await _repo.signUpWithPassword(
        email: email,
        password: password,
        emailRedirectTo: _redirect,
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> sendMagicLink({required String email}) async {
    state = const AsyncLoading();
    try {
      await _repo.sendMagicLink(email: email, redirectTo: _redirect);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  // OAuth

  Future<void> signInWithOAuth(OAuthProvider provider) async {
    state = const AsyncLoading();
    try {
      await _repo.signInWithOAuth(provider, redirectTo: _redirect);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    try {
      await _repo.signInWithGoogle(redirectTo: _redirect);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> signInWithApple() async {
    state = const AsyncLoading();
    try {
      await _repo.signInWithApple(redirectTo: _redirect);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> signInWithFacebook() async {
    state = const AsyncLoading();
    try {
      await _repo.signInWithFacebook(redirectTo: _redirect);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  // Sign out

  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      await _repo.signOut();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
