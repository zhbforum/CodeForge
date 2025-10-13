import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/core/models/course_node.dart';
import 'package:mobile_app/features/catalog/data/progress_store.dart';
import 'package:mobile_app/features/catalog/presentation/viewmodels/course_path_provider.dart';
import 'package:mobile_app/features/catalog/presentation/widgets/course_header.dart';
import 'package:mobile_app/features/catalog/presentation/widgets/course_meta_panel.dart';
import 'package:mobile_app/features/catalog/presentation/widgets/course_path.dart';
import 'package:mobile_app/features/catalog/presentation/widgets/lesson_outline.dart';

class TrackDetailPage extends ConsumerWidget {
  const TrackDetailPage({required this.courseId, super.key});
  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseAsync = ref.watch(courseProvider(courseId));
    final nodesAsync = ref.watch(coursePathProvider(courseId));

    final title = courseAsync.maybeWhen(
      data: (c) => c.title,
      orElse: () => 'Course',
    );

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: nodesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (nodes) {
          final total = nodes.length;
          final done = nodes.where((n) => n.status == NodeStatus.done).length;
          final progress = total == 0 ? 0.0 : done / total;

          CourseNode? nextNode;
          try {
            nextNode = nodes.firstWhere(
              (n) => n.status == NodeStatus.available,
            );
          } catch (_) {
            if (nodes.isNotEmpty) nextNode = nodes.first;
          }

          void openLesson(CourseNode n) => _openOrComplete(context, ref, n);

          return LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth;
              final isMobile = w < 700;
              final isTablet = w >= 700 && w < 1100;
              final isDesktop = w >= 1100;
              final cs = Theme.of(context).colorScheme;

              final header = CourseHeader(
                title: title,
                subtitle: 'Lessons: $done / $total',
                progress: progress,
                onContinue:
                    (nextNode == null || nextNode.status == NodeStatus.locked)
                    ? null
                    : () => openLesson(nextNode!),
              );

              final outline = LessonOutline(nodes: nodes, onTap: openLesson);

              final metaPanel = CourseMetaPanel(
                total: total,
                done: done,
                estimatedHours: (total * 0.15).toStringAsFixed(1),
                tags: const ['Beginner', 'Hands-on', 'Path'],
              );

              final cols = isDesktop ? 4 : (isTablet ? 3 : 2);
              final itemSize = isMobile
                  ? const Size(108, 108)
                  : const Size(96, 96);
              final hGap = isMobile ? 100.0 : 140.0;
              final vGap = isMobile ? 80.0 : 120.0;

              final path = CoursePath(
                nodes: nodes,
                cols: cols,
                itemSize: itemSize,
                hGap: hGap,
                vGap: vGap,
                onNodeTap: openLesson,
              );

              if (isMobile) {
                return SafeArea(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    children: [
                      header,
                      const SizedBox(height: 12),
                      path,
                      const SizedBox(height: 24),
                      outline,
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              }

              if (isTablet) {
                return SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: header,
                      ),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 360),
                              child: Material(
                                color: cs.surfaceContainerHighest,
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: outline,
                                ),
                              ),
                            ),
                            const VerticalDivider(width: 1),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: path,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: header,
                    ),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 360),
                            child: Material(
                              color: cs.surfaceContainerHighest,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: outline,
                              ),
                            ),
                          ),
                          const VerticalDivider(width: 1),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: path,
                            ),
                          ),
                          const VerticalDivider(width: 1),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 320),
                            child: Material(
                              color: cs.surfaceContainerHighest,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: metaPanel,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _openOrComplete(
    BuildContext context,
    WidgetRef ref,
    CourseNode n,
  ) async {
    if (n.status == NodeStatus.locked) return;

    final store = ref.read(progressStoreProvider);
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      await store.setLessonCompleted(
        courseId: courseId,
        lessonId: n.id,
        completed: true,
      );
      ref.invalidate(coursePathProvider(courseId));
      router.go('/home/course/$courseId/lesson/${n.id}');
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Ошибка сохранения: $e')));
    }
  }
}
