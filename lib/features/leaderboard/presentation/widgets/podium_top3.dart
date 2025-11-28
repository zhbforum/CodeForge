import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_app/core/models/leaderboard.dart';
import 'package:mobile_app/features/leaderboard/presentation/widgets/medal_icon.dart';
import 'package:mobile_app/shared/avatar/generated_avatar.dart';

class PodiumTop3 extends StatelessWidget {
  const PodiumTop3({required this.top3, super.key});
  final List<LeaderboardEntry> top3;

  @override
  Widget build(BuildContext context) {
    if (top3.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sorted = top3.take(3).toList()
      ..sort((a, b) => a.rank.compareTo(b.rank));

    const h1 = 110.0;
    const h2 = 85.0;
    const h3 = 70.0;

    Widget step(LeaderboardEntry e, double height) {
      final gradTop = isDark
          ? theme.colorScheme.primary.withValues(alpha: .30)
          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: .95);
      final gradBottom = isDark
          ? theme.colorScheme.primary.withValues(alpha: .10)
          : theme.colorScheme.surface.withValues(alpha: .92);

      final avatarUrl = e.avatarUrl;
      final isSvg =
          avatarUrl != null &&
          avatarUrl.isNotEmpty &&
          (avatarUrl.endsWith('.svg') ||
              avatarUrl.contains('/svg') ||
              avatarUrl.contains('format=svg'));

      return Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 30,
                  foregroundImage:
                      (!isSvg && avatarUrl != null && avatarUrl.isNotEmpty)
                      ? NetworkImage(avatarUrl)
                      : null,
                  child: () {
                    if (isSvg && avatarUrl.isNotEmpty) {
                      return ClipOval(
                        child: SvgPicture.network(
                          avatarUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      );
                    }
                    if (avatarUrl == null || avatarUrl.isEmpty) {
                      return GeneratedAvatar(seed: e.displayName, size: 24);
                    }
                    return null;
                  }(),
                ),
                Positioned(
                  right: -4,
                  bottom: -4,
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: theme.scaffoldBackgroundColor,
                    child: MedalIcon(e.rank, size: 22),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              e.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'lvl ${e.level}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: .68),
              ),
            ),
            const SizedBox(height: 8),

            Container(
              height: height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [gradTop, gradBottom],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: isDark ? .18 : .45,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? .20 : .06),
                    blurRadius: isDark ? 6 : 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                '#${e.rank}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface.withValues(alpha: .90),
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: .18),
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: .25)
              : theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: .60,
                ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(
              alpha: isDark ? .18 : .45,
            ),
          ),
        ),
        padding: const EdgeInsets.only(
          top: 12,
          bottom: 20,
          left: 12,
          right: 12,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (sorted.length >= 2) step(sorted[1], h2),
            const SizedBox(width: 10),
            step(sorted[0], h1),
            const SizedBox(width: 10),
            if (sorted.length >= 3) step(sorted[2], h3),
          ],
        ),
      ),
    );
  }
}
