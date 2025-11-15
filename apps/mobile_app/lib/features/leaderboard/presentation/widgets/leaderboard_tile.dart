import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_app/core/models/leaderboard.dart';
import 'package:mobile_app/features/leaderboard/presentation/widgets/league_badge.dart';
import 'package:mobile_app/features/leaderboard/presentation/widgets/medal_icon.dart';
import 'package:mobile_app/shared/avatar/generated_avatar.dart';

@visibleForTesting
SvgPicture Function(String url)? svgAvatarBuilderOverride;

SvgPicture _buildSvgAvatar(String url) {
  final override = svgAvatarBuilderOverride;
  if (override != null) {
    return override(url);
  }

  return SvgPicture.network(url, width: 44, height: 44, fit: BoxFit.cover);
}

@visibleForTesting
SvgPicture buildSvgAvatarForTest(String url) => _buildSvgAvatar(url);

class LeaderboardTile extends StatelessWidget {
  const LeaderboardTile({required this.entry, super.key});
  final LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onMed = theme.colorScheme.onSurface.withValues(alpha: .68);

    final avatarUrl = entry.avatarUrl;
    final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;
    final isSvg =
        hasAvatar &&
        (avatarUrl.endsWith('.svg') ||
            avatarUrl.contains('/svg') ||
            avatarUrl.contains('format=svg'));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                foregroundImage: (!isSvg && hasAvatar)
                    ? NetworkImage(avatarUrl)
                    : null,
                child: () {
                  if (isSvg && hasAvatar) {
                    return ClipOval(child: _buildSvgAvatar(avatarUrl));
                  }

                  if (!hasAvatar) {
                    return GeneratedAvatar(seed: entry.displayName, size: 24);
                  }

                  return null;
                }(),
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: theme.scaffoldBackgroundColor,
                  child: MedalIcon(entry.rank),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.rank}. ${entry.displayName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Flexible(child: LeagueBadge(entry.leagueName)),
                    const SizedBox(width: 8),
                    Text(
                      'lvl ${entry.level}',
                      style: theme.textTheme.bodyMedium?.copyWith(color: onMed),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _xpMini('Season', entry.seasonExp, theme),
                    _xpMini('Total', entry.totalExp, theme, muted: true),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _xpMini(
    String label,
    int value,
    ThemeData theme, {
    bool muted = false,
  }) {
    final bg = muted
        ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: .60)
        : theme.colorScheme.surfaceContainerHighest;
    final txt = muted
        ? theme.colorScheme.onSurface.withValues(alpha: .68)
        : theme.colorScheme.onSurface.withValues(alpha: .87);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 220, minHeight: 36),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          '$label $value',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: txt,
          ),
        ),
      ),
    );
  }
}
