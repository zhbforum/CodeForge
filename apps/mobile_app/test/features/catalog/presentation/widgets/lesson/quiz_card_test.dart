import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_app/core/models/lesson.dart';
import 'package:mobile_app/features/catalog/presentation/providers/lesson_providers.dart';
import 'package:mobile_app/features/catalog/presentation/widgets/lesson/quiz_card.dart';

void main() {
  LessonSlide buildQuizSlide() {
    return LessonSlide(
      id: 'slide-quiz-1',
      contentType: 'quiz',
      order: 1,
      content: const {
        'question': '2 + 2 = ?',
        'answers': ['3', '4', '5'],
        'correctIndex': 1,
        'explanation': 'Basic math explanation',
      },
    );
  }

  group('QuizCard', () {
    testWidgets('Try again resets quiz providers', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final slide = buildQuizSlide();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(body: QuizCard(slide: slide)),
          ),
        ),
      );

      expect(container.read(quizSelectedProvider(slide.id)), isNull);
      expect(container.read(quizRevealedProvider(slide.id)), isFalse);
      expect(container.read(quizWrongIndexProvider(slide.id)), isNull);

      await tester.tap(find.text('4'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Check answer'));
      await tester.pumpAndSettle();

      expect(container.read(quizSelectedProvider(slide.id)), equals(1));
      expect(container.read(quizRevealedProvider(slide.id)), isTrue);
      expect(container.read(quizWrongIndexProvider(slide.id)), isNull);

      expect(find.text('Try again'), findsOneWidget);

      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();

      expect(container.read(quizSelectedProvider(slide.id)), isNull);
      expect(container.read(quizRevealedProvider(slide.id)), isFalse);
      expect(container.read(quizWrongIndexProvider(slide.id)), isNull);
    });

    testWidgets(
      'dark theme uses green highlight for correct answer and result banner',
      (tester) async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final slide = buildQuizSlide();

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: ThemeData.dark(),
              home: Scaffold(body: QuizCard(slide: slide)),
            ),
          ),
        );

        await tester.tap(find.text('4'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Check answer'));
        await tester.pumpAndSettle();

        expect(container.read(quizRevealedProvider(slide.id)), isTrue);
        expect(find.text('Correct!'), findsOneWidget);
      },
    );
  });

  group('ResultBanner', () {
    testWidgets('uses errorContainer background when correct is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const Scaffold(body: ResultBanner(correct: false)),
        ),
      );

      expect(find.text('Not quite'), findsOneWidget);
    });
  });
}
