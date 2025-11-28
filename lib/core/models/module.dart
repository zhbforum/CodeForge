import 'package:flutter/foundation.dart';

@immutable
class CourseModule {
  const CourseModule({
    required this.id,
    required this.title,
    required this.order,
    required this.totalLessons,
    required this.doneLessons,
  });

  final String id;
  final String title;
  final int order;
  final int totalLessons;
  final int doneLessons;

  int get progressPct =>
      totalLessons == 0 ? 0 : ((doneLessons / totalLessons) * 100).round();
}
