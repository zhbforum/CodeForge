import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/core/models/course_node.dart';
import 'package:mobile_app/features/catalog/data/progress_store.dart';
import 'package:mobile_app/features/catalog/presentation/viewmodels/course_path_provider.dart';
import 'package:mobile_app/features/catalog/presentation/widgets/course_path.dart';

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
        data: (nodes) => SafeArea(
          child: CoursePath(
            nodes: nodes,
            onNodeTap: (CourseNode n) async {
              if (n.status != NodeStatus.available) return;

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
                messenger.showSnackBar(
                  SnackBar(content: Text('Ошибка сохранения: $e')),
                );
              }
            },
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
