import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/models/course_node.dart';
import 'package:mobile_app/core/models/module.dart';
import 'package:mobile_app/core/services/api_service.dart';
import 'package:mobile_app/core/services/api_service_provider.dart';
import 'package:mobile_app/features/catalog/data/progress_store.dart';
import 'package:mobile_app/features/catalog/presentation/providers/module_providers.dart';
import 'package:mocktail/mocktail.dart';

class _MockApiService extends Mock implements ApiService {}

class _MockProgressStore extends Mock implements ProgressStore {}

void main() {
  group('courseModulesProvider', () {
    test(
      'returns empty list when there are no modules (modRows.isEmpty)',
      () async {
        final api = _MockApiService();
        final progressStore = _MockProgressStore();

        when(
          () => api.query(
            table: 'modules',
            select: any(named: 'select'),
            filters: {'course_id': 1},
            orderBy: any(named: 'orderBy'),
          ),
        ).thenAnswer((_) async => <Map<String, dynamic>>[]);

        final container = ProviderContainer(
          overrides: [
            apiServiceProvider.overrideWithValue(api),
            progressStoreProvider.overrideWithValue(progressStore),
          ],
        );
        addTearDown(container.dispose);

        final result = await container.read(courseModulesProvider('1').future);

        expect(result, isEmpty);
      },
    );

    test(
      'builds modules with total & done lessons and sorts by order',
      () async {
        final api = _MockApiService();
        final progressStore = _MockProgressStore();

        final modRows = <Map<String, dynamic>>[
          {'id': 10, 'title': 'Basics', 'order': 2},
          {'id': 5, 'title': 'Intro', 'order': 1},
        ];

        when(
          () => api.query(
            table: 'modules',
            select: 'id,title,"order"',
            filters: {'course_id': 1},
            orderBy: 'order',
          ),
        ).thenAnswer((_) async => modRows);

        final lessonRows = <Map<String, dynamic>>[
          {'id': 100, 'module_id': 10},
          {'id': 101, 'module_id': 10},
          {'id': 200, 'module_id': 5},
        ];

        when(
          () => api.query(
            table: 'lessons',
            select: 'id,module_id',
            filters: {
              'module_id': [10, 5],
            },
            orderBy: any(named: 'orderBy'),
          ),
        ).thenAnswer((_) async => lessonRows);

        when(() => progressStore.getLessonCompletion('1')).thenAnswer(
          (_) async => <String, bool>{'100': true, '101': false, '200': true},
        );

        final container = ProviderContainer(
          overrides: [
            apiServiceProvider.overrideWithValue(api),
            progressStoreProvider.overrideWithValue(progressStore),
          ],
        );
        addTearDown(container.dispose);

        final modules = await container.read(courseModulesProvider('1').future);

        expect(modules, hasLength(2));
        expect(modules, everyElement(isA<CourseModule>()));

        final first = modules[0];
        final second = modules[1];

        expect(first.id, '5');
        expect(first.title, 'Intro');
        expect(first.order, 1);
        expect(first.totalLessons, 1);
        expect(first.doneLessons, 1);

        expect(second.id, '10');
        expect(second.title, 'Basics');
        expect(second.order, 2);
        expect(second.totalLessons, 2);
        expect(second.doneLessons, 1);
      },
    );
  });

  group('modulePathProvider', () {
    test(
      'builds lesson CourseNodes with statuses done / available / locked',
      () async {
        final api = _MockApiService();
        final progressStore = _MockProgressStore();

        final rows = <Map<String, dynamic>>[
          {'id': 1, 'title': 'Lesson 1', 'order': 1, 'course_id': 1},
          {'id': 2, 'title': 'Lesson 2', 'order': 2, 'course_id': 1},
          {'id': 3, 'title': 'Lesson 3', 'order': 3, 'course_id': 1},
        ];

        when(
          () => api.query(
            table: 'lessons',
            select: 'id,title,"order",course_id',
            filters: {'module_id': 99},
            orderBy: 'order',
          ),
        ).thenAnswer((_) async => rows);

        when(() => progressStore.getLessonCompletion('1')).thenAnswer(
          (_) async => <String, bool>{'1': true, '2': false, '3': false},
        );

        final container = ProviderContainer(
          overrides: [
            apiServiceProvider.overrideWithValue(api),
            progressStoreProvider.overrideWithValue(progressStore),
          ],
        );
        addTearDown(container.dispose);

        const key = (courseId: 'ignored-course-id', moduleId: '99');

        final nodes = await container.read(modulePathProvider(key).future);

        expect(nodes, hasLength(3));
        expect(nodes, everyElement(isA<CourseNode>()));

        final n1 = nodes[0];
        final n2 = nodes[1];
        final n3 = nodes[2];

        expect(n1.id, '1');
        expect(n1.order, 1);
        expect(n2.id, '2');
        expect(n2.order, 2);
        expect(n3.id, '3');
        expect(n3.order, 3);

        expect(n1.type, NodeType.lesson);
        expect(n2.type, NodeType.lesson);
        expect(n3.type, NodeType.lesson);

        expect(n1.status, NodeStatus.done);
        expect(n2.status, NodeStatus.available);
        expect(n3.status, NodeStatus.locked);
      },
    );

    test('returns empty list when there are no lessons for module', () async {
      final api = _MockApiService();
      final progressStore = _MockProgressStore();

      when(
        () => api.query(
          table: 'lessons',
          select: any(named: 'select'),
          filters: {'module_id': 123},
          orderBy: any(named: 'orderBy'),
        ),
      ).thenAnswer((_) async => <Map<String, dynamic>>[]);

      when(
        () => progressStore.getLessonCompletion(any()),
      ).thenAnswer((_) async => <String, bool>{});

      final container = ProviderContainer(
        overrides: [
          apiServiceProvider.overrideWithValue(api),
          progressStoreProvider.overrideWithValue(progressStore),
        ],
      );
      addTearDown(container.dispose);

      const key = (courseId: '42', moduleId: '123');
      final nodes = await container.read(modulePathProvider(key).future);

      expect(nodes, isEmpty);
    });
  });
}
