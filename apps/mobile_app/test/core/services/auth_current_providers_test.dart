import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/auth/shared/auth_providers.dart'
    show authStateStreamProvider;
import 'package:mobile_app/features/auth/shared/auth_providers.dart'
    show
        authSessionProvider,
        currentSessionProvider,
        currentUserIdProvider,
        currentUserProvider,
        isAuthenticatedProvider;
import 'package:supabase_flutter/supabase_flutter.dart';

Session? _makeSession(String userId) {
  final userJson = <String, dynamic>{
    'id': userId,
    'aud': 'authenticated',
    'role': 'authenticated',
    'email': 'user@example.com',
    'app_metadata': <String, dynamic>{},
    'user_metadata': <String, dynamic>{},
    'identities': <dynamic>[],
    'created_at': DateTime.now().toIso8601String(),
    'updated_at': DateTime.now().toIso8601String(),
  };

  final sessionJson = <String, dynamic>{
    'access_token': 'token',
    'token_type': 'bearer',
    'expires_in': 3600,
    'expires_at': DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600,
    'refresh_token': 'refresh',
    'user': userJson,
  };

  return Session.fromJson(sessionJson);
}

void main() {
  group('auth current* providers', () {
    test('no session -> all null/false', () async {
      final container = ProviderContainer(
        overrides: [
          authStateStreamProvider.overrideWith(
            (ref) => Stream<AuthState>.value(
              const AuthState(AuthChangeEvent.signedOut, null),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authStateStreamProvider.future);

      expect(container.read(currentSessionProvider), isNull);
      expect(container.read(isAuthenticatedProvider), isFalse);
      expect(container.read(currentUserProvider), isNull);
      expect(container.read(currentUserIdProvider), isNull);

      final av = container.read(authSessionProvider);
      expect(av.valueOrNull, isNull);
    });

    test('with session -> mapped correctly', () async {
      final session = _makeSession('u_123');

      final container = ProviderContainer(
        overrides: [
          authStateStreamProvider.overrideWith(
            (ref) => Stream<AuthState>.value(
              AuthState(AuthChangeEvent.signedIn, session),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authStateStreamProvider.future);

      final curSession = container.read(currentSessionProvider);
      expect(curSession, isNotNull);

      expect(container.read(isAuthenticatedProvider), isTrue);

      final user = container.read(currentUserProvider);
      expect(user, isNotNull);
      expect(user!.id, 'u_123');

      expect(container.read(currentUserIdProvider), 'u_123');

      final av = container.read(authSessionProvider);
      final sess = av.valueOrNull;
      final u = sess?.user;
      expect(u?.id, 'u_123');
    });
  });
}
