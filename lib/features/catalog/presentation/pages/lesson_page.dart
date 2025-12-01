import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/core/models/lesson.dart';
import 'package:mobile_app/features/catalog/data/progress_store.dart';
import 'package:mobile_app/features/catalog/presentation/providers/course_path_provider.dart';
import 'package:mobile_app/features/catalog/presentation/providers/lesson_providers.dart';
import 'package:mobile_app/features/catalog/presentation/widgets/lesson/finish_bar.dart';
import 'package:mobile_app/features/catalog/presentation/widgets/lesson/slide_card.dart';
import 'package:mobile_app/features/catalog/presentation/widgets/lesson/top_progress_bar.dart';

class LessonPage extends ConsumerWidget {
  const LessonPage({
    required this.courseId,
    required this.moduleId,
    required this.lessonId,
    super.key,
  });

  final String courseId;
  final String moduleId;
  final String lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final header = ref.watch(lessonHeaderProvider(lessonId));
    final slides = ref.watch(lessonSlidesProvider(lessonId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          header.maybeWhen(data: (h) => h.title, orElse: () => 'Lesson'),
        ),
      ),
      body: _buildBody(context, ref, header, slides),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<LessonHeader> header,
    AsyncValue<List<LessonSlide>> slides,
  ) {
    if (header.isLoading || slides.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (header.hasError) {
      return Center(child: Text('Error: ${header.error}'));
    }
    if (slides.hasError) {
      return Center(child: Text('Error: ${slides.error}'));
    }

    final data = slides.value!;
    if (data.isEmpty) {
      return const Center(child: Text('No slides yet'));
    }

    final byOrder = <int, List<LessonSlide>>{};
    for (final s in data) {
      byOrder.putIfAbsent(s.order, () => []).add(s);
    }
    for (final list in byOrder.values) {
      list.sort((a, b) {
        final ai = int.tryParse(a.id) ?? 0;
        final bi = int.tryParse(b.id) ?? 0;
        return ai.compareTo(bi);
      });
    }

    final orders = byOrder.keys.toList()..sort();
    final minOrder = orders.first;
    final maxOrder = orders.last;

    final currentOrder = ref.watch(currentOrderProvider(lessonId));
    final clamped = currentOrder.clamp(minOrder, maxOrder);
    if (clamped != currentOrder) {
      Future.microtask(() {
        ref.read(currentOrderProvider(lessonId).notifier).state = clamped;
      });
    }

    final currentSlides = byOrder[clamped] ?? const <LessonSlide>[];
    final isLastStep = clamped == maxOrder;

    final completedAsync = ref.watch(
      lessonCompletedProvider((courseId: courseId, lessonId: lessonId)),
    );

    final canFinishLesson = ref.watch(lessonQuizzesCompletedProvider(lessonId));

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () {
          final curr = ref.read(currentOrderProvider(lessonId));
          if (curr > minOrder) {
            ref.read(currentOrderProvider(lessonId).notifier).state = curr - 1;
          }
        },
        const SingleActivator(LogicalKeyboardKey.arrowRight): () {
          final curr = ref.read(currentOrderProvider(lessonId));
          if (curr < maxOrder) {
            ref.read(currentOrderProvider(lessonId).notifier).state = curr + 1;
          }
        },
      },
      child: Focus(
        autofocus: true,
        child: Column(
          children: [
            TopProgressBar(current: clamped, min: minOrder, max: maxOrder),
            if (maxOrder > minOrder)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: clamped > minOrder
                          ? () =>
                                ref
                                        .read(
                                          currentOrderProvider(
                                            lessonId,
                                          ).notifier,
                                        )
                                        .state =
                                    clamped - 1
                          : null,
                      tooltip: 'Previous',
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: clamped < maxOrder
                          ? () =>
                                ref
                                        .read(
                                          currentOrderProvider(
                                            lessonId,
                                          ).notifier,
                                        )
                                        .state =
                                    clamped + 1
                          : null,
                      tooltip: 'Next',
                    ),
                  ],
                ),
              ),
            Expanded(
              child: SafeArea(
                top: false,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: currentSlides.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => SlideCard(slide: currentSlides[i]),
                ),
              ),
            ),
            if (isLastStep && canFinishLesson)
              completedAsync.when(
                data: (isCompleted) => FinishBar(
                  isCompleted: isCompleted,
                  onFinish: isCompleted
                      ? null
                      : () async {
                          final store = ref.read(progressStoreProvider);
                          await store.setLessonCompleted(
                            courseId: courseId,
                            lessonId: lessonId,
                            completed: true,
                          );
                          ref
                            ..invalidate(
                              lessonCompletedProvider((
                                courseId: courseId,
                                lessonId: lessonId,
                              )),
                            )
                            ..invalidate(coursePathProvider(courseId));
                          if (!context.mounted) return;
                          context.go('/home/course/$courseId');
                        },
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
          ],
        ),
      ),
    );
  }
}
