import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/models/course.dart';
import 'package:mobile_app/core/models/lesson.dart';
import 'package:mobile_app/features/catalog/data/course_repository.dart';

final courseRepositoryProvider = Provider<CourseRepository>(
  (ref) => CourseRepository(),
);

final coursesProvider = FutureProvider.autoDispose<List<Course>>((ref) async {
  final repo = ref.read(courseRepositoryProvider);
  return repo.getCourses();
});

final lessonsByCourseProvider = FutureProvider.family
    .autoDispose<List<Lesson>, String>((ref, courseId) async {
      final repo = ref.read(courseRepositoryProvider);
      return repo.getLessonsByCourseId(courseId);
    });
