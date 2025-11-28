import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/models/lesson.dart';
import 'package:mobile_app/core/services/api_service.dart';
import 'package:mobile_app/core/services/api_service_provider.dart';
import 'package:mobile_app/features/catalog/data/progress_store.dart';
import 'package:mobile_app/features/catalog/presentation/providers/lesson_providers.dart';
import 'package:mocktail/mocktail.dart';

class _MockApiService extends Mock implements ApiService {}

class _MockProgressStore extends Mock implements ProgressStore {}

void main() {
  group('lessonHeaderProvider', () {
    test('builds LessonHeader from API row with numeric id', () async {
      final api = _MockApiService();
      final progressStore = _MockProgressStore();

      when(
        () => api.single(
          table: 'lessons',
          select: 'id,title,"order"',
          idField: 'id',
          id: 42,
        ),
      ).thenAnswer(
        (_) async => <String, Object?>{
          'id': 42,
          'title': 'Intro to Dart',
          'order': 3,
        },
      );

      final container = ProviderContainer(
        overrides: [
          apiServiceProvider.overrideWithValue(api),
          progressStoreProvider.overrideWithValue(progressStore),
        ],
      );
      addTearDown(container.dispose);

      final header = await container.read(lessonHeaderProvider('42').future);

      expect(header, isA<LessonHeader>());
      expect(header.id, '42');
      expect(header.title, 'Intro to Dart');
      expect(header.order, 3);
    });

    test(
      'falls back to default title and order when fields are null',
      () async {
        final api = _MockApiService();
        final progressStore = _MockProgressStore();

        when(
          () => api.single(
            table: 'lessons',
            select: 'id,title,"order"',
            idField: 'id',
            id: 'custom-id',
          ),
        ).thenAnswer(
          (_) async => <String, Object?>{
            'id': 'custom-id',
            'title': null,
            'order': null,
          },
        );

        final container = ProviderContainer(
          overrides: [
            apiServiceProvider.overrideWithValue(api),
            progressStoreProvider.overrideWithValue(progressStore),
          ],
        );
        addTearDown(container.dispose);

        final header = await container.read(
          lessonHeaderProvider('custom-id').future,
        );

        expect(header.id, 'custom-id');
        expect(header.title, 'Lesson');
        expect(header.order, 1);
      },
    );
  });

  group('lessonSlidesProvider', () {
    test('maps rows to LessonSlide list', () async {
      final api = _MockApiService();
      final progressStore = _MockProgressStore();

      final rows = <Map<String, Object?>>[
        {
          'id': 1,
          'lesson_id': 10,
          'order': 1,
          'content_type': 'quiz',
          'content': {'question': 'What is Dart?'},
        },
        {
          'id': 'slide-2',
          'lesson_id': 10,
          'order': 2,
          'content_type': 'theory',
          'content': {'text': 'Dart is a programming language.'},
        },
      ];

      when(
        () => api.query(
          table: 'lesson_slides',
          select: 'id,lesson_id,"order",content_type,content',
          filters: {'lesson_id': 10},
          orderBy: 'order',
        ),
      ).thenAnswer((_) async => rows);

      final container = ProviderContainer(
        overrides: [
          apiServiceProvider.overrideWithValue(api),
          progressStoreProvider.overrideWithValue(progressStore),
        ],
      );
      addTearDown(container.dispose);

      final slides = await container.read(lessonSlidesProvider('10').future);

      expect(slides, hasLength(2));
      expect(slides, everyElement(isA<LessonSlide>()));

      final first = slides[0];
      final second = slides[1];

      expect(first.id, '1');
      expect(first.contentType, 'quiz');
      expect(first.order, 1);
      expect(first.content['question'], 'What is Dart?');

      expect(second.id, 'slide-2');
      expect(second.contentType, 'theory');
      expect(second.order, 2);
      expect(second.content['text'], 'Dart is a programming language.');
    });
  });

  group('lessonCompletedProvider', () {
    test('returns true when lessonId is marked completed in store', () async {
      final api = _MockApiService();
      final progressStore = _MockProgressStore();

      when(() => progressStore.getLessonCompletion('course-1')).thenAnswer(
        (_) async => <String, bool>{'lesson-1': true, 'lesson-2': false},
      );

      final container = ProviderContainer(
        overrides: [
          apiServiceProvider.overrideWithValue(api),
          progressStoreProvider.overrideWithValue(progressStore),
        ],
      );
      addTearDown(container.dispose);

      const key = (courseId: 'course-1', lessonId: 'lesson-1');

      final completed = await container.read(
        lessonCompletedProvider(key).future,
      );

      expect(completed, isTrue);
    });

    test(
      'returns false when lessonId is absent or false in completion map',
      () async {
        final api = _MockApiService();
        final progressStore = _MockProgressStore();

        when(
          () => progressStore.getLessonCompletion('course-1'),
        ).thenAnswer((_) async => <String, bool>{'lesson-1': true});

        final container = ProviderContainer(
          overrides: [
            apiServiceProvider.overrideWithValue(api),
            progressStoreProvider.overrideWithValue(progressStore),
          ],
        );
        addTearDown(container.dispose);

        const key = (courseId: 'course-1', lessonId: 'lesson-2');

        final completed = await container.read(
          lessonCompletedProvider(key).future,
        );

        expect(completed, isFalse);
      },
    );
  });
}
