import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_app/core/models/lesson.dart';
import 'package:mobile_app/features/catalog/presentation/pages/lesson_page.dart';
import 'package:mobile_app/features/catalog/presentation/viewmodels/lesson_providers.dart';

LessonSlide _quizSlide({required String id, required int correctIndex}) {
  return LessonSlide(
    id: id,
    contentType: 'quiz',
    order: 1,
    content: {
      'question': 'Which is true about Python?',
      'answers': [
        'Compiles to native machine code without VM',
        'Uses significant indentation',
        'Requires explicit type declarations',
        'Cannot run on macOS',
      ],
      'correctIndex': correctIndex,
      'explanation': 'Python uses indentation to define blocks.',
    },
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const lessonId = '31';
  const courseId = '1';
  const slideId = 'q1';

  final headerOverride = lessonHeaderProvider(lessonId).overrideWith((
    ref,
  ) async {
    return LessonHeader(id: lessonId, title: 'Lesson (Test)', order: 1);
  });

  final slidesOverride = lessonSlidesProvider(lessonId).overrideWith((
    ref,
  ) async {
    return <LessonSlide>[_quizSlide(id: slideId, correctIndex: 1)];
  });

  final completedOverride = lessonCompletedProvider((
    courseId: courseId,
    lessonId: lessonId,
  )).overrideWith((ref) async => false);

  testWidgets('quiz flow: wrong -> banner; correct -> success & lock', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [headerOverride, slidesOverride, completedOverride],
        child: const MaterialApp(
          home: LessonPage(courseId: courseId, lessonId: lessonId),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Which is true about Python?'), findsOneWidget);
    await tester.tap(find.text('Compiles to native machine code without VM'));
    await tester.pump();

    await tester.tap(find.widgetWithText(FilledButton, 'Check answer'));
    await tester.pump();

    expect(find.text('Wrong'), findsOneWidget);
    expect(find.text("Try again. Don't give up!"), findsOneWidget);

    await tester.tap(find.text('Uses significant indentation'));
    await tester.pump();

    await tester.tap(find.widgetWithText(FilledButton, 'Check answer'));
    await tester.pump();

    expect(find.text('Correct!'), findsOneWidget);

    await tester.tap(find.text('Requires explicit type declarations'));
    await tester.pump();

    expect(find.text('Correct!'), findsOneWidget);
    expect(find.text('Wrong'), findsNothing);
  });
}
