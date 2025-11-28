import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/models/leaderboard.dart';
import 'package:mobile_app/features/leaderboard/presentation/widgets/leaderboard_list.dart';
import 'package:mobile_app/features/leaderboard/presentation/widgets/leaderboard_tile.dart';

import '../../../../helpers/test_wrap.dart';

LeaderboardEntry _entry(int rank) {
  return LeaderboardEntry(
    rank: rank,
    displayName: 'User $rank',
    avatarUrl: null,
    level: 1,
    leagueName: 'Bronze League',
    seasonExp: 0,
    totalExp: 0,
  );
}

void main() {
  testWidgets('LeaderboardList renders with empty entries', (tester) async {
    await tester.pumpWidget(wrap(const LeaderboardList(entries: [])));
    await tester.pump(const Duration(milliseconds: 20));

    expect(find.byType(LeaderboardList), findsOneWidget);
    expect(find.text('No data'), findsOneWidget);
  });

  testWidgets(
    'LeaderboardList renders top3 and others when more than 3 entries',
    (tester) async {
      final entries = List.generate(5, (i) => _entry(i + 1));

      await tester.pumpWidget(wrap(LeaderboardList(entries: entries)));
      await tester.pump(const Duration(milliseconds: 20));

      expect(find.byType(LeaderboardTile), findsNWidgets(5));

      expect(find.text('1. User 1'), findsOneWidget);
      expect(find.text('4. User 4'), findsOneWidget);

      expect(find.byType(ListView), findsNWidgets(2));
    },
  );
}
