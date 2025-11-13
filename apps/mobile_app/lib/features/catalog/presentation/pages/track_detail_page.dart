import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mobile_app/core/models/course_node.dart';
import 'package:mobile_app/core/models/module.dart';
import 'package:mobile_app/features/catalog/presentation/providers/course_path_provider.dart';
import 'package:mobile_app/features/catalog/presentation/providers/module_providers.dart';
import 'package:mobile_app/features/catalog/presentation/widgets/course_header.dart';
import 'package:mobile_app/features/catalog/presentation/widgets/course_meta_panel.dart';
import 'package:mobile_app/features/catalog/presentation/widgets/course_module_list_sheet.dart';
import 'package:mobile_app/features/catalog/presentation/widgets/course_path.dart';
import 'package:mobile_app/features/catalog/presentation/widgets/lesson_outline.dart';

class TrackDetailPage extends ConsumerWidget {
  const TrackDetailPage({
    required this.courseId,
    required this.moduleId,
    super.key,
  });

  final String courseId;
  final String moduleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseAsync = ref.watch(courseProvider(courseId));
    final modulesAsync = ref.watch(courseModulesProvider(courseId));
    final nodesAsync = ref.watch(
      modulePathProvider((courseId: courseId, moduleId: moduleId)),
    );

    final title = courseAsync.maybeWhen(
      data: (c) => c.title,
      orElse: () => 'Course',
    );

    return Scaffold(
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

          void openLesson(CourseNode n) => _openLesson(context, n);

          final headerPill = CourseHeader(
            title: title,
            progress: progress,
            onContinue:
                (nextNode == null || nextNode.status == NodeStatus.locked)
                ? null
                : () => openLesson(nextNode!),
            onTitleTap: () async {
              final modules = await modulesAsync.maybeWhen(
                data: Future.value,
                orElse: () => ref.read(courseModulesProvider(courseId).future),
              );

              if (!context.mounted) return;

              final picked = await showModalBottomSheet<CourseModule>(
                context: context,
                useSafeArea: true,
                isScrollControlled: true,
                backgroundColor: Theme.of(context).colorScheme.surface,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: (ctx) =>
                    CourseModuleListSheet(title: title, modules: modules),
              );

              if (!context.mounted) return;
              if (picked == null) return;

              context.go('/home/course/$courseId/module/${picked.id}');
            },
          );

          return LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth;
              final isMobile = w < 700;
              final isTablet = w >= 700 && w < 1100;
              final cs = Theme.of(context).colorScheme;

              final outline = LessonOutline(nodes: nodes, onTap: openLesson);

              final metaPanel = CourseMetaPanel(
                total: total,
                done: done,
                estimatedHours: (total * 0.15).toStringAsFixed(1),
                tags: const ['Beginner', 'Hands-on', 'Path'],
              );

              final cols = isTablet ? 3 : (isMobile ? 2 : 4);
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
                    padding: EdgeInsets.zero,
                    children: [
                      headerPill,
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Column(
                          children: [
                            path,
                            const SizedBox(height: 24),
                            outline,
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (isTablet) {
                return SafeArea(
                  child: Column(
                    children: [
                      headerPill,
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
                    headerPill,
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

  void _openLesson(BuildContext context, CourseNode n) {
    if (n.status == NodeStatus.locked) return;
    context.go('/home/course/$courseId/module/$moduleId/lesson/${n.id}');
  }
}
