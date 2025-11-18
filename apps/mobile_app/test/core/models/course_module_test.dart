import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/models/module.dart';

void main() {
  group('CourseModule', () {
    test('creates instance with all fields', () {
      const module = CourseModule(
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
      const module = CourseModule(
        id: 'module-empty',
        title: 'Empty module',
        order: 0,
        totalLessons: 0,
        doneLessons: 0,
      );

      expect(module.progressPct, 0);
    });

    test('progressPct returns rounded percentage', () {
      const module = CourseModule(
        id: 'module-progress',
        title: 'Progress module',
        order: 2,
        totalLessons: 4,
        doneLessons: 1,
      );

      expect(module.progressPct, 25);
    });

    test('progressPct can go over 100 when doneLessons > totalLessons', () {
      const module = CourseModule(
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
