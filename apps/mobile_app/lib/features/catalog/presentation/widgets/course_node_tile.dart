import 'package:flutter/material.dart';
import 'package:mobile_app/core/models/course_node.dart';

class CourseNodeTile extends StatelessWidget {
  const CourseNodeTile({
    required this.node,
    required this.onTap,
    super.key,
    this.size = 84,
  });

  final CourseNode node;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final locked = node.status == NodeStatus.locked;

    return Semantics(
      button: true,
      label: node.title,
      child: GestureDetector(
        onTap: locked ? null : onTap,
        child: Opacity(
          opacity: locked ? 0.55 : 1,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: locked
                    ? Theme.of(context).colorScheme.outlineVariant
                    : Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.65),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                  color: Colors.black.withValues(alpha: 0.25),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: _Inner(node: node),
          ),
        ),
      ),
    );
  }
}

class _Inner extends StatelessWidget {
  const _Inner({required this.node});
  final CourseNode node;

  @override
  Widget build(BuildContext context) {
    final icon = switch (node.type) {
      NodeType.practice => Icons.bolt,
      NodeType.quiz => Icons.help_outline,
      NodeType.boss => Icons.star,
      _ => Icons.play_arrow,
    };

    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(icon, size: 32),
        if (node.status == NodeStatus.done)
          const Positioned(
            right: 6,
            top: 6,
            child: Icon(Icons.check, size: 18),
          ),
        if (node.status == NodeStatus.locked)
          const Positioned(right: 6, top: 6, child: Icon(Icons.lock, size: 18)),
        if (node.status == NodeStatus.available && node.progress > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Text(
              '${node.progress}%',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
      ],
    );
  }
}
