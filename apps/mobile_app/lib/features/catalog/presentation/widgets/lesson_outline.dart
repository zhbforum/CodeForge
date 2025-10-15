import 'package:flutter/material.dart';
import 'package:mobile_app/core/models/course_node.dart';

class LessonOutline extends StatefulWidget {
  const LessonOutline({required this.nodes, required this.onTap, super.key});

  final List<CourseNode> nodes;
  final void Function(CourseNode) onTap;

  @override
  State<LessonOutline> createState() => _LessonOutlineState();
}

class _LessonOutlineState extends State<LessonOutline> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final filtered = _query.trim().isEmpty
        ? widget.nodes
        : widget.nodes.where((n) {
            final q = _query.toLowerCase();
            return n.title.toLowerCase().contains(q) ||
                n.id.toLowerCase().contains(q);
          }).toList();

    String statusLabel(NodeStatus s) => switch (s) {
      NodeStatus.locked => 'Locked',
      NodeStatus.available => 'Available',
      NodeStatus.done => 'Completed',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          onChanged: (v) => setState(() => _query = v),
          decoration: InputDecoration(
            hintText: 'Search lessons',
            prefixIcon: const Icon(Icons.search),
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            itemCount: filtered.length,
            separatorBuilder: (_, __) => Divider(color: cs.outlineVariant),
            itemBuilder: (context, i) {
              final n = filtered[i];
              final icon = switch (n.status) {
                NodeStatus.locked => const Icon(Icons.lock),
                NodeStatus.available => const Icon(Icons.play_circle_fill),
                NodeStatus.done => const Icon(Icons.check_circle),
              };

              return ListTile(
                dense: true,
                leading: icon,
                title: Text(
                  n.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  statusLabel(n.status),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
                trailing: const Icon(Icons.chevron_right),
                enabled: n.status != NodeStatus.locked,
                onTap: () => widget.onTap(n),
              );
            },
          ),
        ),
      ],
    );
  }
}
