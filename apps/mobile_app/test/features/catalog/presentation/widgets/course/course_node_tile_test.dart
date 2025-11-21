import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/models/course_node.dart';
import 'package:mobile_app/features/catalog/presentation/widgets/course_node_tile.dart';

import '../../../../../helpers/test_wrap.dart';

void main() {
  group('CourseNodeTile', () {
    testWidgets('shows progress badge when node.progress > 0', (tester) async {
      const node = CourseNode(
        id: 'node-1',
        title: 'Practice 1',
        type: NodeType.practice,
        status: NodeStatus.available,
        progress: 45,
      );

      await tester.pumpWidget(wrap(CourseNodeTile(node: node, onTap: () {})));

      expect(find.byIcon(Icons.bolt), findsOneWidget);

      expect(find.text('45%'), findsOneWidget);
    });

    testWidgets(
      'updates pulse animation when pulsePeriod and isActive change',
      (tester) async {
        const node = CourseNode(
          id: 'node-2',
          title: 'Active lesson',
          type: NodeType.lesson,
          status: NodeStatus.available,
        );

        const key = ValueKey('course-node-tile');

        await tester.pumpWidget(
          wrap(
            CourseNodeTile(key: key, node: node, onTap: () {}, isActive: true),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));

        await tester.pumpWidget(
          wrap(
            CourseNodeTile(
              key: key,
              node: node,
              onTap: () {},
              isActive: true,
              pulsePeriod: const Duration(milliseconds: 1500),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));

        await tester.pumpWidget(
          wrap(
            CourseNodeTile(
              key: key,
              node: node,
              onTap: () {},
              pulsePeriod: const Duration(milliseconds: 1500),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));

        await tester.pumpWidget(
          wrap(
            CourseNodeTile(
              key: key,
              node: node,
              onTap: () {},
              isActive: true,
              pulsePeriod: const Duration(milliseconds: 1500),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byKey(key), findsOneWidget);
      },
    );
  });
}
