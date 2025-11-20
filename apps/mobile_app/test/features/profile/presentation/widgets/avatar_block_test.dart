import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/profile/presentation/widgets/avatar_block.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AvatarBlock', () {
    testWidgets('applies border when showBorder is true', (tester) async {
      var editCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AvatarBlock(
                seed: 'test-seed',
                showBorder: true,
                onEditAvatar: () {
                  editCalled = true;
                },
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      final decoratedBoxes = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .toList();
      expect(decoratedBoxes, isNotEmpty);

      final decoratedBox = decoratedBoxes.firstWhere((box) {
        final decoration = box.decoration;
        return decoration is BoxDecoration && decoration.border != null;
      });

      final decoration = decoratedBox.decoration as BoxDecoration;

      expect(decoration.shape, BoxShape.circle);
      expect(decoration.border, isNotNull);

      final editButton = find.byTooltip('Edit avatar');
      expect(editButton, findsOneWidget);

      await tester.tap(editButton);
      await tester.pump();

      expect(editCalled, isTrue);
    });
  });
}
