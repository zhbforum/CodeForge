import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/models/course_node.dart';

final coursePathProvider =
    NotifierProvider<CoursePathController, List<CourseNode>>(
      CoursePathController.new,
    );

class CoursePathController extends Notifier<List<CourseNode>> {
  @override
  List<CourseNode> build() {
    return [
      const CourseNode(
        id: 'intro',
        title: 'Intro',
        type: NodeType.lesson,
        status: NodeStatus.available,
      ),
      const CourseNode(
        id: 'practice-1',
        title: 'Practice 1',
        type: NodeType.practice,
        prerequisites: ['intro'],
        order: 1,
      ),
      const CourseNode(
        id: 'quiz-1',
        title: 'Quiz 1',
        type: NodeType.quiz,
        prerequisites: ['practice-1'],
        order: 2,
      ),
      const CourseNode(
        id: 'practice-2',
        title: 'Practice 2',
        type: NodeType.practice,
        prerequisites: ['quiz-1'],
        order: 3,
      ),
    ];
  }

  void markDone(String id) {
    final idx = state.indexWhere((n) => n.id == id);
    if (idx == -1) return;

    final updated = [...state];
    updated[idx] = updated[idx].copyWith(
      status: NodeStatus.done,
      progress: 100,
    );

    for (var i = idx + 1; i < updated.length; i++) {
      final node = updated[i];
      final ok = node.prerequisites.every(
        (p) => updated.any((n) => n.id == p && n.status == NodeStatus.done),
      );
      if (ok && node.status == NodeStatus.locked) {
        updated[i] = node.copyWith(status: NodeStatus.available);
        break;
      }
    }
    state = updated;
  }
}
