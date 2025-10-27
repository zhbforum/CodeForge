import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/models/lesson.dart';
import 'package:mobile_app/features/catalog/presentation/viewmodels/lesson_providers.dart';

class QuizCard extends ConsumerWidget {
  const QuizCard({required this.slide, super.key});
  final LessonSlide slide;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final q = slide.content['question'] as String? ?? '';
    final answers = (slide.content['answers'] as List? ?? const [])
        .map((e) => e.toString())
        .toList();
    final correctIndex = (slide.content['correctIndex'] as num?)?.toInt();
    final explanation = slide.content['explanation'] as String?;

    final selected = ref.watch(quizSelectedProvider(slide.id));
    final revealed = ref.watch(quizRevealedProvider(slide.id));
    final wrongIndex = ref.watch(quizWrongIndexProvider(slide.id));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (q.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(q, style: Theme.of(context).textTheme.titleMedium),
              ),

            for (int i = 0; i < answers.length; i++)
              _AnswerOptionTile(
                index: i,
                text: answers[i],
                selectedIndex: selected,
                correctIndex: correctIndex,
                revealed: revealed,
                wrongIndex: wrongIndex,
                onSelect: revealed
                    ? null
                    : () {
                        ref.read(quizSelectedProvider(slide.id)
                          .notifier).state = i;
                        ref.read(quizWrongIndexProvider(slide.id)
                          .notifier).state = null;
                      },
              ),

            const SizedBox(height: 8),

            Row(
              children: [
                FilledButton(
                  onPressed: (selected == null)
                      ? null
                      : () {
                          if (selected == correctIndex) {
                            ref.read(quizRevealedProvider(slide.id)
                              .notifier).state = true;
                            ref.read(quizWrongIndexProvider(slide.id)
                              .notifier).state = null;
                          } else {
                            ref.read(quizWrongIndexProvider(slide.id)
                              .notifier).state = selected;
                          }
                        },
                  child: const Text('Check answer'),
                ),
                const SizedBox(width: 12),
                if (revealed)
                  TextButton(
                    onPressed: () {
                      ref.read(quizSelectedProvider(slide.id)
                        .notifier).state = null;
                      ref.read(quizRevealedProvider(slide.id)
                        .notifier).state = false;
                      ref.read(quizWrongIndexProvider(slide.id)
                        .notifier).state = null;
                    },
                    child: const Text('Try again'),
                  ),
              ],
            ),

            if (!revealed && wrongIndex != null) ...[
              const SizedBox(height: 12),
              const _WrongTryAgainBanner(),
            ],

            if (revealed) ...[
              const SizedBox(height: 12),
              const _ResultBanner(correct: true),
              if (explanation != null && explanation.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  explanation,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _AnswerOptionTile extends StatelessWidget {
  const _AnswerOptionTile({
    required this.index,
    required this.text,
    required this.selectedIndex,
    required this.correctIndex,
    required this.revealed,
    required this.wrongIndex,
    required this.onSelect,
  });

  final int index;
  final String text;
  final int? selectedIndex;
  final int? correctIndex;
  final bool revealed;
  final int? wrongIndex;
  final VoidCallback? onSelect;

  bool get _isSelected => selectedIndex == index;
  bool get _isCorrect => correctIndex == index;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    const Color greenBorder = Colors.green;
    final greenBg = Theme.of(context).brightness == Brightness.dark
        ? Colors.green.withValues(alpha: 0.25)
        : Colors.green.withValues(alpha: 0.12);

    final isMarkedWrong = wrongIndex != 
      null && wrongIndex == index && !revealed;

    late Color bg;
    late Color border;
    IconData? leadIcon;
    var opacity = 1.0;

    if (revealed && _isCorrect) {
      bg = greenBg;
      border = greenBorder;
      leadIcon = Icons.check_circle_rounded;
    } else if (isMarkedWrong) {
      bg = cs.errorContainer;
      border = cs.error;
      leadIcon = Icons.close_rounded;
    } else if (!revealed && _isSelected) {
      bg = cs.primaryContainer;
      border = cs.primary;
    } else if (revealed) {
      bg = Colors.transparent;
      border = cs.outlineVariant;
      opacity = 0.6;
    } else {
      bg = Colors.transparent;
      border = cs.outlineVariant;
    }

    return Opacity(
      opacity: opacity,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: InkWell(
          onTap: onSelect,
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: bg,
              border: Border.all(color: border, width: 1.4),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                if (leadIcon != null) ...[
                  Icon(leadIcon, size: 20),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Text(
                    text,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(width: 10),
                _AnswerIndexBadge(
                  number: index + 1,
                  revealed: revealed,
                  isCorrect: revealed && _isCorrect,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnswerIndexBadge extends StatelessWidget {
  const _AnswerIndexBadge({
    required this.number,
    required this.revealed,
    required this.isCorrect,
  });

  final int number;
  final bool revealed;
  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = isCorrect
        ? Colors.green
        : (revealed ? cs.surfaceContainerHighest : cs.surfaceContainerHighest);
    final fg =
        isCorrect ? Colors.white : Theme.of(context).textTheme.bodySmall?.color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$number',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: fg),
      ),
    );
  }
}

class _WrongTryAgainBanner extends StatelessWidget {
  const _WrongTryAgainBanner();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.close_rounded, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Wrong', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(
                  "Try again. Don't give up!",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultBanner extends StatelessWidget {
  const _ResultBanner({required this.correct});
  final bool correct;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final bg = correct
        ? (Theme.of(context).brightness == Brightness.dark
            ? Colors.green.withValues(alpha: 0.25)
            : Colors.green.withValues(alpha: 0.12))
        : cs.errorContainer;

    final icon = correct ? Icons.check_circle : Icons.close_rounded;
    final title = correct ? 'Correct!' : 'Not quite';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleSmall),
          ),
        ],
      ),
    );
  }
}
