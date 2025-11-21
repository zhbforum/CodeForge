// ignore_for_file: deprecated_member_use_from_same_package
// We intentionally test deprecated API methods here.
// Suppressing warnings keeps the test output clean.

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/error/error_handler.dart';
import 'package:mobile_app/core/models/course.dart';
import 'package:mobile_app/core/models/lesson.dart';
import 'package:mobile_app/core/models/track.dart';
import 'package:mobile_app/core/services/api_service.dart';
import 'package:mobile_app/features/catalog/data/course_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockApiService extends Mock implements ApiService {}

class _MockErrorHandler extends Mock implements ErrorHandler {}

class _FakeStackTrace extends Fake implements StackTrace {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    registerFallbackValue(_FakeStackTrace());

    SharedPreferences.setMockInitialValues(<String, Object>{});

    await Supabase.initialize(
      url: 'https://example.supabase.co',
      anonKey: 'test-anon-key',
    );
  });

  group('CourseRepository.getCourses', () {
    test('returns mapped list of courses', () async {
      final api = _MockApiService();
      final handler = _MockErrorHandler();
      final repo = CourseRepository(api: api, errorHandler: handler);

      when(
        () => api.query(
          table: 'courses',
          select: 'id,title,description,cover_image,is_published,created_at',
          filters: {'is_published': true},
          orderBy: 'created_at',
        ),
      ).thenAnswer(
        (_) async => <Map<String, dynamic>>[
          {
            'id': 1,
            'title': 'Intro to Dart',
            'description': 'Basics',
            'cover_image': null,
            'is_published': true,
            'created_at': '2025-01-01T00:00:00Z',
          },
        ],
      );

      final courses = await repo.getCourses();

      expect(courses, hasLength(1));
      expect(courses.first, isA<Course>());
      expect(courses.first.title, 'Intro to Dart');

      verifyNever(() => handler.handle(any(), any<StackTrace>()));
    });

    test('forwards errors to ErrorHandler and rethrows', () async {
      final api = _MockApiService();
      final handler = _MockErrorHandler();
      final repo = CourseRepository(api: api, errorHandler: handler);

      when(
        () => api.query(
          table: 'courses',
          select: 'id,title,description,cover_image,is_published,created_at',
          filters: {'is_published': true},
          orderBy: 'created_at',
        ),
      ).thenThrow(Exception('boom'));

      await expectLater(repo.getCourses, throwsA(isA<Exception>()));

      verify(() => handler.handle(any(), any<StackTrace>())).called(1);
    });
  });

  group('CourseRepository.getCourse', () {
    test('returns first course row mapped to Course', () async {
      final api = _MockApiService();
      final handler = _MockErrorHandler();
      final repo = CourseRepository(api: api, errorHandler: handler);

      when(
        () => api.query(
          table: 'courses',
          select: 'id,title,description,cover_image,is_published,created_at',
          filters: {'id': 123},
        ),
      ).thenAnswer(
        (_) async => <Map<String, dynamic>>[
          {
            'id': 123,
            'title': 'Target course',
            'description': 'Desc',
            'cover_image': null,
            'is_published': true,
            'created_at': '2025-01-01T00:00:00Z',
          },
        ],
      );

      final course = await repo.getCourse('123');

      expect(course, isA<Course>());
      expect(course.title, 'Target course');
      verifyNever(() => handler.handle(any(), any<StackTrace>()));
    });

    test('throws when course not found and calls ErrorHandler', () async {
      final api = _MockApiService();
      final handler = _MockErrorHandler();
      final repo = CourseRepository(api: api, errorHandler: handler);

      when(
        () => api.query(
          table: 'courses',
          select: 'id,title,description,cover_image,is_published,created_at',
          filters: {'id': 999},
        ),
      ).thenAnswer((_) async => <Map<String, dynamic>>[]);

      await expectLater(() => repo.getCourse('999'), throwsA(isA<Exception>()));

      verify(() => handler.handle(any(), any<StackTrace>())).called(1);
    });
  });

  group('CourseRepository.getLessonsByCourseId', () {
    test(
      'builds lessons graph with status and layout using LocalProgressStore',
      () async {
        final api = _MockApiService();
        final handler = _MockErrorHandler();
        final repo = CourseRepository(api: api, errorHandler: handler);

        when(
          () => api.query(
            table: 'lessons',
            select: 'id,title,"order"',
            filters: {'course_id': 'course-1'},
            orderBy: 'order',
          ),
        ).thenAnswer(
          (_) async => <Map<String, dynamic>>[
            {'id': 1, 'title': 'Second', 'order': 2},
            {'id': 2, 'title': 'Third', 'order': 3},
            {'id': 0, 'title': 'First', 'order': 1},
          ],
        );

        SharedPreferences.setMockInitialValues({
          'progress_course:course-1': '{"1": true, "2": false}',
        });

        final lessons = await repo.getLessonsByCourseId('course-1');

        expect(lessons, hasLength(3));

        expect(lessons[0].title, 'First');
        expect(lessons[0].status, LessonStatus.inProgress);

        expect(lessons[1].title, 'Second');
        expect(lessons[1].status, LessonStatus.completed);

        expect(lessons[2].title, 'Third');
        expect(lessons[2].status, LessonStatus.locked);

        expect(lessons[0].prereqIds, isEmpty);
        expect(lessons[1].prereqIds, [lessons[0].id]);
        expect(lessons[2].prereqIds, [lessons[1].id]);

        for (final l in lessons) {
          expect(l.posX, inInclusiveRange(0.0, 1.0));
          expect(l.posY, inInclusiveRange(0.0, 1.0));
        }

        verifyNever(() => handler.handle(any(), any<StackTrace>()));
      },
    );

    test('returns fallback lessons when no lessons rows', () async {
      final api = _MockApiService();
      final handler = _MockErrorHandler();
      final repo = CourseRepository(api: api, errorHandler: handler);

      when(
        () => api.query(
          table: 'lessons',
          select: 'id,title,"order"',
          filters: {'course_id': 'course-1'},
          orderBy: 'order',
        ),
      ).thenAnswer((_) async => <Map<String, dynamic>>[]);

      SharedPreferences.setMockInitialValues({});

      final lessons = await repo.getLessonsByCourseId('course-1');

      expect(lessons, hasLength(2));
      expect(lessons.first.title, 'Introduction');
      expect(lessons.first.status, LessonStatus.inProgress);

      verifyNever(() => handler.handle(any(), any<StackTrace>()));
    });

    test('forwards errors to ErrorHandler and rethrows', () async {
      final api = _MockApiService();
      final handler = _MockErrorHandler();
      final repo = CourseRepository(api: api, errorHandler: handler);

      when(
        () => api.query(
          table: 'lessons',
          select: 'id,title,"order"',
          filters: {'course_id': 'course-1'},
          orderBy: 'order',
        ),
      ).thenThrow(Exception('boom-lessons'));

      await expectLater(
        () => repo.getLessonsByCourseId('course-1'),
        throwsA(isA<Exception>()),
      );

      verify(() => handler.handle(any(), any<StackTrace>())).called(1);
    });
  });

  group('CourseRepository.markLessonDone', () {
    test('throws when not authenticated (no Supabase session)', () async {
      final api = _MockApiService();
      final handler = _MockErrorHandler();
      final repo = CourseRepository(api: api, errorHandler: handler);

      await expectLater(
        () => repo.markLessonDone(courseId: '1', lessonId: '2'),
        throwsA(isA<Exception>()),
      );

      verifyNever(
        () => api.upsert(
          table: any(named: 'table'),
          values: any(named: 'values'),
          onConflict: any(named: 'onConflict'),
        ),
      );
    });
  });

  group('CourseRepository.getTracks', () {
    test('maps rows from courses table to Track list', () async {
      final api = _MockApiService();
      final handler = _MockErrorHandler();
      final repo = CourseRepository(api: api, errorHandler: handler);

      when(
        () => api.query(
          table: 'courses',
          select: 'id,title,description,is_published,created_at',
          filters: {'is_published': true},
          orderBy: 'created_at',
        ),
      ).thenAnswer(
        (_) async => <Map<String, dynamic>>[
          {
            'id': 1,
            'title': 'Fullstack Bootcamp',
            'description': 'FS desc',
            'is_published': true,
            'created_at': '2025-01-01T00:00:00Z',
          },
        ],
      );

      final tracks = await repo.getTracks();

      expect(tracks, hasLength(1));
      expect(tracks.first, isA<Track>());
      expect(tracks.first.title, 'Fullstack Bootcamp');
      expect(tracks.first.subtitle, 'FS desc');

      verifyNever(() => handler.handle(any(), any<StackTrace>()));
    });
  });

  group('CourseRepository.getLessons (deprecated API)', () {
    test('falls back to fallback lessons when course id not found', () async {
      final api = _MockApiService();
      final handler = _MockErrorHandler();
      final repo = CourseRepository(api: api, errorHandler: handler);

      for (final trackId in TrackId.values) {
        final kw = switch (trackId) {
          TrackId.python => 'python',
          TrackId.fullstack => 'full',
          TrackId.backend => 'back',
          TrackId.vanillaJs => 'vanilla',
          TrackId.typescript => 'type',
          TrackId.html => 'html',
          TrackId.css => 'css',
        };

        when(
          () => api.query(
            table: 'courses',
            select: 'id,title',
            filters: {'is_published': true, 'title': 'like:$kw'},
            limit: 1,
          ),
        ).thenAnswer((_) async => <Map<String, dynamic>>[]);
      }

      for (final trackId in TrackId.values) {
        final lessons = await repo.getLessons(trackId);
        expect(lessons, isNotEmpty);
      }

      verifyNever(() => handler.handle(any(), any<StackTrace>()));
    });

    test('when course id found delegates to getLessonsByCourseId', () async {
      final api = _MockApiService();
      final handler = _MockErrorHandler();
      final repo = CourseRepository(api: api, errorHandler: handler);

      when(
        () => api.query(
          table: 'courses',
          select: 'id,title',
          filters: {'is_published': true, 'title': 'like:python'},
          limit: 1,
        ),
      ).thenAnswer(
        (_) async => <Map<String, dynamic>>[
          {'id': 42, 'title': 'Python basics'},
        ],
      );

      when(
        () => api.query(
          table: 'lessons',
          select: 'id,title,"order"',
          filters: {'course_id': 42},
          orderBy: 'order',
        ),
      ).thenAnswer(
        (_) async => <Map<String, dynamic>>[
          {'id': 1, 'title': 'Lesson 1', 'order': 1},
        ],
      );

      SharedPreferences.setMockInitialValues({'progress_course:42': '{}'});

      final lessons = await repo.getLessons(TrackId.python);

      expect(lessons, hasLength(1));
      expect(lessons.first.title, 'Lesson 1');

      verifyNever(() => handler.handle(any(), any<StackTrace>()));
    });
  });
}
