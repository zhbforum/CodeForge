import 'package:flutter/material.dart';

class CoursePathPainter extends CustomPainter {
  CoursePathPainter(this.points, {required this.color, this.strokeWidth = 6});

  final List<Offset> points;
  final double strokeWidth;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 2
      ..color = color.withValues(alpha: 0.18)
      ..strokeCap = StrokeCap.round;

    final top = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = color.withValues(alpha: 0.75)
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < points.length - 1; i++) {
      final a = points[i];
      final b = points[i + 1];
      final midX = (a.dx + b.dx) / 2;

      final path = Path()
        ..moveTo(a.dx, a.dy)
        ..quadraticBezierTo(midX, a.dy, b.dx, b.dy);

      canvas
        ..drawPath(path, base)
        ..drawPath(path, top);
    }
  }

  @override
  bool shouldRepaint(covariant CoursePathPainter old) =>
      old.points != points ||
      old.strokeWidth != strokeWidth ||
      old.color != color;
}
