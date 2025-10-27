import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_app/features/catalog/presentation/viewmodels/lesson_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const slideId = 'slide-quiz-1';
  const correctIndex = 1;

  test('quiz: wrong -> keep hidden; correct -> reveal & lock', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(quizSelectedProvider(slideId)), isNull);
    expect(container.read(quizRevealedProvider(slideId)), false);
    expect(container.read(quizWrongIndexProvider(slideId)), isNull);

    container.read(quizSelectedProvider(slideId).notifier).state = 0;
    expect(container.read(quizSelectedProvider(slideId)), 0);

    container.read(quizWrongIndexProvider(slideId).notifier).state =
        container.read(quizSelectedProvider(slideId));
    expect(container.read(quizWrongIndexProvider(slideId)), 0);
    expect(container.read(quizRevealedProvider(slideId)), false);

    container.read(quizSelectedProvider(slideId).notifier).state = correctIndex;
    container.read(quizWrongIndexProvider(slideId).notifier).state = null;
    expect(container.read(quizSelectedProvider(slideId)), correctIndex);
    expect(container.read(quizWrongIndexProvider(slideId)), isNull);

    container.read(quizRevealedProvider(slideId).notifier).state = true;
    expect(container.read(quizRevealedProvider(slideId)), true);

    container.read(quizSelectedProvider(slideId).notifier).state = null;
    container.read(quizRevealedProvider(slideId).notifier).state = false;
    container.read(quizWrongIndexProvider(slideId).notifier).state = null;

    expect(container.read(quizSelectedProvider(slideId)), isNull);
    expect(container.read(quizRevealedProvider(slideId)), false);
    expect(container.read(quizWrongIndexProvider(slideId)), isNull);
  });
}
