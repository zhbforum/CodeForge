import 'package:mobile_app/core/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  AuthRepository(this._service);
  final AuthService _service;

  Session? get currentSession => _service.currentSession;
  User? get currentUser => _service.currentUser;
  Stream<AuthState> get onAuthStateChange => _service.onAuthStateChange;

  Future<AuthResponse> signInWithPassword(String email, String password) =>
      _service.signInWithPassword(email, password);

  Future<AuthResponse> signUpWithPassword(String email, String password) =>
      _service.signUpWithPassword(email, password);

  Future<void> sendMagicLink(String email) => _service.sendMagicLink(email);

  Future<void> signInWithOAuth(OAuthProvider provider) =>
      _service.signInWithOAuth(provider);

  Future<void> signOut() => _service.signOut();
}
