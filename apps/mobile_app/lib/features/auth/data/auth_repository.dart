import 'package:mobile_app/app/supabase_init.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  AuthRepository(this._auth);

  factory AuthRepository.supabase() => AuthRepository(AppSupabase.client.auth);
  final GoTrueClient _auth;

  Session? get currentSession => _auth.currentSession;
  User? get currentUser => _auth.currentUser;

  Stream<AuthState> onAuthStateChange() => _auth.onAuthStateChange;

  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) {
    return _auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signInWithProvider({
    required OAuthProvider provider,
    required String redirectTo,
  }) async {
    await _auth.signInWithOAuth(provider, redirectTo: redirectTo);
  }

  Future<void> signInWithGoogle({required String redirectTo}) =>
      signInWithProvider(provider: OAuthProvider.google, redirectTo: redirectTo);

  Future<void> signInWithApple({required String redirectTo}) =>
      signInWithProvider(provider: OAuthProvider.apple, redirectTo: redirectTo);

  Future<void> signInWithFacebook({required String redirectTo}) =>
      signInWithProvider(provider: OAuthProvider.facebook, redirectTo: redirectTo);

  Future<void> sendMagicLink({
    required String email,
    required String redirectTo,
  }) async {
    await _auth.signInWithOtp(email: email, emailRedirectTo: redirectTo);
  }

  Future<void> signOut() => _auth.signOut();
}
