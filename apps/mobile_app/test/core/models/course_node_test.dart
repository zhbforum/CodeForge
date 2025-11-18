import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/models/course_node.dart';

void main() {
  group('CourseNode', () {
    test('creates instance with default values', () {
      const node = CourseNode(
        id: 'node-1',
        title: 'Intro lesson',
        type: NodeType.lesson,
      );

      expect(node.id, 'node-1');
      expect(node.title, 'Intro lesson');
      expect(node.type, NodeType.lesson);

      expect(node.status, NodeStatus.locked);
      expect(node.progress, 0);
      expect(node.prerequisites, isEmpty);
      expect(node.order, 0);
      expect(node.moduleId, isNull);
      expect(node.moduleTitle, isNull);
      expect(node.moduleOrder, isNull);
    });

    test('copyWith returns same values when no overrides passed', () {
      const original = CourseNode(
        id: 'node-1',
        title: 'Original',
        type: NodeType.quiz,
        status: NodeStatus.available,
        progress: 50,
        prerequisites: ['n0'],
        order: 2,
        moduleId: 'm1',
        moduleTitle: 'Module 1',
        moduleOrder: 1,
      );

      final copy = original.copyWith();

      expect(copy.id, original.id);
      expect(copy.title, original.title);
      expect(copy.type, original.type);
      expect(copy.status, original.status);
      expect(copy.progress, original.progress);
      expect(copy.prerequisites, original.prerequisites);
      expect(copy.order, original.order);
      expect(copy.moduleId, original.moduleId);
      expect(copy.moduleTitle, original.moduleTitle);
      expect(copy.moduleOrder, original.moduleOrder);
    });

    test('copyWith overrides selected fields', () {
      const original = CourseNode(
        id: 'node-1',
        title: 'Original',
        type: NodeType.practice,
        prerequisites: ['n0'],
        order: 1,
        moduleId: 'm1',
        moduleTitle: 'Module 1',
        moduleOrder: 1,
      );

      final updated = original.copyWith(
        title: 'Updated title',
        status: NodeStatus.done,
        progress: 100,
        prerequisites: ['n0', 'n1'],
        order: 3,
        moduleId: 'm2',
        moduleTitle: 'Module 2',
        moduleOrder: 2,
      );

      expect(updated.id, 'node-1');
      expect(updated.title, 'Updated title');
      expect(updated.type, NodeType.practice);
      expect(updated.status, NodeStatus.done);
      expect(updated.progress, 100);
      expect(updated.prerequisites, ['n0', 'n1']);
      expect(updated.order, 3);
      expect(updated.moduleId, 'm2');
      expect(updated.moduleTitle, 'Module 2');
      expect(updated.moduleOrder, 2);
    });
  });
}
