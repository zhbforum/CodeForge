import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/services/auth_service.dart';
import 'package:mobile_app/features/auth/data/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _FakeAuthService implements AuthService {
  _FakeAuthService({Session? session, User? user})
    : _session = session,
      _user = user;

  final Session? _session;
  final User? _user;

  bool signInWithPasswordCalled = false;
  String? signInEmail;
  String? signInPassword;

  bool signUpWithPasswordCalled = false;
  String? signUpEmail;
  String? signUpPassword;

  bool sendMagicLinkCalled = false;
  String? magicLinkEmail;

  bool signInWithOAuthCalled = false;
  OAuthProvider? signInWithOAuthProvider;

  bool signOutCalled = false;

  final _authStateController = StreamController<AuthState>.broadcast();

  @override
  Session? get currentSession => _session;

  @override
  User? get currentUser => _user;

  @override
  Stream<AuthState> get onAuthStateChange => _authStateController.stream;

  @override
  Future<AuthResponse> signInWithPassword(String email, String password) async {
    signInWithPasswordCalled = true;
    signInEmail = email;
    signInPassword = password;

    return AuthResponse(session: _session, user: _user);
  }

  @override
  Future<AuthResponse> signUpWithPassword(String email, String password) async {
    signUpWithPasswordCalled = true;
    signUpEmail = email;
    signUpPassword = password;

    return AuthResponse(session: _session, user: _user);
  }

  @override
  Future<void> sendMagicLink(String email) async {
    sendMagicLinkCalled = true;
    magicLinkEmail = email;
  }

  @override
  Future<void> signInWithOAuth(OAuthProvider provider) async {
    signInWithOAuthCalled = true;
    signInWithOAuthProvider = provider;
  }

  @override
  Future<void> signOut() async {
    signOutCalled = true;
  }

  void addAuthState(AuthState state) {
    _authStateController.add(state);
  }

  void dispose() {
    _authStateController.close();
  }
}

void main() {
  group('AuthRepository', () {
    late _FakeAuthService fakeService;
    late AuthRepository repository;

    setUp(() {
      fakeService = _FakeAuthService();
      repository = AuthRepository(fakeService);
    });

    tearDown(() {
      fakeService.dispose();
    });

    test(
      'exposes currentSession / currentUser / onAuthStateChange from service',
      () {
        expect(repository.currentSession, isNull);
        expect(repository.currentUser, isNull);

        final stream = repository.onAuthStateChange;
        expect(stream, isA<Stream<AuthState>>());
      },
    );

    test('delegates signInWithPassword to underlying service', () async {
      const email = 'test@example.com';
      const password = 'secret-password';

      await repository.signInWithPassword(email, password);

      expect(fakeService.signInWithPasswordCalled, isTrue);
      expect(fakeService.signInEmail, email);
      expect(fakeService.signInPassword, password);
    });

    test('delegates signUpWithPassword to underlying service', () async {
      const email = 'new@example.com';
      const password = 'new-password';

      await repository.signUpWithPassword(email, password);

      expect(fakeService.signUpWithPasswordCalled, isTrue);
      expect(fakeService.signUpEmail, email);
      expect(fakeService.signUpPassword, password);
    });

    test('delegates sendMagicLink to underlying service', () async {
      const email = 'magic@example.com';

      await repository.sendMagicLink(email);

      expect(fakeService.sendMagicLinkCalled, isTrue);
      expect(fakeService.magicLinkEmail, email);
    });

    test('delegates signInWithOAuth to underlying service', () async {
      const provider = OAuthProvider.google;

      await repository.signInWithOAuth(provider);

      expect(fakeService.signInWithOAuthCalled, isTrue);
      expect(fakeService.signInWithOAuthProvider, provider);
    });

    test('delegates signOut to underlying service', () async {
      await repository.signOut();

      expect(fakeService.signOutCalled, isTrue);
    });
  });
}
