import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/leaderboard/data/supabase_leaderboard_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

typedef RowMap = Map<String, dynamic>;
typedef Rows = List<RowMap>;

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _MockGoTrueClient extends Mock implements GoTrueClient {}

class _MockFrom extends Mock implements SupabaseQueryBuilder {}

class _MockFilterList extends Mock implements PostgrestFilterBuilder<Rows> {}

class _MockTransformList extends Mock
    implements PostgrestTransformBuilder<Rows> {}

class _MockTransformMap extends Mock
    implements PostgrestTransformBuilder<RowMap?> {}

Future<dynamic> _resolveRows(Invocation inv, Rows value) {
  final cb = inv.positionalArguments.first as FutureOr<dynamic> Function(Rows);
  return Future.sync(() => cb(value));
}

Future<dynamic> _resolveMap(Invocation inv, RowMap? value) {
  final cb =
      inv.positionalArguments.first as FutureOr<dynamic> Function(RowMap?);
  return Future.sync(() => cb(value));
}

void main() {
  group('SupabaseLeaderboardRepository.fetchTop', () {
    late SupabaseClient sb;
    late SupabaseQueryBuilder fromLeaderboardV;
    late PostgrestFilterBuilder<Rows> afterSelect;
    late PostgrestTransformBuilder<Rows> afterOrder;

    setUp(() {
      sb = _MockSupabaseClient();
      fromLeaderboardV = _MockFrom();
      afterSelect = _MockFilterList();
      afterOrder = _MockTransformList();

      when(() => sb.from('leaderboard_v')).thenAnswer((_) => fromLeaderboardV);
      when(
        () => fromLeaderboardV.select(any<String>()),
      ).thenAnswer((_) => afterSelect);
      when(
        () => afterSelect.order('rank', ascending: true, nullsFirst: false),
      ).thenAnswer((_) => afterOrder);
      when(
        () => afterOrder.limit(any<int>(), referencedTable: null),
      ).thenAnswer((_) => afterOrder);
    });

    test('maps rows and applies order/limit', () async {
      final rows = <RowMap>[
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

      when<dynamic>(
        () => afterOrder.then<dynamic>(any()),
      ).thenAnswer((inv) => _resolveRows(inv, rows));

      when<dynamic>(
        () => afterOrder.then<dynamic>(any(), onError: any(named: 'onError')),
      ).thenAnswer((inv) => _resolveRows(inv, rows));

      final repo = SupabaseLeaderboardRepository(sb);
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

      verify(() => sb.from('leaderboard_v')).called(1);
      verify(() => fromLeaderboardV.select(any<String>())).called(1);
      verify(
        () => afterSelect.order('rank', ascending: true, nullsFirst: false),
      ).called(1);
      verify(() => afterOrder.limit(10, referencedTable: null)).called(1);
    });
  });

  group('SupabaseLeaderboardRepository.fetchUserStats', () {
    late SupabaseClient sb;
    late GoTrueClient auth;

    late SupabaseQueryBuilder fromUgp;
    late SupabaseQueryBuilder fromUsp;

    late PostgrestFilterBuilder<Rows> ugpFilter;
    late PostgrestTransformBuilder<RowMap?> ugpSingle;

    late PostgrestFilterBuilder<Rows> uspFilter;
    late PostgrestTransformBuilder<Rows> uspTransformList;
    late PostgrestTransformBuilder<RowMap?> uspSingle;

    setUp(() {
      sb = _MockSupabaseClient();
      auth = _MockGoTrueClient();

      fromUgp = _MockFrom();
      fromUsp = _MockFrom();

      ugpFilter = _MockFilterList();
      ugpSingle = _MockTransformMap();

      uspFilter = _MockFilterList();
      uspTransformList = _MockTransformList();
      uspSingle = _MockTransformMap();

      when(() => sb.auth).thenAnswer((_) => auth);
    });

    test('throws when session is null', () async {
      when(() => auth.currentSession).thenAnswer((_) => null);

      final repo = SupabaseLeaderboardRepository(sb);
      expect(repo.fetchUserStats(), throwsA(isA<StateError>()));
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

      when(() => auth.currentSession).thenAnswer((_) => session);

      when(() => sb.from('user_global_progress')).thenAnswer((_) => fromUgp);
      when(() => fromUgp.select('total_exp')).thenAnswer((_) => ugpFilter);
      when(() => ugpFilter.eq('user_id', 'u1')).thenAnswer((_) => ugpFilter);
      when(() => ugpFilter.maybeSingle()).thenAnswer((_) => ugpSingle);

      when<dynamic>(() => ugpSingle.then<dynamic>(any())).thenAnswer(
        (inv) => _resolveMap(inv, <String, dynamic>{'total_exp': 2500}),
      );
      when<dynamic>(
        () => ugpSingle.then<dynamic>(any(), onError: any(named: 'onError')),
      ).thenAnswer(
        (inv) => _resolveMap(inv, <String, dynamic>{'total_exp': 2500}),
      );

      when(() => sb.from('user_season_progress')).thenAnswer((_) => fromUsp);
      when(() => fromUsp.select('season_exp')).thenAnswer((_) => uspFilter);
      when(() => uspFilter.eq('user_id', 'u1')).thenAnswer((_) => uspFilter);
      when(
        () =>
            uspFilter.order('season_exp', ascending: false, nullsFirst: false),
      ).thenAnswer((_) => uspTransformList);
      when(
        () => uspTransformList.limit(1, referencedTable: null),
      ).thenAnswer((_) => uspTransformList);
      when(() => uspTransformList.maybeSingle()).thenAnswer((_) => uspSingle);

      when<dynamic>(() => uspSingle.then<dynamic>(any())).thenAnswer(
        (inv) => _resolveMap(inv, <String, dynamic>{'season_exp': 700}),
      );
      when<dynamic>(
        () => uspSingle.then<dynamic>(any(), onError: any(named: 'onError')),
      ).thenAnswer(
        (inv) => _resolveMap(inv, <String, dynamic>{'season_exp': 700}),
      );

      final repo = SupabaseLeaderboardRepository(sb);
      final stats = await repo.fetchUserStats();

      expect(stats.totalExp, 2500);
      expect(stats.seasonExp, 700);
      expect(stats.level, 3);
    });
  });
}
