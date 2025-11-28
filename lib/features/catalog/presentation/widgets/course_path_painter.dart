import 'package:flutter/material.dart';

class CoursePathPainter extends CustomPainter {
  CoursePathPainter(
    this.points, {
    required this.color,
    required this.nodeRadius,
    this.cornerRadius = 18.0,
    this.strokeWidth = 6.0,
  });

  final List<Offset> points;
  final double nodeRadius;
  final double cornerRadius;
  final double strokeWidth;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 2
      ..color = color.withValues(alpha: 0.18)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final top = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = color.withValues(alpha: 0.75)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = _buildOrthogonalPath(points, nodeRadius, cornerRadius);
    canvas
      ..drawPath(path, base)
      ..drawPath(path, top);
  }

  Path _buildOrthogonalPath(List<Offset> pts, double rNode, double rCorner) {
    final path = Path();

    var curStart = pts.first + Offset(0, rNode);
    path.moveTo(curStart.dx, curStart.dy);

    for (var i = 0; i < pts.length - 1; i++) {
      final next = pts[i + 1];

      final x0 = curStart.dx;
      final y0 = curStart.dy;

      final targetTop = Offset(next.dx, next.dy - rNode);
      final x1 = targetTop.dx;
      final y1 = targetTop.dy;

      if ((x0 - x1).abs() < 0.001) {
        path.lineTo(x1, y1);
      } else {
        final midY = (y0 + y1) / 2;
        final dir = x1 > x0 ? 1 : -1;

        path
          ..lineTo(x0, midY - rCorner)
          ..arcToPoint(
            Offset(x0 + dir * rCorner, midY),
            radius: Radius.circular(rCorner),
            clockwise: dir < 0,
          )
          ..lineTo(x1 - dir * rCorner, midY)
          ..arcToPoint(
            Offset(x1, midY + rCorner),
            radius: Radius.circular(rCorner),
            clockwise: dir > 0,
          )
          ..lineTo(x1, y1);
      }

      curStart = next + Offset(0, rNode);
    }

    return path;
  }

  @override
  bool shouldRepaint(covariant CoursePathPainter old) =>
      old.points != points ||
      old.nodeRadius != nodeRadius ||
      old.cornerRadius != cornerRadius ||
      old.strokeWidth != strokeWidth ||
      old.color != color;
}
