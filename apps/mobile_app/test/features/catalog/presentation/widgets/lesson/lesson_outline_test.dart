import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/models/course_node.dart';
import 'package:mobile_app/features/catalog/presentation/widgets/lesson_outline.dart';

import '../../../../../helpers/test_wrap.dart';

void main() {
  group('LessonOutline', () {
    testWidgets('filters nodes by query and calls onTap for tapped node', (
      tester,
    ) async {
      final nodes = <CourseNode>[
        const CourseNode(
          id: 'intro-1',
          title: 'Intro to Dart',
          type: NodeType.lesson,
          status: NodeStatus.available,
        ),
        const CourseNode(
          id: 'flutter-2',
          title: 'Flutter widgets',
          type: NodeType.lesson,
          status: NodeStatus.done,
        ),
        const CourseNode(
          id: 'python-3',
          title: 'Python basics',
          type: NodeType.lesson,
          status: NodeStatus.available,
        ),
      ];

      CourseNode? tapped;

      await tester.pumpWidget(
        wrap(LessonOutline(nodes: nodes, onTap: (n) => tapped = n)),
      );

      expect(find.text('Intro to Dart'), findsOneWidget);
      expect(find.text('Flutter widgets'), findsOneWidget);
      expect(find.text('Python basics'), findsOneWidget);

      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      await tester.enterText(searchField, 'python');
      await tester.pumpAndSettle();

      expect(find.text('Python basics'), findsOneWidget);
      expect(find.text('Intro to Dart'), findsNothing);
      expect(find.text('Flutter widgets'), findsNothing);

      await tester.tap(find.text('Python basics'));
      await tester.pump();

      expect(tapped, isNotNull);
      expect(tapped!.id, 'python-3');
      expect(tapped!.title, 'Python basics');
    });
  });
}
