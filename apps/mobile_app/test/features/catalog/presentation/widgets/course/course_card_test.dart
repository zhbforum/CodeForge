import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/models/course.dart';
import 'package:mobile_app/features/catalog/presentation/widgets/course_card.dart';

import '../../../../../helpers/test_wrap.dart';

void main() {
  group('CourseCard', () {
    testWidgets('uses gradient and boxShadow when highlighted is true', (
      tester,
    ) async {
      final course = Course(
        id: 1,
        title: 'Python basics',
        description: 'Learn Python from scratch',
        isPublished: true,
      );

      await tester.pumpWidget(
        wrap(
          CourseCard(
            course: course,
            onTap: () {},
            progress: 0.3,
            highlighted: true,
          ),
        ),
      );

      final containers = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byType(CourseCard),
              matching: find.byType(Container),
            ),
          )
          .toList();

      final decorated = containers
          .map((c) => c.decoration)
          .whereType<BoxDecoration>()
          .firstWhere((d) => d.gradient != null);

      final gradient = decorated.gradient! as LinearGradient;

      expect(gradient.colors.length, 2);
      expect(decorated.boxShadow, isNotNull);
      expect(decorated.boxShadow!.length, 2);

      expect(gradient.colors[0].a, lessThan(1.0));
      expect(gradient.colors[1].a, lessThan(1.0));
    });
  });
}
