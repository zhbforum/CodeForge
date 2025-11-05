import 'package:flutter/material.dart';
import 'package:mobile_app/features/leaderboard/domain/models.dart';
import 'package:mobile_app/features/leaderboard/presentation/widgets/league_badge.dart';
import 'package:mobile_app/features/leaderboard/presentation/widgets/medal_icon.dart';
import 'package:mobile_app/shared/avatar/generated_avatar.dart';

class LeaderboardTile extends StatelessWidget {
  const LeaderboardTile({required this.entry, super.key});

  final LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      leading: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            foregroundImage:
                (entry.avatarUrl != null && entry.avatarUrl!.isNotEmpty)
                ? NetworkImage(entry.avatarUrl!)
                : null,
            child: (entry.avatarUrl == null || entry.avatarUrl!.isEmpty)
                ? GeneratedAvatar(seed: entry.displayName, size: 24)
                : null,
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
      title: Text(
        '${entry.rank}. ${entry.displayName}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Row(
        children: [
          LeagueBadge(entry.leagueName),
          const SizedBox(width: 8),
          Text(
            'lvl ${entry.level}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: .68),
            ),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _xpMini('Season', entry.seasonExp, theme),
          const SizedBox(width: 6),
          _xpMini('Total', entry.totalExp, theme, muted: true),
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$label $value',
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: txt,
        ),
      ),
    );
  }
}
