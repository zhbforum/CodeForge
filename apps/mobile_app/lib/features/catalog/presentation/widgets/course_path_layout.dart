import 'dart:ui';

class SnakeLayout {
  static List<Offset> place({
    required int count,
    required int cols,
    required Size itemSize,
    required double hGap,
    required double vGap,
  }) {
    final points = <Offset>[];

    if (count <= 0) return points;
    if (cols <= 1) {
      for (var i = 0; i < count; i++) {
        final y = i * (itemSize.height + vGap) + itemSize.height / 2;
        final x = itemSize.width / 2;
        points.add(Offset(x, y));
      }
      return points;
    }

    final period = cols * 2 - 2;

    int laneForIndex(int i) {
      final p = i % period;
      return p < cols ? p : period - p;
    }

    for (var i = 0; i < count; i++) {
      final lane = laneForIndex(i);

      final x = lane * (itemSize.width + hGap) + itemSize.width / 2;
      final y = i * (itemSize.height + vGap) + itemSize.height / 2;

      points.add(Offset(x, y));
    }
    return points;
  }

  static Size scrollSize({
    required int count,
    required int cols,
    required Size itemSize,
    required double hGap,
    required double vGap,
  }) {
    final lanes = cols.clamp(1, 9999);
    final width = lanes * itemSize.width + (lanes - 1) * hGap;
    final height = (count <= 0)
        ? 0
        : (count * itemSize.height + (count - 1) * vGap);
    return Size(width, height.toDouble());
  }
}
