import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/services/auth_refresh_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('authRefreshProvider', () {
    late StreamController<AuthState> controller;
    late ProviderContainer container;

    setUp(() {
      controller = StreamController<AuthState>();
      container = ProviderContainer(
        overrides: [
          authStateStreamProvider.overrideWithValue(controller.stream),
          currentSessionGetterProvider.overrideWithValue(() => null),
        ],
      );
    });

    tearDown(() async {
      await controller.close();
      container.dispose();
    });

    test('exposes value getter and seeds with current session', () async {
      final notifier = container.read(authRefreshProvider);
      final value = (notifier as dynamic).value as AsyncValue<Session?>;
      expect(value, isA<AsyncData<Session?>>());
      expect(value.value, isNull);
    });

    test('onData success: updates value with session and notifies', () async {
      final notifications = <int>[];
      final notifier = container.read(authRefreshProvider)
        ..addListener(() => notifications.add(1));

      final fakeSession = Session(
        accessToken: 'token',
        refreshToken: 'refresh',
        user: const User(
          id: 'uid',
          appMetadata: {},
          userMetadata: {},
          aud: 'authenticated',
          createdAt: '1970-01-01T00:00:00Z',
        ),
        tokenType: 'bearer',
        expiresIn: 3600,
      );

      controller.add(AuthState(AuthChangeEvent.signedIn, fakeSession));
      await Future<void>.delayed(const Duration(milliseconds: 1));

      final value = (notifier as dynamic).value as AsyncValue<Session?>;
      expect(value, isA<AsyncData<Session?>>());
      expect(value.value, equals(fakeSession));
      expect(notifications, isNotEmpty);
    });

    test(
      'onData error branch: currentSession throws => AsyncError + notify',
      () async {
        var shouldThrow = false;
        container.dispose();
        controller = StreamController<AuthState>();
        container = ProviderContainer(
          overrides: [
            authStateStreamProvider.overrideWithValue(controller.stream),
            currentSessionGetterProvider.overrideWithValue(() {
              if (shouldThrow) {
                throw StateError('boom');
              }
              return null;
            }),
          ],
        );

        final notifier = container.read(authRefreshProvider);
        var notified = false;
        notifier.addListener(() => notified = true);

        shouldThrow = true;
        controller.add(const AuthState(AuthChangeEvent.tokenRefreshed, null));
        await Future<void>.delayed(const Duration(milliseconds: 5));

        final value = (notifier as dynamic).value as AsyncValue<Session?>;
        expect(value, isA<AsyncError<Session?>>());
        expect(notified, isTrue);
      },
    );

    test('onError handler: stream error => AsyncError + notify', () async {
      final notifier = container.read(authRefreshProvider);
      var notified = false;
      notifier.addListener(() => notified = true);

      controller.addError(Exception('stream-fail'));
      await Future<void>.delayed(const Duration(milliseconds: 1));

      final value = (notifier as dynamic).value as AsyncValue<Session?>;
      expect(value, isA<AsyncError<Session?>>());
      expect(notified, isTrue);
    });
  });
}
