import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/auth/shared/auth_providers.dart';
import 'package:mobile_app/features/profile/data/profile_repository.dart';
import 'package:mobile_app/features/profile/data/profile_repository_provider.dart';
import 'package:mobile_app/features/profile/domain/profile.dart';
import 'package:mobile_app/features/profile/presentation/viewmodels/profile_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _FakeProfileRepository implements ProfileRepository {
  _FakeProfileRepository({
    this.onLoad,
    this.onUpdateFullName,
    this.onUpdateBio,
    this.onUpdateAvatar,
  });

  Future<Profile> Function()? onLoad;
  Future<void> Function(String?)? onUpdateFullName;
  Future<void> Function(String?)? onUpdateBio;
  Future<void> Function(String)? onUpdateAvatar;

  @override
  Future<Profile> load() {
    return onLoad!.call();
  }

  @override
  Future<void> updateFullName(String? fullName) {
    return onUpdateFullName!.call(fullName);
  }

  @override
  Future<void> updateBio(String? bio) {
    return onUpdateBio!.call(bio);
  }

  @override
  Future<void> updateAvatar(String url) {
    return onUpdateAvatar!.call(url);
  }
}

Profile makeTestProfile() => const Profile(
  id: 'user-1',
  fullName: 'Test User',
  bio: 'Test bio',
  avatarUrl: 'https://example.com/avatar.png',
);

