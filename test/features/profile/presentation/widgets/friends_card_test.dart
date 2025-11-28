import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/profile/presentation/widgets/friends_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FriendsCard', () {
    testWidgets('uses dark theme color and handles Add Friends tap', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
          ),
          home: const Scaffold(body: Center(child: FriendsCard())),
        ),
      );

      await tester.pump();

      expect(find.byType(Card), findsOneWidget);

      final addFriendsText = find.text('Add Friends');
      expect(addFriendsText, findsOneWidget);

      await tester.tap(addFriendsText);
      await tester.pump();
    });
  });
}
