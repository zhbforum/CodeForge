import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_app/features/leaderboard/presentation/widgets/xp_chip.dart';

void main() {
  testWidgets('XpChip shows label and value', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: XpChip(label: 'XP', value: 123)),
        ),
      ),
    );

    expect(find.byType(XpChip), findsOneWidget);
    expect(find.text('XP: 123'), findsOneWidget);
  });

  testWidgets('XpChip updates when value changes', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: XpChip(label: 'XP', value: 10)),
        ),
      ),
    );
    expect(find.text('XP: 10'), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: XpChip(label: 'XP', value: 999)),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('XP: 999'), findsOneWidget);
    expect(find.text('XP: 10'), findsNothing);
  });
}
