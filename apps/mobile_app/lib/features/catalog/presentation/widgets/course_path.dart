import 'package:flutter/material.dart';
import 'package:mobile_app/core/models/course_node.dart';
import 'package:mobile_app/features/catalog/presentation/widgets/course_node_tile.dart';
import 'package:mobile_app/features/catalog/presentation/widgets/course_path_layout.dart';
import 'package:mobile_app/features/catalog/presentation/widgets/course_path_painter.dart';

class CoursePath extends StatelessWidget {
  const CoursePath({
    required this.nodes,
    required this.onNodeTap,
    super.key,
    this.cols = 3,
    this.itemSize = const Size(84, 84),
    this.hGap = 48,
    this.vGap = 64,
  });

  final List<CourseNode> nodes;
  final void Function(CourseNode) onNodeTap;
  final int cols;
  final Size itemSize;
  final double hGap;
  final double vGap;

  @override
  Widget build(BuildContext context) {
    final centers = SnakeLayout.place(
      count: nodes.length,
      cols: cols,
      itemSize: itemSize,
      hGap: hGap,
      vGap: vGap,
    );
    final canvasSize = SnakeLayout.scrollSize(
      count: nodes.length,
      cols: cols,
      itemSize: itemSize,
      hGap: hGap,
      vGap: vGap,
    );

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final connectorColor = theme.brightness == Brightness.dark
        ? scheme.onSurfaceVariant
        : scheme.outline;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: SizedBox(
          width: canvasSize.width,
          height: canvasSize.height,
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: CoursePathPainter(
                    centers,
                    color: connectorColor,
                    strokeWidth: 6,
                  ),
                ),
              ),
              for (var i = 0; i < nodes.length; i++)
                Positioned(
                  left: centers[i].dx - itemSize.width / 2,
                  top: centers[i].dy - itemSize.height / 2,
                  child: CourseNodeTile(
                    node: nodes[i],
                    onTap: () => onNodeTap(nodes[i]),
                    size: itemSize.width,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
