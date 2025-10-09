import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/models/course.dart';
import 'package:mobile_app/core/models/course_node.dart';
import 'package:mobile_app/core/models/lesson.dart';
import 'package:mobile_app/features/catalog/data/course_repository.dart';
import 'package:mobile_app/features/catalog/data/progress_store.dart';

final courseRepositoryProvider = Provider<CourseRepository>(
  (ref) => CourseRepository(),
);

final courseProvider = FutureProvider.family.autoDispose<Course, String>((
  ref,
  id,
) async {
  final repo = ref.read(courseRepositoryProvider);
  return repo.getCourse(id);
});

final coursePathProvider = FutureProvider.family
    .autoDispose<List<CourseNode>, String>((ref, courseId) async {
      final repo = ref.read(courseRepositoryProvider);
      final store = ref.read(progressStoreProvider);
      final lessons = await repo.getLessonsByCourseId(courseId);
      final done = await store.getLessonCompletion(courseId);

      final nodes = <CourseNode>[];
      var madeAvailable = false;

      for (var i = 0; i < lessons.length; i++) {
        final l = lessons[i];
        final isCompleted = done[l.id] ?? false;
        final prevCompleted = i == 0 || (done[lessons[i - 1].id] ?? false);

        final status = isCompleted
            ? NodeStatus.locked
            : (!madeAvailable && prevCompleted)
            ? (madeAvailable = true, NodeStatus.available).$2
            : NodeStatus.locked;

        nodes.add(
          CourseNode(
            id: l.id,
            title: l.title,
            status: status,
            type: _toNodeType(l.type),
          ),
        );
      }

      return nodes;
    });

NodeType _toNodeType(LessonType t) {
  try {
    return NodeType.values.byName(t.name);
  } catch (_) {
    return NodeType.values.first;
  }
}
