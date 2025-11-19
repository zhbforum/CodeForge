import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/services/api_service.dart';
import 'package:mobile_app/features/profile/data/supabase_profile_repository.dart';
import 'package:mobile_app/features/profile/domain/profile.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockApiService extends Mock implements ApiService {}

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _MockGoTrueClient extends Mock implements GoTrueClient {}

class _MockUser extends Mock implements User {}

void main() {
  group('SupabaseProfileRepository', () {
    test('throws StateError when not authenticated (_uidOrThrow)', () async {
      final api = _MockApiService();
      final db = _MockSupabaseClient();
      final auth = _MockGoTrueClient();

      when(() => db.auth).thenReturn(auth);
      when(() => auth.currentUser).thenReturn(null);

      final repo = SupabaseProfileRepository(api, db);

      await expectLater(
        repo.load(),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            'Not authenticated',
          ),
        ),
      );
    });

    test('load returns existing profile when row found', () async {
      final api = _MockApiService();
      final db = _MockSupabaseClient();
      final auth = _MockGoTrueClient();
      final user = _MockUser();

      when(() => db.auth).thenReturn(auth);
      when(() => auth.currentUser).thenReturn(user);
      when(() => user.id).thenReturn('user-1');
      when(() => user.email).thenReturn('user@example.com');

      when(
        () => api.query(
          table: 'profiles',
          select: '*',
          filters: {'id': 'user-1'},
          limit: 1,
        ),
      ).thenAnswer(
        (_) async => <Map<String, dynamic>>[
          {
            'id': 'user-1',
            'username': 'existing-user',
            'full_name': 'Existing User',
            'bio': 'Hello',
            'avatar_url': null,
            'updated_at': '2023-01-01T00:00:00Z',
          },
        ],
      );

      final repo = SupabaseProfileRepository(api, db);

      final profile = await repo.load();

      expect(profile, isA<Profile>());
      expect(profile.id, 'user-1');
      expect(profile.username, 'existing-user');

      verify(
        () => api.query(
          table: 'profiles',
          select: '*',
          filters: {'id': 'user-1'},
          limit: 1,
        ),
      ).called(1);
    });

    test('load creates profile when none exists and then returns it', () async {
      final api = _MockApiService();
      final db = _MockSupabaseClient();
      final auth = _MockGoTrueClient();
      final user = _MockUser();

      when(() => db.auth).thenReturn(auth);
      when(() => auth.currentUser).thenReturn(user);
      when(() => user.id).thenReturn('user-2');
      when(() => user.email).thenReturn('new.user@example.com');

      var queryCallCount = 0;

      when(
        () => api.query(
          table: 'profiles',
          select: '*',
          filters: {'id': 'user-2'},
          limit: 1,
        ),
      ).thenAnswer((_) async {
        if (queryCallCount == 0) {
          queryCallCount++;
          return <Map<String, dynamic>>[];
        }
        queryCallCount++;
        return <Map<String, dynamic>>[
          {
            'id': 'user-2',
            'username': 'new.user',
            'full_name': null,
            'bio': null,
            'avatar_url': null,
            'updated_at': '2023-01-01T00:00:00Z',
          },
        ];
      });

      when(
        () => api.upsert(
          table: 'profiles',
          values: any(named: 'values'),
          onConflict: 'id',
        ),
      ).thenAnswer((_) async {});

      final repo = SupabaseProfileRepository(api, db);

      final profile = await repo.load();

      expect(profile.id, 'user-2');
      expect(profile.username, 'new.user');

      verify(
        () => api.upsert(
          table: 'profiles',
          values: any(named: 'values'),
          onConflict: 'id',
        ),
      ).called(1);

      expect(queryCallCount, 2);
    });

    test(
      'load throws when profile creation fails (createdRows.isEmpty)',
      () async {
        final api = _MockApiService();
        final db = _MockSupabaseClient();
        final auth = _MockGoTrueClient();
        final user = _MockUser();

        when(() => db.auth).thenReturn(auth);
        when(() => auth.currentUser).thenReturn(user);
        when(() => user.id).thenReturn('user-3');
        when(() => user.email).thenReturn('fail@example.com');

        when(
          () => api.query(
            table: 'profiles',
            select: '*',
            filters: {'id': 'user-3'},
            limit: 1,
          ),
        ).thenAnswer((_) async => <Map<String, dynamic>>[]);

        when(
          () => api.upsert(
            table: 'profiles',
            values: any(named: 'values'),
            onConflict: 'id',
          ),
        ).thenAnswer((_) async {});

        when(
          () => api.query(
            table: 'profiles',
            select: '*',
            filters: {'id': 'user-3'},
            limit: 1,
          ),
        ).thenAnswer((_) async => <Map<String, dynamic>>[]);

        final repo = SupabaseProfileRepository(api, db);

        await expectLater(
          repo.load(),
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              'Failed to create profile',
            ),
          ),
        );
      },
    );

    test('updateAvatar upserts avatar_url for current user', () async {
      final api = _MockApiService();
      final db = _MockSupabaseClient();
      final auth = _MockGoTrueClient();
      final user = _MockUser();

      when(() => db.auth).thenReturn(auth);
      when(() => auth.currentUser).thenReturn(user);
      when(() => user.id).thenReturn('user-4');

      when(
        () => api.upsert(
          table: 'profiles',
          values: any(named: 'values'),
          onConflict: 'id',
        ),
      ).thenAnswer((_) async {});

      final repo = SupabaseProfileRepository(api, db);

      await repo.updateAvatar('https://example.com/avatar.png');

      verify(
        () => api.upsert(
          table: 'profiles',
          values: any(named: 'values'),
          onConflict: 'id',
        ),
      ).called(1);
    });

    test('ensureProfile upserts minimal profile for current user', () async {
      final api = _MockApiService();
      final db = _MockSupabaseClient();
      final auth = _MockGoTrueClient();
      final user = _MockUser();

      when(() => db.auth).thenReturn(auth);
      when(() => auth.currentUser).thenReturn(user);
      when(() => user.id).thenReturn('user-5');

      when(
        () => api.upsert(
          table: 'profiles',
          values: any(named: 'values'),
          onConflict: 'id',
        ),
      ).thenAnswer((_) async {});

      final repo = SupabaseProfileRepository(api, db);

      await repo.ensureProfile();

      verify(
        () => api.upsert(
          table: 'profiles',
          values: any(named: 'values'),
          onConflict: 'id',
        ),
      ).called(1);
    });

    test('updateFullName upserts full_name for current user', () async {
      final api = _MockApiService();
      final db = _MockSupabaseClient();
      final auth = _MockGoTrueClient();
      final user = _MockUser();

      when(() => db.auth).thenReturn(auth);
      when(() => auth.currentUser).thenReturn(user);
      when(() => user.id).thenReturn('user-6');

      when(
        () => api.upsert(
          table: 'profiles',
          values: any(named: 'values'),
          onConflict: 'id',
        ),
      ).thenAnswer((_) async {});

      final repo = SupabaseProfileRepository(api, db);

      await repo.updateFullName('New Name');

      verify(
        () => api.upsert(
          table: 'profiles',
          values: any(named: 'values'),
          onConflict: 'id',
        ),
      ).called(1);
    });

    test('updateBio upserts bio for current user', () async {
      final api = _MockApiService();
      final db = _MockSupabaseClient();
      final auth = _MockGoTrueClient();
      final user = _MockUser();

      when(() => db.auth).thenReturn(auth);
      when(() => auth.currentUser).thenReturn(user);
      when(() => user.id).thenReturn('user-7');

      when(
        () => api.upsert(
          table: 'profiles',
          values: any(named: 'values'),
          onConflict: 'id',
        ),
      ).thenAnswer((_) async {});

      final repo = SupabaseProfileRepository(api, db);

      await repo.updateBio('New bio');

      verify(
        () => api.upsert(
          table: 'profiles',
          values: any(named: 'values'),
          onConflict: 'id',
        ),
      ).called(1);
    });
  });
}
