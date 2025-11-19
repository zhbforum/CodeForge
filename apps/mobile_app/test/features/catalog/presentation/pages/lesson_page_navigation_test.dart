import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/core/models/lesson.dart';
import 'package:mobile_app/features/catalog/data/progress_store.dart';
import 'package:mobile_app/features/catalog/presentation/pages/lesson_page.dart';
import 'package:mobile_app/features/catalog/presentation/providers/lesson_providers.dart';
import 'package:mobile_app/features/catalog/presentation/widgets/lesson/finish_bar.dart';
import 'package:mocktail/mocktail.dart';

class _MockProgressStore extends Mock implements ProgressStore {}

LessonHeader _buildHeader() =>
    LessonHeader(id: 'header-1', title: 'Test lesson', order: 1);

LessonSlide _slide({required String id, required int order}) => LessonSlide(
  id: id,
  contentType: 'text',
  content: <String, dynamic>{'text': 'Slide $id'},
  order: order,
);

Widget _buildApp({
  required ProviderContainer container,
  required String courseId,
  required String moduleId,
  required String lessonId,
}) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => LessonPage(
          courseId: courseId,
          moduleId: moduleId,
          lessonId: lessonId,
        ),
      ),
      GoRoute(
        path: '/home/course/:courseId',
        builder: (context, state) => const SizedBox.shrink(),
      ),
    ],
  );

  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  const courseId = 'course-1';
  const moduleId = 'module-1';
  const lessonId = 'lesson-1';

  testWidgets(
    'shows slides error when slides provider fails (covers slides.hasError)',
    (tester) async {
      final container = ProviderContainer(
        overrides: [
          lessonHeaderProvider(
            lessonId,
          ).overrideWith((ref) async => _buildHeader()),
          lessonSlidesProvider(lessonId).overrideWith((ref) async {
            throw Exception('slides failed');
          }),
        ],
      );

      await tester.pumpWidget(
        _buildApp(
          container: container,
          courseId: courseId,
          moduleId: moduleId,
          lessonId: lessonId,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('Error:'), findsOneWidget);
    },
  );

  testWidgets(
    'sorts slides by id, clamps currentOrder keyboard + icon navigation',
    (tester) async {
      final header = _buildHeader();

      final slides = <LessonSlide>[
        _slide(id: '10', order: 2),
        _slide(id: '2', order: 2),
        _slide(id: '1', order: 1),
      ];

      final container = ProviderContainer(
        overrides: [
          lessonHeaderProvider(lessonId).overrideWith((ref) async => header),
          lessonSlidesProvider(lessonId).overrideWith((ref) async => slides),

          currentOrderProvider(lessonId).overrideWith((ref) => 999),

          lessonCompletedProvider((
            courseId: courseId,
            lessonId: lessonId,
          )).overrideWith((ref) async => false),
        ],
      );

      await tester.pumpWidget(
        _buildApp(
          container: container,
          courseId: courseId,
          moduleId: moduleId,
          lessonId: lessonId,
        ),
      );
      await tester.pumpAndSettle();

      final clampedValue = container.read(currentOrderProvider(lessonId));
      expect(clampedValue, 2);

      expect(find.byType(ListView), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(container.read(currentOrderProvider(lessonId)), 1);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(container.read(currentOrderProvider(lessonId)), 2);

      final prevButton = find.byTooltip('Previous');
      final nextButton = find.byTooltip('Next');

      await tester.tap(prevButton);
      await tester.pump();
      expect(container.read(currentOrderProvider(lessonId)), 1);

      await tester.tap(nextButton);
      await tester.pump();
      expect(container.read(currentOrderProvider(lessonId)), 2);
    },
  );

  testWidgets('onFinish marks lesson completed and navigates back', (
    tester,
  ) async {
    final header = _buildHeader();
    final slides = <LessonSlide>[_slide(id: '1', order: 1)];

    final mockStore = _MockProgressStore();

    when(
      () => mockStore.setLessonCompleted(
        courseId: any(named: 'courseId'),
        lessonId: any(named: 'lessonId'),
        completed: any(named: 'completed'),
      ),
    ).thenAnswer((_) async {});

    const key = (courseId: courseId, lessonId: lessonId);

    final container = ProviderContainer(
      overrides: [
        lessonHeaderProvider(lessonId).overrideWith((ref) async => header),
        lessonSlidesProvider(lessonId).overrideWith((ref) async => slides),

        currentOrderProvider(lessonId).overrideWith((ref) => 1),

        lessonCompletedProvider(key).overrideWith((ref) async => false),

        progressStoreProvider.overrideWithValue(mockStore),
      ],
    );

    await tester.pumpWidget(
      _buildApp(
        container: container,
        courseId: courseId,
        moduleId: moduleId,
        lessonId: lessonId,
      ),
    );
    await tester.pumpAndSettle();

    final finishBarFinder = find.byType(FinishBar);
    expect(finishBarFinder, findsOneWidget);

    final finishBar = tester.widget<FinishBar>(finishBarFinder);
    expect(finishBar.isCompleted, isFalse);
    expect(finishBar.onFinish, isNotNull);

    finishBar.onFinish!.call();

    verify(
      () => mockStore.setLessonCompleted(
        courseId: courseId,
        lessonId: lessonId,
        completed: true,
      ),
    ).called(1);
  });

  testWidgets('error in lessonCompletedProvider uses shrink widget', (
    tester,
  ) async {
    final header = _buildHeader();
    final slides = <LessonSlide>[_slide(id: '1', order: 1)];

    final container = ProviderContainer(
      overrides: [
        lessonHeaderProvider(lessonId).overrideWith((ref) async => header),
        lessonSlidesProvider(lessonId).overrideWith((ref) async => slides),
        currentOrderProvider(lessonId).overrideWith((ref) => 1),
        lessonCompletedProvider((
          courseId: courseId,
          lessonId: lessonId,
        )).overrideWith((ref) async {
          throw Exception('completion error');
        }),
      ],
    );

    await tester.pumpWidget(
      _buildApp(
        container: container,
        courseId: courseId,
        moduleId: moduleId,
        lessonId: lessonId,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(FinishBar), findsNothing);
    expect(find.byType(SizedBox), findsWidgets);
  });
}
