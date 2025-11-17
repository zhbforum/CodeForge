import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/models/leaderboard.dart';
import 'package:mobile_app/features/leaderboard/data/leaderboard_repository_provider.dart';
import 'package:mobile_app/features/leaderboard/domain/leaderboard_repository.dart';
import 'package:mobile_app/features/leaderboard/presentation/viewmodels/leaderboard_providers.dart';
import 'package:mocktail/mocktail.dart';

class _MockLeaderboardRepository extends Mock
    implements LeaderboardRepository {}

class _FakeUserStats extends Mock implements UserStats {}

class _FakeLeaderboardEntry extends Mock implements LeaderboardEntry {}

void main() {
  group('leaderboard_providers.dart', () {
    test('userStatsProvider reads repo and returns UserStats', () async {
      final repo = _MockLeaderboardRepository();
      final fakeStats = _FakeUserStats();

      when(repo.fetchUserStats).thenAnswer((_) async => fakeStats);

      final container = ProviderContainer(
        overrides: [leaderboardRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      final result = await container.read(userStatsProvider.future);

      expect(result, equals(fakeStats));
      verify(repo.fetchUserStats).called(1);
    });

    test('topLeaderboardProvider reads repo and returns list', () async {
      final repo = _MockLeaderboardRepository();
      final e1 = _FakeLeaderboardEntry();
      final e2 = _FakeLeaderboardEntry();

      when(repo.fetchTop).thenAnswer((_) async => [e1, e2]);

      final container = ProviderContainer(
        overrides: [leaderboardRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      final result = await container.read(topLeaderboardProvider.future);

      expect(result, hasLength(2));
      expect(result.first, equals(e1));
      expect(result.last, equals(e2));
      verify(repo.fetchTop).called(1);
    });

    test('userStatsProvider propagates repository error', () async {
      final repo = _MockLeaderboardRepository();

      when(repo.fetchUserStats).thenThrow(Exception('boom'));

      final container = ProviderContainer(
        overrides: [leaderboardRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      expect(
        () => container.read(userStatsProvider.future),
        throwsA(isA<Exception>()),
      );
      verify(repo.fetchUserStats).called(1);
    });

    test('topLeaderboardProvider propagates repository error', () async {
      final repo = _MockLeaderboardRepository();

      when(repo.fetchTop).thenThrow(Exception('boom'));

      final container = ProviderContainer(
        overrides: [leaderboardRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      expect(
        () => container.read(topLeaderboardProvider.future),
        throwsA(isA<Exception>()),
      );
      verify(repo.fetchTop).called(1);
    });

    test('autoDispose: second read calls repo again', () async {
      final repo = _MockLeaderboardRepository();
      final e = _FakeLeaderboardEntry();

      when(repo.fetchTop).thenAnswer((_) async => [e]);

      final container = ProviderContainer(
        overrides: [leaderboardRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      final first = await container.read(topLeaderboardProvider.future);
      expect(first, isNotEmpty);

      container.refresh(topLeaderboardProvider);

      final second = await container.read(topLeaderboardProvider.future);
      expect(second, isNotEmpty);

      verify(repo.fetchTop).called(2);
    });
  });
}