Future<AsyncValue<Profile>> waitForProfileToBeData(
  ProviderContainer container,
) {
  final completer = Completer<AsyncValue<Profile>>();

  late final ProviderSubscription<AsyncValue<Profile>> sub;
  sub = container.listen<AsyncValue<Profile>>(profileProvider, (
    previous,
    next,
  ) {
    if (next is AsyncData<Profile> && !completer.isCompleted) {
      completer.complete(next);
      sub.close();
    }
  }, fireImmediately: true);

  return completer.future;
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    SharedPreferences.setMockInitialValues(<String, Object>{});

    await Supabase.initialize(
      url: 'https://example.supabase.co',
      anonKey: 'example-anon-key',
    );
  });

  group('profileProvider', () {
    test('uid == null => unauthenticated error', () {
      final fakeRepo = _FakeProfileRepository(
        onLoad: () async => makeTestProfile(),
      );

      final container = ProviderContainer(
        overrides: [
          profileRepositoryProvider.overrideWith((ref) => fakeRepo),
          currentUserIdProvider.overrideWith((ref) => null),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(profileProvider);

      expect(state, isA<AsyncError<Profile>>());
      final error = state as AsyncError<Profile>;
      expect(error.error, isA<StateError>());
      expect((error.error as StateError).message, 'Not authenticated');
    });

    test('uid != null => calls load and ends in AsyncData', () async {
      final calls = <String>[];

      final fakeRepo = _FakeProfileRepository(
        onLoad: () async {
          calls.add('load');
          return makeTestProfile();
        },
      );

      final container = ProviderContainer(
        overrides: [
          profileRepositoryProvider.overrideWith((ref) => fakeRepo),
          currentUserIdProvider.overrideWith((ref) => 'user-123'),
        ],
      );
      addTearDown(container.dispose);

      final initial = container.read(profileProvider);
      expect(initial, const AsyncLoading<Profile>());

      final state = await waitForProfileToBeData(container);

      expect(calls, ['load']);
      expect(state, isA<AsyncData<Profile>>());
      expect(state.value, isA<Profile>());
    });
  });

  group('ProfileController', () {
    test('constructor sets AsyncLoading', () {
      final fakeRepo = _FakeProfileRepository(
        onLoad: () async => makeTestProfile(),
      );

      final controller = ProfileController(fakeRepo);

      expect(controller.state, const AsyncLoading<Profile>());
    });

    test('setUnauthenticated sets AsyncError with StateError', () {
      final fakeRepo = _FakeProfileRepository(
        onLoad: () async => makeTestProfile(),
      );

      final controller = ProfileController(fakeRepo)..setUnauthenticated();

      expect(controller.state, isA<AsyncError<Profile>>());
      final error = controller.state as AsyncError<Profile>;
      expect(error.error, isA<StateError>());
      expect((error.error as StateError).message, 'Not authenticated');
    });

    test('load success => AsyncData', () async {
      final profile = makeTestProfile();

      final fakeRepo = _FakeProfileRepository(onLoad: () async => profile);

      final controller = ProfileController(fakeRepo);

      await controller.load();

      expect(controller.state, isA<AsyncData<Profile>>());
      expect(controller.state.value, same(profile));
    });

    test('load failure => AsyncError', () async {
      final error = Exception('load failed');

      final fakeRepo = _FakeProfileRepository(
        onLoad: () => Future<Profile>.error(error),
      );

      final controller = ProfileController(fakeRepo);

      await controller.load();

      expect(controller.state, isA<AsyncError<Profile>>());
      final asyncError = controller.state as AsyncError<Profile>;
      expect(asyncError.error, same(error));
    });

    test('reset sets AsyncLoading', () async {
      final profile = makeTestProfile();

      final fakeRepo = _FakeProfileRepository(onLoad: () async => profile);

      final controller = ProfileController(fakeRepo);

      await controller.load();
      expect(controller.state, isA<AsyncData<Profile>>());

      controller.reset();

      expect(controller.state, const AsyncLoading<Profile>());
    });

    group('updateFullName', () {
      test('no profile => throws StateError and sets AsyncError', () async {
        final fakeRepo = _FakeProfileRepository(
          onLoad: () async => makeTestProfile(),
          onUpdateFullName: (String? _) async {},
        );

        final controller = ProfileController(fakeRepo);

        await expectLater(
          controller.updateFullName('New'),
          throwsA(isA<StateError>()),
        );

        expect(controller.state, isA<AsyncError<Profile>>());
        expect(
          (controller.state as AsyncError<Profile>).error,
          isA<StateError>(),
        );
      });

      test('happy path => calls repo and reloads', () async {
        final profile = makeTestProfile();
        String? updated;

        final fakeRepo = _FakeProfileRepository(
          onLoad: () async => profile,
          onUpdateFullName: (String? name) async {
            updated = name;
          },
        );

        final controller = ProfileController(fakeRepo)
          ..state = AsyncData<Profile>(profile);

        await controller.updateFullName('New');

        expect(updated, 'New');
        expect(controller.state, isA<AsyncData<Profile>>());
      });

      test('repo throws => state AsyncError and error rethrown', () async {
        final profile = makeTestProfile();
        final error = Exception('updateFullName failed');

        final fakeRepo = _FakeProfileRepository(
          onLoad: () async => profile,
          onUpdateFullName: (String? _) => Future<void>.error(error),
        );

        final controller = ProfileController(fakeRepo)
          ..state = AsyncData<Profile>(profile);

        await expectLater(
          controller.updateFullName('Name'),
          throwsA(same(error)),
        );

        expect(controller.state, isA<AsyncError<Profile>>());
        expect((controller.state as AsyncError<Profile>).error, same(error));
      });
    });

    group('updateBio', () {
      test('no profile => throws StateError and sets AsyncError', () async {
        final fakeRepo = _FakeProfileRepository(
          onLoad: () async => makeTestProfile(),
          onUpdateBio: (String? _) async {},
        );

        final controller = ProfileController(fakeRepo);

        await expectLater(
          controller.updateBio('New bio'),
          throwsA(isA<StateError>()),
        );

        expect(controller.state, isA<AsyncError<Profile>>());
        expect(
          (controller.state as AsyncError<Profile>).error,
          isA<StateError>(),
        );
      });

      test('happy path => calls repo and reloads', () async {
        final profile = makeTestProfile();
        String? updated;

        final fakeRepo = _FakeProfileRepository(
          onLoad: () async => profile,
          onUpdateBio: (String? bio) async {
            updated = bio;
          },
        );

        final controller = ProfileController(fakeRepo)
          ..state = AsyncData<Profile>(profile);

        await controller.updateBio('New bio');

        expect(updated, 'New bio');
        expect(controller.state, isA<AsyncData<Profile>>());
      });

      test('repo throws => state AsyncError and error rethrown', () async {
        final profile = makeTestProfile();
        final error = Exception('updateBio failed');

        final fakeRepo = _FakeProfileRepository(
          onLoad: () async => profile,
          onUpdateBio: (String? _) => Future<void>.error(error),
        );

        final controller = ProfileController(fakeRepo)
          ..state = AsyncData<Profile>(profile);

        await expectLater(controller.updateBio('bio'), throwsA(same(error)));

        expect(controller.state, isA<AsyncError<Profile>>());
        expect((controller.state as AsyncError<Profile>).error, same(error));
      });
    });

    group('updateAvatar', () {
      test('no profile => throws StateError and sets AsyncError', () async {
        final fakeRepo = _FakeProfileRepository(
          onLoad: () async => makeTestProfile(),
          onUpdateAvatar: (String _) async {},
        );

        final controller = ProfileController(fakeRepo);

        await expectLater(
          controller.updateAvatar('https://example.com/new.png'),
          throwsA(isA<StateError>()),
        );

        expect(controller.state, isA<AsyncError<Profile>>());
        expect(
          (controller.state as AsyncError<Profile>).error,
          isA<StateError>(),
        );
      });

      test('happy path => calls repo and reloads', () async {
        final profile = makeTestProfile();
        String? updated;

        final fakeRepo = _FakeProfileRepository(
          onLoad: () async => profile,
          onUpdateAvatar: (String url) async {
            updated = url;
          },
        );

        final controller = ProfileController(fakeRepo)
          ..state = AsyncData<Profile>(profile);

        await controller.updateAvatar('https://example.com/new.png');

        expect(updated, 'https://example.com/new.png');
        expect(controller.state, isA<AsyncData<Profile>>());
      });

      test('repo throws => state AsyncError and error rethrown', () async {
        final profile = makeTestProfile();
        final error = Exception('updateAvatar failed');

        final fakeRepo = _FakeProfileRepository(
          onLoad: () async => profile,
          onUpdateAvatar: (String _) => Future<void>.error(error),
        );

        final controller = ProfileController(fakeRepo)
          ..state = AsyncData<Profile>(profile);

        await expectLater(
          controller.updateAvatar('https://example.com/new.png'),
          throwsA(same(error)),
        );

        expect(controller.state, isA<AsyncError<Profile>>());
        expect((controller.state as AsyncError<Profile>).error, same(error));
      });
    });
  });
}
