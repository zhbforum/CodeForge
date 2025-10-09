import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/core/models/course.dart';
import 'package:mobile_app/features/catalog/presentation/viewmodels/learn_view_model.dart';
import 'package:mobile_app/features/catalog/presentation/widgets/course_card.dart';

class LearnPage extends ConsumerWidget {
  const LearnPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCourses = ref.watch(coursesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Learn')),
      body: asyncCourses.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Ошибка: $e')),
        data: (courses) => _CoursesGrid(courses: courses),
      ),
    );
  }
}

class _CoursesGrid extends StatelessWidget {
  const _CoursesGrid({required this.courses});
  final List<Course> courses;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final crossAxisCount = w < 420
            ? 1
            : w < 900
            ? 2
            : w < 1400
            ? 3
            : 4;
        final childAspectRatio = w < 420
            ? 2.6
            : w < 900
            ? 1.45
            : 2.2;

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: courses.length,
              itemBuilder: (_, i) {
                final c = courses[i];
                final isDesktop = w >= 1200;
                return CourseCard(
                  course: c,
                  dense: isDesktop,
                  onTap: () => context.go('/home/course/${c.id}'),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
