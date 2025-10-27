import 'package:flutter/material.dart';

class CourseHeader extends StatelessWidget {
  const CourseHeader({
    required this.title, super.key,
    this.progress = 0,
    this.onContinue,
    this.onBack,
    this.onTitleTap,
  });

  final String title;
  final double progress;
  final VoidCallback? onContinue;
  final VoidCallback? onBack;
  final VoidCallback? onTitleTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;
    final isNarrow = width < 520;

    Widget progressChip() {
      final pct = (progress.clamp(0, 1) * 100).round();
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                value: progress.clamp(0, 1),
                strokeWidth: 3,
                color: cs.primary,
              ),
            ),
            const SizedBox(width: 6),
            Text('$pct%', style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Row(
                children: [
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                ],
              ),
              Center(
                child: GestureDetector(
                  onTap: onTitleTap,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, 
                      vertical: 6),
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!isNarrow) progressChip(),
                  if (!isNarrow) const SizedBox(width: 8),
                  if (onContinue != null)
                    FilledButton.icon(
                      onPressed: onContinue,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Continue'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
