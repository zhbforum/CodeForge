import 'package:flutter/material.dart';

class CourseMetaPanel extends StatelessWidget {
  const CourseMetaPanel({
    required this.total,
    required this.done,
    required this.estimatedHours,
    required this.tags,
    super.key,
  });

  final int total;
  final int done;
  final String estimatedHours;
  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    Widget row(IconData i, String label, String value) => Row(
      children: [
        Icon(i, size: 18, color: cs.primary),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About this course',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        row(Icons.menu_book, 'Lessons', '$done / $total'),
        const SizedBox(height: 8),
        row(Icons.schedule, 'Estimated time', '$estimatedHours h'),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final t in tags)
              Chip(
                label: Text(t),
                side: BorderSide(color: cs.outlineVariant),
                backgroundColor: cs.surface,
              ),
          ],
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.file_download),
          label: const Text('Resources'),
        ),
      ],
    );
  }
}
