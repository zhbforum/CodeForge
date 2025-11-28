import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/catalog/presentation/widgets/course_path_painter.dart';

void main() {
  group('CoursePathPainter', () {
    test('handles vertical segments without corners', () {
      final points = <Offset>[const Offset(50, 50), const Offset(50, 150)];

      final painter = CoursePathPainter(
        points,
        color: Colors.blue,
        nodeRadius: 10,
      );

      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);

      painter.paint(canvas, const Size(200, 200));

      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    });

    test('shouldRepaint reacts to individual property changes', () {
      final points = <Offset>[const Offset(10, 10), const Offset(30, 30)];

      final base = CoursePathPainter(points, color: Colors.blue, nodeRadius: 8);

      final differentNodeRadius = CoursePathPainter(
        points,
        color: Colors.blue,
        nodeRadius: 10,
      );
      expect(differentNodeRadius.shouldRepaint(base), isTrue);

      final differentCornerRadius = CoursePathPainter(
        points,
        color: Colors.blue,
        nodeRadius: 8,
        cornerRadius: 20,
      );
      expect(differentCornerRadius.shouldRepaint(base), isTrue);

      final differentStrokeWidth = CoursePathPainter(
        points,
        color: Colors.blue,
        nodeRadius: 8,
        strokeWidth: 8,
      );
      expect(differentStrokeWidth.shouldRepaint(base), isTrue);

      final differentColor = CoursePathPainter(
        points,
        color: Colors.red,
        nodeRadius: 8,
      );
      expect(differentColor.shouldRepaint(base), isTrue);

      final same = CoursePathPainter(points, color: Colors.blue, nodeRadius: 8);
      expect(same.shouldRepaint(base), isFalse);
    });
  });
}
