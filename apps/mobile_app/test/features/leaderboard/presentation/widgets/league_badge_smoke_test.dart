import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/leaderboard/presentation/widgets/league_badge.dart';

import '../../../../helpers/test_wrap.dart';

void main() {
  group('LeagueBadge', () {
    testWidgets('renders with given league name', (tester) async {
      await tester.pumpWidget(wrap(const LeagueBadge('Bronze')));
      await tester.pump(const Duration(milliseconds: 20));

      expect(find.byType(LeagueBadge), findsOneWidget);
      expect(find.text('Bronze'), findsOneWidget);
    });

    testWidgets('uses bronze / silver / gold palette branches', (tester) async {
      await tester.pumpWidget(
        wrap(
          const Column(
            children: [
              LeagueBadge('Bronze League'),
              LeagueBadge('Silver League'),
              LeagueBadge('Gold League'),
            ],
          ),
        ),
      );

      expect(find.text('Bronze League'), findsOneWidget);
      expect(find.text('Silver League'), findsOneWidget);
      expect(find.text('Gold League'), findsOneWidget);
    });

    testWidgets('uses platinum and diamond palette branches', (tester) async {
      await tester.pumpWidget(
        wrap(
          const Column(
            children: [
              LeagueBadge('Platinum League'),
              LeagueBadge('Diamond League'),
            ],
          ),
        ),
      );

      expect(find.text('Platinum League'), findsOneWidget);
      expect(find.text('Diamond League'), findsOneWidget);
    });

    testWidgets(
      'falls back to theme primary color and uses dark background alpha',
      (tester) async {
        const primary = Colors.purple;

        final darkScheme = ColorScheme.fromSeed(
          seedColor: primary,
          primary: primary,
          brightness: Brightness.dark,
        );

        final darkTheme = ThemeData.from(colorScheme: darkScheme);

        await tester.pumpWidget(
          MaterialApp(
            theme: darkTheme,
            home: const Scaffold(body: LeagueBadge('Custom League')),
          ),
        );

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(LeagueBadge),
            matching: find.byType(Container),
          ),
        );

        final decoration = container.decoration! as BoxDecoration;
        final border = decoration.border! as Border;

        expect(decoration.color, primary.withValues(alpha: .20));
        expect(border.top.color, primary.withValues(alpha: .45));
      },
    );
  });
}
