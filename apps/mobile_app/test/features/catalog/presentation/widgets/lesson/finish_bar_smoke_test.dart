import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/catalog/presentation/widgets/lesson/finish_bar.dart';
import '../../../../../helpers/test_wrap.dart';

void main() {
  testWidgets('FinishBar shows completed state', (tester) async {
    await tester.pumpWidget(wrap(const FinishBar(isCompleted: true)));
    await tester.pump(const Duration(milliseconds: 20));

    expect(find.byType(FinishBar), findsOneWidget);
    expect(find.text('Lesson is completed'), findsOneWidget);
    expect(find.text('Finish lesson'), findsNothing);
  });

  testWidgets('FinishBar calls onFinish when not completed', (tester) async {
    var called = false;

    await tester.pumpWidget(
      wrap(FinishBar(isCompleted: false, onFinish: () => called = true)),
    );

    await tester.tap(find.text('Finish lesson'));
    await tester.pump();

    expect(called, isTrue);
  });
}
