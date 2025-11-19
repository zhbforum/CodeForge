import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/core/models/course.dart';
import 'package:mobile_app/features/catalog/presentation/pages/learn_page.dart';
import 'package:mobile_app/features/catalog/presentation/viewmodels/learn_view_model.dart';
import 'package:mobile_app/features/catalog/presentation/widgets/course_card.dart';

Course _makeTestCourse({int id = 1}) {
  return Course(
    id: id,
    title: 'Test course $id',
    description: 'Description $id',
    isPublished: true,
  );
}

void main() {
  group('LearnBody', () {
    testWidgets('shows loading indicator when asyncCourses is loading', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LearnBody(asyncCourses: AsyncLoading<List<Course>>()),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message when asyncCourses is error', (
      tester,
    ) async {
      const errorMessage = 'boom';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LearnBody(
              asyncCourses: AsyncError<List<Course>>(
                errorMessage,
                StackTrace.empty,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Text), findsOneWidget);
      expect(find.textContaining('Error:'), findsOneWidget);
      expect(find.textContaining('boom'), findsOneWidget);
    });

    testWidgets('renders grid when asyncCourses has data', (tester) async {
      final courses = <Course>[_makeTestCourse(), _makeTestCourse(id: 2)];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LearnBody(asyncCourses: AsyncData<List<Course>>(courses)),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(GridView), findsOneWidget);
      expect(find.text('Test course 1'), findsOneWidget);
      expect(find.text('Test course 2'), findsOneWidget);
    });
  });

  group('LearnBody + _CoursesGrid responsive layout', () {
    final courses = <Course>[
      _makeTestCourse(),
      _makeTestCourse(id: 2),
      _makeTestCourse(id: 3),
    ];
    final asyncData = AsyncData<List<Course>>(courses);

    Future<void> pumpWithSize(WidgetTester tester, Size size) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: LearnBody(asyncCourses: asyncData)),
        ),
      );

      await tester.pump();
    }

    testWidgets('< 420 width -> 1 column, aspect 2.6', (tester) async {
      await pumpWithSize(tester, const Size(400, 800));

      final grid = tester.widget<GridView>(find.byType(GridView));
      final delegate =
          grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;

      expect(delegate.crossAxisCount, 1);
      expect(delegate.childAspectRatio, 2.6);
      expect(delegate.mainAxisSpacing, 16);
      expect(delegate.crossAxisSpacing, 16);
    });

    testWidgets('< 900 width -> 2 columns, aspect 1.45', (tester) async {
      await pumpWithSize(tester, const Size(800, 800));

      final grid = tester.widget<GridView>(find.byType(GridView));
      final delegate =
          grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;

      expect(delegate.crossAxisCount, 2);
      expect(delegate.childAspectRatio, 1.45);
      expect(delegate.mainAxisSpacing, 16);
      expect(delegate.crossAxisSpacing, 16);
    });

    testWidgets('< 1400 width -> 3 columns, aspect 2.2', (tester) async {
      await pumpWithSize(tester, const Size(1300, 800));

      final grid = tester.widget<GridView>(find.byType(GridView));
      final delegate =
          grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;

      expect(delegate.crossAxisCount, 3);
      expect(delegate.childAspectRatio, 2.2);
      expect(delegate.mainAxisSpacing, 16);
      expect(delegate.crossAxisSpacing, 16);
    });

    testWidgets('>= 1400 width -> 4 columns, aspect 2.2', (tester) async {
      await pumpWithSize(tester, const Size(1500, 800));

      final grid = tester.widget<GridView>(find.byType(GridView));
      final delegate =
          grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;

      expect(delegate.crossAxisCount, 4);
      expect(delegate.childAspectRatio, 2.2);
      expect(delegate.mainAxisSpacing, 16);
      expect(delegate.crossAxisSpacing, 16);
    });
  });

  group('LearnPage + coursesProvider', () {
    testWidgets('smoke: renders LearnPage with data from provider', (
      tester,
    ) async {
      final courses = <Course>[_makeTestCourse()];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            coursesProvider.overrideWith((ref) => Future.value(courses)),
          ],
          child: const MaterialApp(home: LearnPage()),
        ),
      );

      await tester.pump();

      expect(find.text('Learn'), findsOneWidget);
      expect(find.text('Test course 1'), findsOneWidget);
      expect(find.byType(GridView), findsOneWidget);
    });
  });

  group('LearnBody navigation', () {
    testWidgets('tapping a course navigates to course details route', (
      tester,
    ) async {
      final courses = <Course>[_makeTestCourse()];

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) {
              return Scaffold(
                appBar: AppBar(title: const Text('Learn')),
                body: LearnBody(asyncCourses: AsyncData<List<Course>>(courses)),
              );
            },
          ),
          GoRoute(
            path: '/home/course/:id',
            builder: (context, state) {
              final id = state.pathParameters['id'];
              return Scaffold(
                body: Text('Course page $id', key: ValueKey('course-page-$id')),
              );
            },
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      await tester.pumpAndSettle();

      await tester.tap(find.byType(CourseCard).first);
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('course-page-1')), findsOneWidget);
    });
  });
}
