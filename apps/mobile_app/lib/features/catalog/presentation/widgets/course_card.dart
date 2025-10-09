import 'package:flutter/material.dart';
import 'package:mobile_app/core/models/course.dart';
import 'package:mobile_app/core/models/track.dart';
import 'package:mobile_app/core/ui/tech_icon.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({
    required this.course,
    required this.onTap,
    this.progress = 0.0,
    this.locked = false,
    this.highlighted = false,
    this.dense = false,
    super.key,
  });

  final Course course;
  final VoidCallback onTap;
  final double progress;
  final bool locked;
  final bool highlighted;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final progressPct = (progress * 100).round();
    final techs = iconsForTrackId(_resolveTrackIdFromCourse(course));

    final pad = dense ? 10.0 : 12.0;
    final gapS = dense ? 4.0 : 6.0;
    final iconSize = dense ? 14.0 : 16.0;
    final progressH = dense ? 6.0 : 8.0;

    const outerRadius = 22.0;
    const innerRadius = 18.0;

    final outerDecoration = highlighted
        ? BoxDecoration(
            borderRadius: BorderRadius.circular(outerRadius),
            gradient: LinearGradient(
              colors: [
                cs.primary.withValues(alpha: 0.6),
                cs.primary.withValues(alpha: 0.25),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: cs.primary.withValues(alpha: 0.25),
                blurRadius: 16,
                spreadRadius: 1,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 8),
              ),
            ],
          )
        : BoxDecoration(
            borderRadius: BorderRadius.circular(outerRadius),
            color: Colors.transparent,
          );

    return InkWell(
      borderRadius: BorderRadius.circular(outerRadius),
      onTap: locked ? null : onTap,
      child: Container(
        decoration: outerDecoration,
        padding: EdgeInsets.all(highlighted ? 3 : 0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(innerRadius),
            color: cs.surfaceContainerHighest,
            border: Border.all(
              color: cs.outlineVariant.withValues(
                alpha: highlighted ? 0.6 : 0.35,
              ),
            ),
          ),
          padding: EdgeInsets.all(pad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (techs.isNotEmpty) ...[
                TechIconsRow(items: techs, size: iconSize, spacing: 4),
                SizedBox(height: gapS),
              ],
              Row(
                children: [
                  Expanded(
                    child: Text(
                      course.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                        height: 1.05,
                        fontSize: dense
                            ? (theme.textTheme.titleMedium?.fontSize ?? 16) - 1
                            : null,
                      ),
                    ),
                  ),
                  if (locked) Icon(Icons.lock, color: cs.onSurfaceVariant),
                ],
              ),
              SizedBox(height: dense ? 2 : 4),
              Text(
                course.description ?? 'Без описания',
                maxLines: dense ? 1 : 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.15,
                  fontSize: dense
                      ? (theme.textTheme.bodySmall?.fontSize ?? 12) - .5
                      : null,
                ),
              ),

              SizedBox(height: dense ? 6 : 8),

              Row(
                children: [
                  Text(
                    'SECTION',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.9),
                      letterSpacing: 1.1,
                      height: 1,
                      fontSize: dense ? 10.5 : null,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '0/20',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.9),
                      height: 1,
                      fontSize: dense ? 10.5 : null,
                    ),
                  ),
                ],
              ),
              SizedBox(height: gapS),

              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  height: progressH.roundToDouble(),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0, 1),
                    backgroundColor: cs.outlineVariant.withValues(alpha: 0.4),
                    color: cs.primary.withValues(alpha: 0.9),
                  ),
                ),
              ),
              SizedBox(height: dense ? 4 : 6),

              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '$progressPct% completed',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1,
                    fontSize: dense ? 10.5 : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TrackId _resolveTrackIdFromCourse(Course c) {
    final t = '${c.title} ${c.description ?? ''}'.toLowerCase();
    if (t.contains('python')) return TrackId.python;
    if (t.contains('javascript') || t.contains('js')) return TrackId.vanillaJs;
    if (t.contains('full')) return TrackId.fullstack;
    if (t.contains('back')) return TrackId.backend;
    if (t.contains('vanilla')) return TrackId.vanillaJs;
    if (t.contains('type')) return TrackId.typescript;
    if (t.contains('html')) return TrackId.html;
    if (t.contains('css')) return TrackId.css;
    return TrackId.fullstack;
  }
}
