import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/models/module.dart';

// We intentionally avoid `const` here so the constructor runs at runtime
// and is visible in coverage. In a small test like this, the performance
// impact is negligible.
// ignore_for_file: prefer_const_constructors

void main() {
  group('CourseModule', () {
    test('creates instance with all fields', () {
      final module = CourseModule(
        id: 'module-1',
        title: 'Intro module',
        order: 1,
        totalLessons: 10,
        doneLessons: 3,
      );

      expect(module.id, 'module-1');
      expect(module.title, 'Intro module');
      expect(module.order, 1);
      expect(module.totalLessons, 10);
      expect(module.doneLessons, 3);
    });

    test('progressPct returns 0 when totalLessons is 0', () {
      final module = CourseModule(
        id: 'module-empty',
        title: 'Empty module',
        order: 0,
        totalLessons: 0,
        doneLessons: 0,
      );

      expect(module.progressPct, 0);
    });

    test('progressPct returns rounded percentage', () {
      final module = CourseModule(
        id: 'module-progress',
        title: 'Progress module',
        order: 2,
        totalLessons: 4,
        doneLessons: 1,
      );

      expect(module.progressPct, 25);
    });

    test('progressPct can go over 100 when doneLessons > totalLessons', () {
      final module = CourseModule(
        id: 'module-over',
        title: 'Over-completed module',
        order: 3,
        totalLessons: 5,
        doneLessons: 7,
      );

      expect(module.progressPct, 140);
    });
  });
}
