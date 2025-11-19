import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:mobile_app/core/models/course.dart';
import 'package:mobile_app/core/models/course_node.dart';
import 'package:mobile_app/core/models/module.dart';
import 'package:mobile_app/features/catalog/presentation/pages/track_detail_page.dart';
import 'package:mobile_app/features/catalog/presentation/providers/course_path_provider.dart';
import 'package:mobile_app/features/catalog/presentation/providers/module_providers.dart';
import 'package:mobile_app/features/catalog/presentation/widgets/course_header.dart';
import 'package:mobile_app/features/catalog/presentation/widgets/course_path.dart';

Course _buildCourse() {
  return Course(
    id: 1,
    title: 'Test Course',
    description: 'Desc',
    isPublished: true,
  );
}

CourseModule _buildModule({required String id, required String title}) {
  return CourseModule(
    id: id,
    title: title,
    order: 1,
    totalLessons: 10,
    doneLessons: 2,
  );
}

CourseNode _node({
  required String id,
  required NodeStatus status,
  int order = 1,
}) {
  return CourseNode(
    id: id,
    title: 'Lesson $id',
    type: NodeType.lesson,
    status: status,
    progress: status == NodeStatus.done ? 100 : 0,
    order: order,
  );
}

Widget _buildApp({
  required ProviderContainer container,
  required String courseId,
  required String moduleId,
}) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) =>
            TrackDetailPage(courseId: courseId, moduleId: moduleId),
      ),
      GoRoute(
        path: '/home/course/:courseId/module/:moduleId/lesson/:lessonId',
        builder: (context, state) => const SizedBox(key: Key('lesson-target')),
      ),
      GoRoute(
        path: '/home/course/:courseId/module/:moduleId',
        builder: (context, state) => const SizedBox(key: Key('module-target')),
      ),
    ],
  );

  return UncontrolledProviderScope(
    container: container,
    child: TickerMode(
      enabled: false,
      child: MaterialApp.router(routerConfig: router),
    ),
  );
}

void main() {
  const courseId = '1';
  const moduleId = '1';

  TestWidgetsFlutterBinding.ensureInitialized();

  group('TrackDetailPage', () {
    testWidgets(
      'mobile layout, progress calc, fallback nextNode and locked node',
      (tester) async {
        final view = tester.view
          ..physicalSize = const Size(400, 800)
          ..devicePixelRatio = 1.0;
        addTearDown(() {
          view
            ..resetPhysicalSize()
            ..resetDevicePixelRatio();
        });

        final course = _buildCourse();

        final nodes = <CourseNode>[
          _node(id: 'l1', status: NodeStatus.done),
          _node(id: 'l2', status: NodeStatus.locked, order: 2),
          _node(id: 'l3', status: NodeStatus.locked, order: 3),
        ];

        final modules = <CourseModule>[
          _buildModule(id: 'm1', title: 'Module 1'),
          _buildModule(id: 'm2', title: 'Module 2'),
        ];

        final container = ProviderContainer(
          overrides: [
            courseProvider(courseId).overrideWith((ref) async => course),
            modulePathProvider((
              courseId: courseId,
              moduleId: moduleId,
            )).overrideWith((ref) async => nodes),
            courseModulesProvider(
              courseId,
            ).overrideWith((ref) async => modules),
          ],
        );

        await tester.pumpWidget(
          _buildApp(
            container: container,
            courseId: courseId,
            moduleId: moduleId,
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        final headerFinder = find.byType(CourseHeader);
        expect(headerFinder, findsOneWidget);

        final header = tester.widget<CourseHeader>(headerFinder);
        expect(header.title, 'Test Course');

        expect(header.progress, closeTo(1 / 3, 0.0001));
        expect(header.onContinue, isNotNull);

        header.onContinue!.call();

        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        expect(find.byKey(const Key('lesson-target')), findsOneWidget);

        final path = tester.widget<CoursePath>(find.byType(CoursePath));
        path.onNodeTap(_node(id: 'locked', status: NodeStatus.locked));

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byKey(const Key('lesson-target')), findsOneWidget);
      },
    );

    testWidgets('tablet layout: side outline and path grid', (tester) async {
      final view = tester.view
        ..physicalSize = const Size(900, 800)
        ..devicePixelRatio = 1.0;
      addTearDown(() {
        view
          ..resetPhysicalSize()
          ..resetDevicePixelRatio();
      });

      final course = _buildCourse();

      final nodes = <CourseNode>[
        _node(id: 'l1', status: NodeStatus.done),
        _node(id: 'l2', status: NodeStatus.available, order: 2),
        _node(id: 'l3', status: NodeStatus.locked, order: 3),
      ];

      final modules = <CourseModule>[
        _buildModule(id: 'm1', title: 'Module 1'),
        _buildModule(id: 'm2', title: 'Module 2'),
      ];

      final container = ProviderContainer(
        overrides: [
          courseProvider(courseId).overrideWith((ref) async => course),
          modulePathProvider((
            courseId: courseId,
            moduleId: moduleId,
          )).overrideWith((ref) async => nodes),
          courseModulesProvider(courseId).overrideWith((ref) async => modules),
        ],
      );

      await tester.pumpWidget(
        _buildApp(container: container, courseId: courseId, moduleId: moduleId),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(CoursePath), findsOneWidget);
      expect(find.byType(SafeArea), findsWidgets);
      expect(find.byType(Row), findsWidgets);
      expect(find.byType(ConstrainedBox), findsWidgets);
      expect(find.byType(Material), findsWidgets);
      expect(find.byType(Expanded), findsWidgets);
    });

    testWidgets(
      'desktop layout, modules loading -> orElse future, sheet + navigation',
      (tester) async {
        final view = tester.view
          ..physicalSize = const Size(1200, 800)
          ..devicePixelRatio = 1.0;
        addTearDown(() {
          view
            ..resetPhysicalSize()
            ..resetDevicePixelRatio();
        });

        final course = _buildCourse();

        final nodes = <CourseNode>[
          _node(id: 'l1', status: NodeStatus.done),
          _node(id: 'l2', status: NodeStatus.available, order: 2),
        ];

        final modules = <CourseModule>[
          _buildModule(id: 'm1', title: 'Module 1'),
          _buildModule(id: 'm2', title: 'Module 2'),
        ];

        final container = ProviderContainer(
          overrides: [
            courseProvider(courseId).overrideWith((ref) async => course),
            modulePathProvider((
              courseId: courseId,
              moduleId: moduleId,
            )).overrideWith((ref) async => nodes),
            courseModulesProvider(courseId).overrideWith((ref) async {
              await Future<void>.delayed(const Duration(milliseconds: 200));
              return modules;
            }),
          ],
        );

        await tester.pumpWidget(
          _buildApp(
            container: container,
            courseId: courseId,
            moduleId: moduleId,
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        expect(find.byType(CoursePath), findsOneWidget);
        expect(find.byType(SafeArea), findsWidgets);
        expect(find.byType(Row), findsWidgets);
        expect(find.byType(ConstrainedBox), findsWidgets);
        expect(find.byType(Material), findsWidgets);
        expect(find.byType(Expanded), findsWidgets);

        final headerFinder = find.byType(CourseHeader);
        final header = tester.widget<CourseHeader>(headerFinder);

        header.onTitleTap?.call();

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));

        final picked = modules[1];
        final rootContext = tester.element(find.byType(TrackDetailPage));
        Navigator.of(rootContext).pop<CourseModule>(picked);

        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        expect(find.byKey(const Key('module-target')), findsOneWidget);
      },
    );
  });
}
