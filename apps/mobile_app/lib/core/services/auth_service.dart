import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/app/supabase_init.dart';
import 'package:mobile_app/core/services/error_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authStateStreamProvider = Provider<Stream<AuthState>>((ref) {
  return AppSupabase.client.auth.onAuthStateChange;
});

abstract class AuthClient {
  Stream<AuthState> get onAuthStateChange;

  Session? get currentSession;
  User? get currentUser;

  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  });

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String? emailRedirectTo,
  });

  Future<void> signInWithOAuth(OAuthProvider provider, {String? redirectTo});

  Future<void> signOut();

  Future<void> signInWithOtp({required String email, String? emailRedirectTo});
}

class SupabaseAuthClient implements AuthClient {
  SupabaseAuthClient(this._inner);

  final GoTrueClient _inner;

  @override
  Stream<AuthState> get onAuthStateChange => _inner.onAuthStateChange;

  @override
  Session? get currentSession => _inner.currentSession;

  @override
  User? get currentUser => _inner.currentUser;

  @override
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) {
    return _inner.signInWithPassword(email: email, password: password);
  }

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String? emailRedirectTo,
  }) {
    return _inner.signUp(
      email: email,
      password: password,
      emailRedirectTo: emailRedirectTo,
    );
  }

  @override
  Future<void> signInWithOAuth(OAuthProvider provider, {String? redirectTo}) {
    return _inner.signInWithOAuth(provider, redirectTo: redirectTo);
  }

  @override
  Future<void> signOut() {
    return _inner.signOut();
  }

  @override
  Future<void> signInWithOtp({required String email, String? emailRedirectTo}) {
    return _inner.signInWithOtp(email: email, emailRedirectTo: emailRedirectTo);
  }
}

class AuthService {
  AuthService({AuthClient? auth, ErrorHandler? errorHandler})
    : _auth = auth ?? SupabaseAuthClient(AppSupabase.client.auth),
      _errorHandler = errorHandler ?? ErrorHandler();

  final AuthClient _auth;
  final ErrorHandler _errorHandler;

  Stream<AuthState> get onAuthStateChange => _auth.onAuthStateChange;

  Session? get currentSession => _auth.currentSession;
  User? get currentUser => _auth.currentUser;

  static const _redirect = 'codeforge://auth-callback';

  Future<AuthResponse> signInWithPassword(String email, String password) async {
    try {
      return await _auth.signInWithPassword(email: email, password: password);
    } catch (e, st) {
      _errorHandler.handle(e, st);
      rethrow;
    }
  }

  Future<AuthResponse> signUpWithPassword(String email, String password) async {
    try {
      return await _auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: _redirect,
      );
    } catch (e, st) {
      _errorHandler.handle(e, st);
      rethrow;
    }
  }

  Future<void> signInWithOAuth(OAuthProvider provider) async {
    try {
      await _auth.signInWithOAuth(provider, redirectTo: _redirect);
    } catch (e, st) {
      _errorHandler.handle(e, st);
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e, st) {
      _errorHandler.handle(e, st);
      rethrow;
    }
  }

  Future<void> sendMagicLink(String email) async {
    try {
      await _auth.signInWithOtp(email: email, emailRedirectTo: _redirect);
    } catch (e, st) {
      _errorHandler.handle(e, st);
      rethrow;
    }
  }
}
