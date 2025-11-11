import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/practice/practice_page.dart';

void main() {
  group('PracticePage', () {
    testWidgets('renders AppBar title and body text', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: PracticePage()));

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Practice'), findsOneWidget);
      expect(find.text('Exerices and timers'), findsOneWidget);
    });
  });
}
