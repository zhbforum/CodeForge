import 'package:flutter/material.dart';

class FinishBar extends StatelessWidget {
  const FinishBar({
    required this.isCompleted, super.key,
    this.onFinish,
  });

  final bool isCompleted;
  final VoidCallback? onFinish;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            if (isCompleted) ...[
              const Icon(Icons.check_circle, size: 20),
              const SizedBox(width: 8),
              const Text('Lesson is completed'),
            ] else ...[
              const Text('You are on the last step'),
              const Spacer(),
              FilledButton.icon(
                onPressed: onFinish,
                icon: const Icon(Icons.flag),
                label: const Text('Finish lesson'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
