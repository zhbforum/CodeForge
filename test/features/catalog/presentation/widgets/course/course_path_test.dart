import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/models/course_node.dart';
import 'package:mobile_app/features/catalog/presentation/widgets/course_node_tile.dart';
import 'package:mobile_app/features/catalog/presentation/widgets/course_path.dart';

import '../../../../../helpers/test_wrap.dart';

void main() {
  group('CoursePath', () {
    testWidgets('calls onNodeTap when a node tile is tapped', (tester) async {
      final nodes = <CourseNode>[
        const CourseNode(
          id: 'n1',
          title: 'Lesson 1',
          type: NodeType.lesson,
          status: NodeStatus.available,
        ),
        const CourseNode(
          id: 'n2',
          title: 'Lesson 2',
          type: NodeType.lesson,
          status: NodeStatus.available,
        ),
      ];

      CourseNode? tapped;

      await tester.pumpWidget(
        wrap(CoursePath(nodes: nodes, onNodeTap: (n) => tapped = n)),
      );
      await tester.pump();

      final tilesFinder = find.byType(CourseNodeTile);
      expect(tilesFinder, findsNWidgets(2));

      await tester.tap(tilesFinder.first);
      await tester.pump();

      expect(tapped, isNotNull);
      expect(tapped!.id, 'n1');
      expect(tapped!.title, 'Lesson 1');
    });

    testWidgets('uses dark connector color when theme is dark', (tester) async {
      final nodes = <CourseNode>[
        const CourseNode(
          id: 'n1',
          title: 'Dark Lesson',
          type: NodeType.lesson,
          status: NodeStatus.available,
        ),
      ];

      await tester.pumpWidget(
        wrap(
          Theme(
            data: ThemeData.dark(),
            child: CoursePath(nodes: nodes, onNodeTap: (_) {}),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CourseNodeTile), findsOneWidget);
    });
  });
}
