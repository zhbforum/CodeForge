import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/models/course_node.dart';
import 'package:mobile_app/core/models/track.dart';
import 'package:mobile_app/features/catalog/presentation/viewmodels/course_path_provider.dart';
import 'package:mobile_app/features/catalog/presentation/widgets/course_path.dart';

class TrackDetailPage extends ConsumerWidget {
  const TrackDetailPage({
    required this.trackId,
    required this.title,
    super.key,
  });

  final TrackId trackId;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nodes = ref.watch(coursePathProvider);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: CoursePath(
          nodes: nodes,
          onNodeTap: (CourseNode n) {
            if (n.status == NodeStatus.available) {
              ref.read(coursePathProvider.notifier).markDone(n.id);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Completed: ${n.title}')));
            }
          },
        ),
      ),
    );
  }
}
