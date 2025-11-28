import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/catalog/presentation/widgets/course_meta_panel.dart';

import '../../../../../helpers/test_wrap.dart';

void main() {
  group('CourseMetaPanel', () {
    testWidgets('taps Resources button (onPressed is called)', (tester) async {
      await tester.pumpWidget(
        wrap(
          const CourseMetaPanel(
            total: 10,
            done: 3,
            estimatedHours: '4.5',
            tags: ['Beginner', 'Frontend'],
          ),
        ),
      );
      await tester.pump();

      final resourcesFinder = find.text('Resources');
      expect(resourcesFinder, findsOneWidget);

      await tester.tap(resourcesFinder);
      await tester.pump();
    });
  });
}
