import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CourseHeader extends StatelessWidget {
  const CourseHeader({
    required this.title,
    super.key,
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

    final continueStyle = FilledButton.styleFrom(
      visualDensity: isNarrow ? VisualDensity.compact : VisualDensity.standard,
      padding: EdgeInsets.symmetric(horizontal: isNarrow ? 12 : 16),
      minimumSize: Size(0, isNarrow ? 36 : 40),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: StadiumBorder(side: BorderSide(color: cs.outlineVariant)),
    );

    final titleHPad = isNarrow ? 64.0 : 8.0;

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
                    onPressed: onBack ?? () => context.go('/home'),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                ],
              ),

              Center(
                child: GestureDetector(
                  onTap: onTitleTap,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: titleHPad,
                      vertical: 6,
                    ),
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
                      style: continueStyle,
                      onPressed: onContinue,
                      icon: Icon(
                        Icons.play_arrow_rounded,
                        size: isNarrow ? 18 : 20,
                      ),
                      label: Text(
                        'Continue',
                        style: isNarrow
                            ? Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: cs.onPrimary,
                              )
                            : null,
                      ),
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
