import 'package:mobile_app/app/supabase_init.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  AuthRepository(this._auth);
  factory AuthRepository.supabase() => AuthRepository(AppSupabase.client.auth);

  final GoTrueClient _auth;

  static const _redirect = 'codeforge://auth-callback';

  Session? get currentSession => _auth.currentSession;
  User? get currentUser => _auth.currentUser;

  Stream<AuthState> onAuthStateChange() => _auth.onAuthStateChange;

  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) =>
      _auth.signInWithPassword(email: email, password: password);

  Future<AuthResponse> signUpWithPassword({
    required String email,
    required String password,
    String? emailRedirectTo,
  }) =>
      _auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: emailRedirectTo,
      );

  Future<void> sendMagicLink({
    required String email,
    String? redirectTo,
  }) =>
      _auth.signInWithOtp(
        email: email,
        emailRedirectTo: redirectTo ?? _redirect,
      );

  Future<void> signInWithOAuth(
    OAuthProvider provider, {
    String? redirectTo,
  }) =>
      _auth.signInWithOAuth(
        provider,
        redirectTo: redirectTo ?? _redirect,
        // queryParams: queryParams,
      );

  Future<void> signInWithGoogle({String? redirectTo}) =>
      signInWithOAuth(OAuthProvider.google, redirectTo: redirectTo);

  Future<void> signInWithApple({String? redirectTo}) =>
      signInWithOAuth(OAuthProvider.apple, redirectTo: redirectTo);

  Future<void> signInWithFacebook({String? redirectTo}) =>
      signInWithOAuth(OAuthProvider.facebook, redirectTo: redirectTo);

  Future<AuthResponse> signInWithIdToken({
    required OAuthProvider provider,
    required String idToken,
    String? accessToken,
    String? nonce,       
  }) =>
      _auth.signInWithIdToken(
        provider: provider,
        idToken: idToken,
        accessToken: accessToken,
        nonce: nonce,
      );

  Future<void> signOut() => _auth.signOut();
}
