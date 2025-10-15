import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/models/course.dart';
import 'package:mobile_app/core/models/course_node.dart';
import 'package:mobile_app/core/models/lesson.dart';
import 'package:mobile_app/features/catalog/data/course_repository.dart';

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
      final lessons = await repo.getLessonsByCourseId(courseId);

      NodeStatus map(LessonStatus s) => switch (s) {
        LessonStatus.completed => NodeStatus.done,
        LessonStatus.inProgress => NodeStatus.available,
        LessonStatus.locked => NodeStatus.locked,
      };

      NodeType toNodeType(LessonType t) {
        try {
          return NodeType.values.byName(t.name);
        } catch (_) {
          return NodeType.lesson;
        }
      }

      return [
        for (final l in lessons)
          CourseNode(
            id: l.id,
            title: l.title,
            type: toNodeType(l.type),
            status: map(l.status),
            progress: l.status == LessonStatus.completed ? 100 : 0,
            order: l.order,
          ),
      ];
    });
