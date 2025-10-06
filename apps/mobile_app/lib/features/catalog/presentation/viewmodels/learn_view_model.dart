import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/models/course.dart';
import 'package:mobile_app/core/models/lesson.dart';
import 'package:mobile_app/core/models/track.dart';
import 'package:mobile_app/features/catalog/data/course_repository.dart';

final courseRepositoryProvider = Provider<CourseRepository>(
  (ref) => CourseRepository(),
);

final coursesProvider = FutureProvider<List<Course>>((ref) async {
  final repo = ref.watch(courseRepositoryProvider);
  return repo.getCourses();
});

final tracksProvider = FutureProvider<List<Track>>((ref) async {
  final repo = ref.watch(courseRepositoryProvider);
  return repo.getTracks();
});

final lessonsProvider =
    FutureProvider.family<List<Lesson>, TrackId>((ref, id) async {
  final repo = ref.watch(courseRepositoryProvider);
  return repo.getLessons(id);
});
