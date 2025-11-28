import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/features/auth/data/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthViewModel extends StateNotifier<AsyncValue<void>> {
  AuthViewModel(this._repo) : super(const AsyncData(null));

  final AuthRepository _repo;

  Session? get currentSession => _repo.currentSession;
  User? get currentUser => _repo.currentUser;

  Future<void> signInWithPassword(String email, String password) async {
    state = const AsyncLoading();
    try {
      await _repo.signInWithPassword(email, password);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> signUpWithPassword(String email, String password) async {
    state = const AsyncLoading();
    try {
      await _repo.signUpWithPassword(email, password);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> sendMagicLink(String email) async {
    state = const AsyncLoading();
    try {
      await _repo.sendMagicLink(email);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> signInWithOAuth(OAuthProvider provider) async {
    state = const AsyncLoading();
    try {
      await _repo.signInWithOAuth(provider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

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
