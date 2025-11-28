import 'package:flutter/material.dart';

class MedalIcon extends StatelessWidget {
  const MedalIcon(this.rank, {super.key, this.size = 20});
  final int rank;
  final double size;

  @override
  Widget build(BuildContext context) {
    var icon = Icons.emoji_events;
    Color color;

    switch (rank) {
      case 1:
        color = const Color(0xFFFFD700);
      case 2:
        color = const Color(0xFFC0C0C0);
      case 3:
        color = const Color(0xFFCD7F32);
      default:
        icon = Icons.leaderboard_outlined;
        color = Theme.of(context).colorScheme.primary;
    }
    return Icon(icon, color: color, size: size);
  }
}
