import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/models/lesson.dart';
import 'package:mobile_app/core/models/track.dart';
import 'package:mobile_app/features/catalog/controllers/track_detail_controller.dart';

class TrackDetailPage extends ConsumerWidget {
  const TrackDetailPage({
    required this.trackId,
    required this.title,
    super.key,
  });

  final TrackId trackId;
  final String title;

  IconData _iconFor(LessonType t) {
    switch (t) {
      case LessonType.theory:
        return Icons.menu_book;
      case LessonType.fillIn:
        return Icons.edit_note;
      case LessonType.quiz:
        return Icons.quiz;
    }
  }

  Widget _statusChip(BuildContext ctx, LessonStatus s) {
    final scheme = Theme.of(ctx).colorScheme;
    switch (s) {
      case LessonStatus.completed:
        return Chip(
          label: const Text('Done'),
          backgroundColor: scheme.secondaryContainer,
        );
      case LessonStatus.inProgress:
        return Chip(
          label: const Text('In progress'),
          backgroundColor: scheme.primaryContainer,
        );
      case LessonStatus.locked:
        return const Chip(label: Text('Locked'));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncLessons = ref.watch(lessonsProvider(trackId));

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: asyncLessons.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Failed to load lessons: $e')),
        data: (List<Lesson> lessons) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: lessons.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (ctx, i) {
            final l = lessons[i];
            return Card(
              child: ListTile(
                leading: Icon(_iconFor(l.type)),
                title: Text(l.title),
                subtitle: Text('#${l.order} • ${l.type.name}'),
                trailing: _statusChip(ctx, l.status),
                onTap: l.status == LessonStatus.locked
                    ? null
                    : () {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(content: Text('Open "${l.title}" (TBD)')),
                        );
                      },
              ),
            );
          },
        ),
      ),
    );
  }
}
