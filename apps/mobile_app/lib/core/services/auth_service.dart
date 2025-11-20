import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/app/supabase_init.dart';
import 'package:mobile_app/core/services/error_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authStateStreamProvider = Provider<Stream<AuthState>>((ref) {
  return AppSupabase.client.auth.onAuthStateChange;
});

class AuthService {
  final GoTrueClient _auth = AppSupabase.client.auth;
  final ErrorHandler _errorHandler = ErrorHandler();

  static const _mobileRedirect = 'codeforge://auth-callback';
  static const _webRedirect = 'https://zhbforum.github.io/CodeForge/';

  String get _redirect => kIsWeb ? _webRedirect : _mobileRedirect;

  Stream<AuthState> get onAuthStateChange => _auth.onAuthStateChange;

  Session? get currentSession => _auth.currentSession;
  User? get currentUser => _auth.currentUser;

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
      await _auth.signInWithOAuth(
        provider,
        redirectTo: _redirect,
      );
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
      await _auth.signInWithOtp(
        email: email,
        emailRedirectTo: _redirect,
      );
    } catch (e, st) {
      _errorHandler.handle(e, st);
      rethrow;
    }
  }
}
