import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/profile/presentation/widgets/list_block.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ListBlock', () {
    testWidgets('uses surfaceContainerHighest in dark theme', (tester) async {
      const items = [
        ListItem(title: 'Item 1'),
        ListItem(title: 'Item 2', isLast: true),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
          ),
          home: const Scaffold(
            body: Center(child: ListBlock(items: items)),
          ),
        ),
      );

      await tester.pump();

      final cardFinder = find.byType(Card);
      expect(cardFinder, findsOneWidget);

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
    });
  });
}
