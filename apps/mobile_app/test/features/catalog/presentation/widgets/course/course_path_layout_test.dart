import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/catalog/presentation/widgets/course_path_layout.dart';

void main() {
  group('SnakeLayout.place', () {
    test('places items in a single vertical column when cols <= 1', () {
      const itemSize = Size(100, 40);
      const vGap = 8.0;

      final points = SnakeLayout.place(
        count: 3,
        cols: 1,
        itemSize: itemSize,
        hGap: 16,
        vGap: vGap,
      );

      expect(points.length, 3);

      for (final p in points) {
        expect(p.dx, itemSize.width / 2);
      }

      expect(points[0].dy, 0 * (itemSize.height + vGap) + itemSize.height / 2);
      expect(points[1].dy, 1 * (itemSize.height + vGap) + itemSize.height / 2);
      expect(points[2].dy, 2 * (itemSize.height + vGap) + itemSize.height / 2);
    });
  });
}
