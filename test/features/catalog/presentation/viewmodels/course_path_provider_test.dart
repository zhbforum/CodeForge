import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/models/course_node.dart';
import 'package:mobile_app/core/models/lesson.dart';
import 'package:mobile_app/features/catalog/data/course_repository.dart';
import 'package:mobile_app/features/catalog/presentation/providers/course_path_provider.dart';
import 'package:mocktail/mocktail.dart';

// We intentionally avoid `const` here so the constructor runs at runtime
// and is visible in coverage. In a small test like this, the performance
// impact is negligible.
// ignore_for_file: prefer_const_constructors

class _MockCourseRepository extends Mock implements CourseRepository {}

void main() {
  group('coursePathProvider', () {
    test('maps lessons to CourseNodes with status/progress/order', () async {
      final repo = _MockCourseRepository();

      when(() => repo.getLessonsByCourseId('course-1')).thenAnswer(
        (_) async => <Lesson>[
          Lesson(
            id: 'l1',
            title: 'Lesson 1',
            type: LessonType.theory,
            status: LessonStatus.completed,
            order: 1,
          ),
          Lesson(
            id: 'l2',
            title: 'Lesson 2',
            type: LessonType.quiz,
            status: LessonStatus.inProgress,
            order: 2,
          ),
          Lesson(
            id: 'l3',
            title: 'Lesson 3',
            type: LessonType.fillIn,
            status: LessonStatus.locked,
            order: 3,
          ),
        ],
      );

      final container = ProviderContainer(
        overrides: [courseRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      final nodes = await container.read(coursePathProvider('course-1').future);

      verify(() => repo.getLessonsByCourseId('course-1')).called(1);

      expect(nodes, hasLength(3));
      expect(nodes, everyElement(isA<CourseNode>()));

      final n1 = nodes[0];
      final n2 = nodes[1];
      final n3 = nodes[2];

      expect(n1.id, 'l1');
      expect(n1.title, 'Lesson 1');
      expect(n1.order, 1);

      expect(n2.id, 'l2');
      expect(n2.title, 'Lesson 2');
      expect(n2.order, 2);

      expect(n3.id, 'l3');
      expect(n3.title, 'Lesson 3');
      expect(n3.order, 3);

      expect(n1.status, NodeStatus.done);
      expect(n2.status, NodeStatus.available);
      expect(n3.status, NodeStatus.locked);

      expect(n1.progress, 100);
      expect(n2.progress, 0);
      expect(n3.progress, 0);

      expect(n1.type, isNotNull);
      expect(n2.type, isNotNull);
      expect(n3.type, isNotNull);
    });
  });
}
