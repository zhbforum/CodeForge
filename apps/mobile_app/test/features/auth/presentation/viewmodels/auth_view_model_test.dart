import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/auth/data/auth_repository.dart';
import 'package:mobile_app/features/auth/shared/auth_providers.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _FakeSession extends Fake implements Session {}

class _FakeUser extends Fake implements User {}

class _FakeAuthResponse extends Fake implements AuthResponse {}

void main() {
  late _MockAuthRepository repo;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(_FakeAuthResponse());
  });

  setUp(() {
    repo = _MockAuthRepository();

    container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repo)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('AuthViewModel getters', () {
    test('currentSession and currentUser delegate to repository', () {
      final session = _FakeSession();
      final user = _FakeUser();

      when(() => repo.currentSession).thenReturn(session);
      when(() => repo.currentUser).thenReturn(user);

      final vm = container.read(authViewModelProvider.notifier);

      expect(vm.currentSession, same(session));
      expect(vm.currentUser, same(user));
    });
  });

  group('AuthViewModel auth flows – success', () {
    const email = 'test@example.com';
    const password = 'secret-password';

    test('signInWithPassword calls repo and sets AsyncData(null)', () async {
      when(
        () => repo.signInWithPassword(email, password),
      ).thenAnswer((_) async => _FakeAuthResponse());

      final vm = container.read(authViewModelProvider.notifier);

      await vm.signInWithPassword(email, password);

      verify(() => repo.signInWithPassword(email, password)).called(1);

      final state = container.read(authViewModelProvider);
      expect(state, const AsyncData<void>(null));
    });

    test('signUpWithPassword calls repo and sets AsyncData(null)', () async {
      when(
        () => repo.signUpWithPassword(email, password),
      ).thenAnswer((_) async => _FakeAuthResponse());

      final vm = container.read(authViewModelProvider.notifier);

      await vm.signUpWithPassword(email, password);

      verify(() => repo.signUpWithPassword(email, password)).called(1);

      final state = container.read(authViewModelProvider);
      expect(state, const AsyncData<void>(null));
    });

    test('sendMagicLink calls repo and sets AsyncData(null)', () async {
      when(() => repo.sendMagicLink(email)).thenAnswer((_) async {});

      final vm = container.read(authViewModelProvider.notifier);

      await vm.sendMagicLink(email);

      verify(() => repo.sendMagicLink(email)).called(1);

      final state = container.read(authViewModelProvider);
      expect(state, const AsyncData<void>(null));
    });

    test('signInWithOAuth calls repo and sets AsyncData(null)', () async {
      const provider = OAuthProvider.google;

      when(() => repo.signInWithOAuth(provider)).thenAnswer((_) async {});

      final vm = container.read(authViewModelProvider.notifier);

      await vm.signInWithOAuth(provider);

      verify(() => repo.signInWithOAuth(provider)).called(1);

      final state = container.read(authViewModelProvider);
      expect(state, const AsyncData<void>(null));
    });

    test('signOut calls repo and sets AsyncData(null)', () async {
      when(() => repo.signOut()).thenAnswer((_) async {});

      final vm = container.read(authViewModelProvider.notifier);

      await vm.signOut();

      verify(() => repo.signOut()).called(1);

      final state = container.read(authViewModelProvider);
      expect(state, const AsyncData<void>(null));
    });
  });

  group('AuthViewModel auth flows – error', () {
    const email = 'test@example.com';
    const password = 'secret-password';

    test('signInWithPassword sets AsyncError and rethrows', () async {
      final exception = Exception('sign-in failed');

      when(() => repo.signInWithPassword(email, password)).thenThrow(exception);

      final vm = container.read(authViewModelProvider.notifier);

      await expectLater(
        vm.signInWithPassword(email, password),
        throwsA(same(exception)),
      );

      final state = container.read(authViewModelProvider);
      expect(state, isA<AsyncError<void>>());
      final errorState = state as AsyncError<void>;
      expect(errorState.error, same(exception));
    });

    test('signUpWithPassword sets AsyncError and rethrows', () async {
      final exception = Exception('sign-up failed');

      when(() => repo.signUpWithPassword(email, password)).thenThrow(exception);

      final vm = container.read(authViewModelProvider.notifier);

      await expectLater(
        vm.signUpWithPassword(email, password),
        throwsA(same(exception)),
      );

      final state = container.read(authViewModelProvider);
      expect(state, isA<AsyncError<void>>());
      final errorState = state as AsyncError<void>;
      expect(errorState.error, same(exception));
    });

    test('sendMagicLink sets AsyncError and rethrows', () async {
      final exception = Exception('magic-link failed');

      when(() => repo.sendMagicLink(email)).thenThrow(exception);

      final vm = container.read(authViewModelProvider.notifier);

      await expectLater(vm.sendMagicLink(email), throwsA(same(exception)));

      final state = container.read(authViewModelProvider);
      expect(state, isA<AsyncError<void>>());
      final errorState = state as AsyncError<void>;
      expect(errorState.error, same(exception));
    });

    test('signInWithOAuth sets AsyncError and rethrows', () async {
      final exception = Exception('oauth failed');
      const provider = OAuthProvider.google;

      when(() => repo.signInWithOAuth(provider)).thenThrow(exception);

      final vm = container.read(authViewModelProvider.notifier);

      await expectLater(vm.signInWithOAuth(provider), throwsA(same(exception)));

      final state = container.read(authViewModelProvider);
      expect(state, isA<AsyncError<void>>());
      final errorState = state as AsyncError<void>;
      expect(errorState.error, same(exception));
    });

    test('signOut sets AsyncError and rethrows', () async {
      final exception = Exception('sign-out failed');

      when(() => repo.signOut()).thenThrow(exception);

      final vm = container.read(authViewModelProvider.notifier);

      await expectLater(vm.signOut(), throwsA(same(exception)));

      final state = container.read(authViewModelProvider);
      expect(state, isA<AsyncError<void>>());
      final errorState = state as AsyncError<void>;
      expect(errorState.error, same(exception));
    });
  });
}
