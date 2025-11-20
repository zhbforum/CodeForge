import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/catalog/data/progress_store.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthRequiredException', () {
    test('toString returns class name', () {
      final ex = AuthRequiredException();
      expect(ex.toString(), 'AuthRequiredException');
    });
  });

  group('LocalProgressStore', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('getLessonCompletion returns empty map when nothing stored', () async {
      final store = LocalProgressStore();

      final result = await store.getLessonCompletion('course-1');

      expect(result, isEmpty);
    });

    test('getLessonCompletion decodes json and normalizes bools', () async {
      final prefsData = <String, Object>{
        'progress_course:course-1': jsonEncode(<String, dynamic>{
          'l1': true,
          'l2': false,
          'l3': 'not-bool',
        }),
      };
      SharedPreferences.setMockInitialValues(prefsData);

      final store = LocalProgressStore();

      final result = await store.getLessonCompletion('course-1');

      expect(result, <String, bool>{'l1': true, 'l2': false, 'l3': false});
    });

    test('setLessonCompleted creates new map when nothing stored', () async {
      final store = LocalProgressStore();

      await store.setLessonCompleted(
        courseId: 'course-1',
        lessonId: 'lesson-1',
        completed: true,
      );

      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('progress_course:course-1');

      expect(raw, isNotNull);

      final decoded = jsonDecode(raw!) as Map<String, dynamic>;
      expect(decoded, <String, dynamic>{'lesson-1': true});
    });

    test('setLessonCompleted updates existing map', () async {
      final initial = <String, Object>{
        'progress_course:course-1': jsonEncode(<String, bool>{
          'lesson-1': true,
        }),
      };
      SharedPreferences.setMockInitialValues(initial);

      final store = LocalProgressStore();

      await store.setLessonCompleted(
        courseId: 'course-1',
        lessonId: 'lesson-2',
        completed: false,
      );

      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('progress_course:course-1');
      final decoded = jsonDecode(raw!) as Map<String, dynamic>;

      expect(decoded, <String, dynamic>{'lesson-1': true, 'lesson-2': false});
    });

    test('clearCourse removes stored progress for given course', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'progress_course:course-1': jsonEncode(<String, bool>{
          'lesson-1': true,
        }),
      });

      final store = LocalProgressStore();

      await store.clearCourse('course-1');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('progress_course:course-1'), isNull);
    });
  });

  group('RemoteProgressStore with no session', () {
    SupabaseClient makeClient() =>
        SupabaseClient('https://example.supabase.co', 'anon-key');

    test(
      'getLessonCompletion returns empty map when session is null',
      () async {
        final client = makeClient();
        final store = RemoteProgressStore(client);

        final result = await store.getLessonCompletion('123');

        expect(result, isEmpty);
      },
    );

    test(
      'setLessonCompleted throws AuthRequiredException when session is null',
      () async {
        final client = makeClient();
        final store = RemoteProgressStore(client);

        expect(
          () => store.setLessonCompleted(
            courseId: '1',
            lessonId: '2',
            completed: true,
          ),
          throwsA(isA<AuthRequiredException>()),
        );
      },
    );

    test(
      'setCurrentSlide throws AuthRequiredException when session is null',
      () async {
        final client = makeClient();
        final store = RemoteProgressStore(client);

        expect(
          () => store.setCurrentSlide(lessonId: '2', order: 5),
          throwsA(isA<AuthRequiredException>()),
        );
      },
    );
  });

  group('RemoteProgressStore mapping helper', () {
    test('mapRowsToCompletionForTest normalizes ids and bools', () {
      final rows = [
        {'lesson_id': 1, 'is_completed': true},
        {'lesson_id': '2', 'is_completed': false},
        {'lesson_id': 3, 'is_completed': 'not-bool'},
      ];

      final result = mapRowsToCompletionForTest(rows);

      expect(result, <String, bool>{'1': true, '2': false, '3': false});
    });
  });
}
