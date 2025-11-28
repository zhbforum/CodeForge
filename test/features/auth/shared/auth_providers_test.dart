import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/services/auth_service.dart';
import 'package:mobile_app/features/auth/data/auth_repository.dart';
import 'package:mobile_app/features/auth/presentation/viewmodels/auth_view_model.dart';
import 'package:mobile_app/features/auth/shared/auth_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _FakeAuthService implements AuthService {
  _FakeAuthService(this._stream);

  final Stream<AuthState> _stream;

  @override
  Stream<AuthState> get onAuthStateChange => _stream;

  @override
  Session? get currentSession => null;

  @override
  User? get currentUser => null;

  @override
  Future<AuthResponse> signInWithPassword(String email, String password) async {
    return AuthResponse();
  }

  @override
  Future<AuthResponse> signUpWithPassword(String email, String password) async {
    return AuthResponse();
  }

  @override
  Future<void> sendMagicLink(String email) async {}

  @override
  Future<void> signInWithOAuth(OAuthProvider provider) async {}

  @override
  Future<void> signOut() async {}
}

void main() {
  group('auth shared providers wiring', () {
    test(
      'authStateStreamProviderAlias forwards events from authServiceProvider',
      () async {
        final controller = StreamController<AuthState>();

        final container = ProviderContainer(
          overrides: [
            authServiceProvider.overrideWithValue(
              _FakeAuthService(controller.stream),
            ),
          ],
        );
        addTearDown(() async {
          await controller.close();
          container.dispose();
        });

        const state = AuthState(AuthChangeEvent.signedIn, null);

        final future = container.read(authStateStreamProviderAlias.future);

        controller.add(state);
        await controller.close();

        final first = await future;

        expect(first.event, AuthChangeEvent.signedIn);
        expect(first.session, isNull);
      },
    );

    test('authRepositoryProvider builds an AuthRepository', () {
      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(
            _FakeAuthService(const Stream<AuthState>.empty()),
          ),
        ],
      );
      addTearDown(container.dispose);

      final repo = container.read(authRepositoryProvider);

      expect(repo, isA<AuthRepository>());
    });

    test('authViewModelProvider exposes an AuthViewModel notifier', () {
      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(
            _FakeAuthService(const Stream<AuthState>.empty()),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(authViewModelProvider.notifier);
      expect(notifier, isA<AuthViewModel>());

      final state = container.read(authViewModelProvider);
      expect(state, isA<AsyncValue<void>>());
    });
  });
}
