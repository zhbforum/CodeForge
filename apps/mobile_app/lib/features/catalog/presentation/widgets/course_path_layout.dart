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
    for (var i = 0; i < count; i++) {
      final row = i ~/ cols;
      final col = i % cols;
      final snakeCol = row.isEven ? col : (cols - 1 - col);
      final x = snakeCol * (itemSize.width + hGap) + itemSize.width / 2;
      final y = row * (itemSize.height + vGap) + itemSize.height / 2;
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
    final rows = (count / cols).ceil();
    final width = cols * itemSize.width + (cols - 1) * hGap;
    final height = rows * itemSize.height + (rows - 1) * vGap;
    return Size(width, height);
  }
}
