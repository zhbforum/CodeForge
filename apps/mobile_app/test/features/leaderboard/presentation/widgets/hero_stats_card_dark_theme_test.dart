import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/models/leaderboard.dart';
import 'package:mobile_app/features/leaderboard/presentation/widgets/hero_stats_card.dart';

import '../../../../helpers/test_wrap.dart';

void main() {
  group('HeroStatsCard – dark theme', () {
    testWidgets('hits dark color branches', (tester) async {
      const stats = UserStats(totalExp: 1420, seasonExp: 420, level: 5);

      await tester.pumpWidget(
        wrap(
          Theme(
            data: ThemeData.from(colorScheme: const ColorScheme.dark()),
            child: const HeroStatsCard(stats: stats),
          ),
        ),
      );

      expect(find.text('Your Level'), findsOneWidget);
      expect(find.text('lvl'), findsOneWidget);

      expect(find.textContaining('Global XP'), findsOneWidget);
      expect(find.textContaining('Season XP'), findsOneWidget);

      expect(find.text('420 / 1000'), findsOneWidget);
    });
  });
}
