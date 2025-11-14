import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/models/leaderboard.dart';
import 'package:mobile_app/features/leaderboard/leaderboard_page.dart';
import 'package:mobile_app/features/leaderboard/presentation/viewmodels/leaderboard_providers.dart';
import 'package:mobile_app/features/leaderboard/presentation/widgets/hero_stats_card.dart';
import 'package:mobile_app/features/leaderboard/presentation/widgets/leaderboard_list.dart';
import 'package:mobile_app/features/leaderboard/presentation/widgets/podium_top3.dart';

void main() {
  group('LeaderboardPage', () {
    UserStats makeUserStats() {
      return const UserStats(totalExp: 1234, seasonExp: 500, level: 5);
    }

    LeaderboardEntry makeEntry(int i) {
      return LeaderboardEntry(
        rank: i + 1,
        displayName: 'User $i',
        avatarUrl: '',
        level: 5,
        leagueName: 'Gold',
        seasonExp: 500 - i * 5,
        totalExp: 1000 - i * 10,
      );
    }

    Future<void> pumpWithOverrides(
      WidgetTester tester, {
      required Future<UserStats> Function(Ref ref) userStatsOverride,
      required Future<List<LeaderboardEntry>> Function(Ref ref)
      leaderboardOverride,
    }) {
      return tester.pumpWidget(
        ProviderScope(
          overrides: [
            userStatsProvider.overrideWith((ref) => userStatsOverride(ref)),
            topLeaderboardProvider.overrideWith(
              (ref) => leaderboardOverride(ref),
            ),
          ],
          child: const MaterialApp(home: LeaderboardPage()),
        ),
      );
    }

    testWidgets('renders HeroStatsCard and splits top3/others', (tester) async {
      final stats = makeUserStats();
      final entries = List.generate(5, makeEntry);

      await pumpWithOverrides(
        tester,
        userStatsOverride: (ref) async => stats,
        leaderboardOverride: (ref) async => entries,
      );

      await tester.pumpAndSettle();

      expect(find.byType(HeroStatsCard), findsOneWidget);
      expect(find.byType(PodiumTop3), findsOneWidget);
      expect(find.byType(LeaderboardList), findsOneWidget);
    });

    testWidgets('refresh button triggers _refresh', (tester) async {
      var statsBuilds = 0;
      var leaderboardBuilds = 0;

      final stats = makeUserStats();
      final entries = List.generate(4, makeEntry);

      await pumpWithOverrides(
        tester,
        userStatsOverride: (ref) async {
          statsBuilds++;
          return stats;
        },
        leaderboardOverride: (ref) async {
          leaderboardBuilds++;
          return entries;
        },
      );

      await tester.pumpAndSettle();

      final refreshButton = find.byIcon(Icons.refresh);
      expect(refreshButton, findsOneWidget);

      await tester.tap(refreshButton);
      await tester.pumpAndSettle();

      expect(statsBuilds, greaterThan(1));
      expect(leaderboardBuilds, greaterThan(1));
    });

    testWidgets('pull-to-refresh triggers _refresh via RefreshIndicator', (
      tester,
    ) async {
      var statsBuilds = 0;
      var leaderboardBuilds = 0;

      final stats = makeUserStats();
      final entries = List.generate(6, makeEntry);

      await pumpWithOverrides(
        tester,
        userStatsOverride: (ref) async {
          statsBuilds++;
          return stats;
        },
        leaderboardOverride: (ref) async {
          leaderboardBuilds++;
          return entries;
        },
      );

      await tester.pumpAndSettle();

      final refreshIndicator = find.byType(RefreshIndicator);
      expect(refreshIndicator, findsOneWidget);

      await tester.drag(refreshIndicator, const Offset(0, 300));
      await tester.pumpAndSettle();

      expect(statsBuilds, greaterThan(1));
      expect(leaderboardBuilds, greaterThan(1));
    });
  });
}
