import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/services/api_service.dart';
import 'package:mobile_app/features/leaderboard/data/supabase_leaderboard_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockApiService extends Mock implements ApiService {}

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _MockGoTrueClient extends Mock implements GoTrueClient {}

void main() {
  group('SupabaseLeaderboardRepository.fetchTop', () {
    late ApiService api;
    late SupabaseClient sb;

    setUp(() {
      api = _MockApiService();
      sb = _MockSupabaseClient();
    });

    test('maps rows and applies order/limit', () async {
      final rows = <Map<String, dynamic>>[
        {
          'rank': 1,
          'display_name': 'Alice',
          'avatar_url': null,
          'level': 5,
          'league_name': 'gold',
          'season_exp': 1234,
          'total_exp': 5432,
        },
        {
          'rank': 2,
          'display_name': 'Bob',
          'avatar_url': 'https://x/y.png',
          'level': 4,
          'league_name': 'silver',
          'season_exp': 987,
          'total_exp': 3210,
        },
      ];

      when(
        () => api.query(
          table: 'leaderboard_v',
          select: any(named: 'select'),
          orderBy: 'rank',
          limit: 10,
        ),
      ).thenAnswer((_) async => rows);

      final repo = SupabaseLeaderboardRepository(api, sb);

      final out = await repo.fetchTop(limit: 10);

      expect(out, hasLength(2));

      expect(out.first.rank, 1);
      expect(out.first.displayName, 'Alice');
      expect(out.first.avatarUrl, isNull);
      expect(out.first.level, 5);
      expect(out.first.leagueName, 'gold');
      expect(out.first.seasonExp, 1234);
      expect(out.first.totalExp, 5432);

      expect(out.last.rank, 2);
      expect(out.last.displayName, 'Bob');
      expect(out.last.avatarUrl, 'https://x/y.png');
      expect(out.last.level, 4);
      expect(out.last.leagueName, 'silver');
      expect(out.last.seasonExp, 987);
      expect(out.last.totalExp, 3210);

      verify(
        () => api.query(
          table: 'leaderboard_v',
          select: any(named: 'select'),
          orderBy: 'rank',
          limit: 10,
        ),
      ).called(1);
    });
  });

  group('SupabaseLeaderboardRepository.fetchUserStats', () {
    late ApiService api;
    late SupabaseClient sb;
    late GoTrueClient auth;

    setUp(() {
      api = _MockApiService();
      sb = _MockSupabaseClient();
      auth = _MockGoTrueClient();

      when(() => sb.auth).thenReturn(auth);
    });

    test('throws when session is null', () async {
      when(() => auth.currentSession).thenReturn(null);

      final repo = SupabaseLeaderboardRepository(api, sb);

      expect(repo.fetchUserStats(), throwsA(isA<StateError>()));

      verify(() => auth.currentSession).called(1);
      verifyNever(
        () => api.query(
          table: any(named: 'table'),
          select: any(named: 'select'),
        ),
      );
    });

    test('returns stats when session exists and rows present', () async {
      final session = Session(
        accessToken: 't',
        tokenType: 'bearer',
        user: User(
          id: 'u1',
          appMetadata: const {},
          userMetadata: const {},
          aud: 'authenticated',
          createdAt: DateTime.now().toIso8601String(),
        ),
      );

      when(() => auth.currentSession).thenReturn(session);

      // user_global_progress
      when(
        () => api.query(
          table: 'user_global_progress',
          select: 'total_exp',
          filters: {'user_id': 'u1'},
          limit: 1,
        ),
      ).thenAnswer(
        (_) async => <Map<String, dynamic>>[
          {'total_exp': 2500},
        ],
      );

      // user_season_progress
      when(
        () => api.query(
          table: 'user_season_progress',
          select: 'season_exp',
          filters: {'user_id': 'u1'},
          orderBy: 'season_exp',
          ascending: false,
          limit: 1,
        ),
      ).thenAnswer(
        (_) async => <Map<String, dynamic>>[
          {'season_exp': 700},
        ],
      );

      final repo = SupabaseLeaderboardRepository(api, sb);
      final stats = await repo.fetchUserStats();

      expect(stats.totalExp, 2500);
      expect(stats.seasonExp, 700);
      expect(stats.level, 3); // 2500 ~/ 1000 + 1 = 3

      verify(() => auth.currentSession).called(1);

      verify(
        () => api.query(
          table: 'user_global_progress',
          select: 'total_exp',
          filters: {'user_id': 'u1'},
          limit: 1,
        ),
      ).called(1);

      verify(
        () => api.query(
          table: 'user_season_progress',
          select: 'season_exp',
          filters: {'user_id': 'u1'},
          orderBy: 'season_exp',
          ascending: false,
          limit: 1,
        ),
      ).called(1);
    });
  });
}
