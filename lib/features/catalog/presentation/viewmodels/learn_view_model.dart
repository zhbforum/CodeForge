import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/models/course.dart';
import 'package:mobile_app/core/models/lesson.dart';
import 'package:mobile_app/core/services/api_service_provider.dart';
import 'package:mobile_app/features/catalog/data/course_repository.dart';
import 'package:mobile_app/features/catalog/data/progress_store.dart';

final courseRepositoryProvider = Provider<CourseRepository>((ref) {
  final api = ref.read(apiServiceProvider);
  final errorHandler = ref.read(errorHandlerProvider);

  return CourseRepository(api: api, errorHandler: errorHandler);
});

final coursesProvider = FutureProvider.autoDispose<List<Course>>((ref) async {
  final repo = ref.read(courseRepositoryProvider);
  return repo.getCourses();
});

final lessonsByCourseProvider = FutureProvider.family
    .autoDispose<List<Lesson>, String>((ref, courseId) async {
      final repo = ref.read(courseRepositoryProvider);
      return repo.getLessonsByCourseId(courseId);
    });

class CourseProgressSummary {
  const CourseProgressSummary({
    required this.completedLessons,
    required this.totalLessons,
  });

  final int completedLessons;
  final int totalLessons;

  double get progress =>
      totalLessons == 0 ? 0.0 : completedLessons / totalLessons;
}

final courseProgressSummaryProvider = FutureProvider.family
    .autoDispose<CourseProgressSummary, String>((ref, courseId) async {
      ref.watch(progressVersionProvider);

      final lessons = await ref.watch(lessonsByCourseProvider(courseId).future);
      final totalLessons = lessons.length;

      final progressStore = ref.read(progressStoreProvider);
      final completionMap = await progressStore.getLessonCompletion(courseId);
      final completedLessons = completionMap.values
          .where((v) => v == true)
          .length;

      return CourseProgressSummary(
        completedLessons: completedLessons.clamp(0, totalLessons),
        totalLessons: totalLessons,
      );
    });
