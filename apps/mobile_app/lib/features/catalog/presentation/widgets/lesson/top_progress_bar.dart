import 'package:flutter/material.dart';

class TopProgressBar extends StatelessWidget {
  const TopProgressBar({
    required this.current, required this.min, required this.max, super.key,
  });

  final int current;
  final int min;
  final int max;

  @override
  Widget build(BuildContext context) {
    final total = (max - min + 1).clamp(1, 9999);
    final value = ((current - min + 1) / total).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(value: value),
          const SizedBox(height: 8),
          Text(
            'Step $current of $max',
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}
