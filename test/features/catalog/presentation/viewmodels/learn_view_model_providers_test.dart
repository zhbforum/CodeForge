import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/models/course.dart';
import 'package:mobile_app/core/models/lesson.dart';
import 'package:mobile_app/core/models/track.dart';
import 'package:mobile_app/features/catalog/data/course_repository.dart';
import 'package:mobile_app/features/catalog/presentation/viewmodels/learn_view_model.dart';

class _FakeCourseRepository implements CourseRepository {
  bool getCoursesCalled = false;
  bool getLessonsCalled = false;
  String? lastCourseId;

  @override
  Future<List<Course>> getCourses() async {
    getCoursesCalled = true;
    return <Course>[];
  }

  @override
  Future<Course> getCourse(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<List<Lesson>> getLessonsByCourseId(String courseId) async {
    getLessonsCalled = true;
    lastCourseId = courseId;
    return <Lesson>[];
  }

  @override
  Future<void> markLessonDone({
    required String courseId,
    required String lessonId,
  }) async {}

  @override
  Future<List<Track>> getTracks() async {
    return <Track>[];
  }

  @override
  Future<List<Lesson>> getLessons(TrackId id) async {
    return <Lesson>[];
  }
}

void main() {
  group('learn view model providers', () {
    test('coursesProvider uses courseRepository.getCourses()', () async {
      final fakeRepo = _FakeCourseRepository();

      final container = ProviderContainer(
        overrides: [courseRepositoryProvider.overrideWithValue(fakeRepo)],
      );
      addTearDown(container.dispose);

      final result = await container.read(coursesProvider.future);

      expect(fakeRepo.getCoursesCalled, isTrue);
      expect(result, isA<List<Course>>());
      expect(result, isEmpty);
    });

    test(
      'lessonsByCourseProvider uses courseRepository.getLessonsByCourseId()',
      () async {
        final fakeRepo = _FakeCourseRepository();

        final container = ProviderContainer(
          overrides: [courseRepositoryProvider.overrideWithValue(fakeRepo)],
        );
        addTearDown(container.dispose);

        const courseId = 'course_123';

        final result = await container.read(
          lessonsByCourseProvider(courseId).future,
        );

        expect(fakeRepo.getLessonsCalled, isTrue);
        expect(fakeRepo.lastCourseId, courseId);
        expect(result, isA<List<Lesson>>());
        expect(result, isEmpty);
      },
    );
  });
}
