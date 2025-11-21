import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/models/module.dart';
import 'package:mobile_app/features/catalog/presentation/widgets/course_module_list_sheet.dart';

import '../../../../../helpers/test_wrap.dart';

void main() {
  group('CourseModuleListSheet', () {
    testWidgets('pops selected module when tapped', (tester) async {
      final modules = <CourseModule>[
        const CourseModule(
          id: 'm1',
          title: 'Module 1',
          order: 1,
          totalLessons: 10,
          doneLessons: 3,
        ),
        const CourseModule(
          id: 'm2',
          title: 'Module 2',
          order: 2,
          totalLessons: 8,
          doneLessons: 1,
        ),
      ];

      CourseModule? selected;

      await tester.pumpWidget(
        wrap(
          Builder(
            builder: (context) {
              return Center(
                child: ElevatedButton(
                  onPressed: () async {
                    final res = await showModalBottomSheet<CourseModule>(
                      context: context,
                      builder: (_) => CourseModuleListSheet(
                        title: 'All modules',
                        modules: modules,
                      ),
                    );
                    selected = res;
                  },
                  child: const Text('Open sheet'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Module 1'), findsOneWidget);
      expect(find.text('Module 2'), findsOneWidget);

      await tester.tap(find.text('Module 1'));
      await tester.pumpAndSettle();

      expect(selected, isNotNull);
      expect(selected!.id, 'm1');
      expect(selected!.title, 'Module 1');
      expect(selected!.progressPct, 30);
    });
  });
}
