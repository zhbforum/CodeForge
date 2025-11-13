import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/models/course_node.dart';
import 'package:mobile_app/core/models/module.dart';
import 'package:mobile_app/core/services/api_service_provider.dart';
import 'package:mobile_app/features/catalog/data/progress_store.dart';

typedef ModuleKey = ({String courseId, String moduleId});

final courseModulesProvider = FutureProvider.family
    .autoDispose<List<CourseModule>, String>((ref, courseId) async {
      final api = ref.read(apiServiceProvider);
      final progressStore = ref.read(progressStoreProvider);

      final courseKey = int.tryParse(courseId) ?? courseId;

      final modRows = await api.query(
        table: 'modules',
        select: 'id,title,"order"',
        filters: {'course_id': courseKey},
        orderBy: 'order',
      );

      if (modRows.isEmpty) return const <CourseModule>[];

      final modules = modRows;

      final moduleIds = modules
          .map<int>((m) => (m['id'] as num).toInt())
          .toList(growable: false);

      final lessonRows = await api.query(
        table: 'lessons',
        select: 'id,module_id',
        filters: {'module_id': moduleIds},
      );

      final lessons = lessonRows;

      final lessonsByModule = <int, List<int>>{};
      for (final row in lessons) {
        final mid = (row['module_id'] as num).toInt();
        final lid = (row['id'] as num).toInt();
        (lessonsByModule[mid] ??= <int>[]).add(lid);
      }

      final completion = await progressStore.getLessonCompletion(courseId);

      final result = <CourseModule>[];

      for (final m in modules) {
        final mid = (m['id'] as num).toInt();
        final title = (m['title'] as String?) ?? 'Module';
        final order = (m['order'] as num?)?.toInt() ?? 1;

        final lessonIds = lessonsByModule[mid] ?? const <int>[];
        final total = lessonIds.length;

        var done = 0;
        for (final id in lessonIds) {
          if (completion[id.toString()] ?? false) {
            done++;
          }
        }

        result.add(
          CourseModule(
            id: '$mid',
            title: title,
            order: order,
            totalLessons: total,
            doneLessons: done,
          ),
        );
      }

      result.sort((a, b) => a.order.compareTo(b.order));
      return result;
    });

final modulePathProvider = FutureProvider.family
    .autoDispose<List<CourseNode>, ModuleKey>((ref, key) async {
      final api = ref.read(apiServiceProvider);
      final progressStore = ref.read(progressStoreProvider);

      final modKey = int.tryParse(key.moduleId) ?? key.moduleId;

      final rows = await api.query(
        table: 'lessons',
        select: 'id,title,"order",course_id',
        filters: {'module_id': modKey},
        orderBy: 'order',
      );

      final courseId = rows.isNotEmpty
          ? rows.first['course_id'].toString()
          : key.courseId;

      final completion = await progressStore.getLessonCompletion(courseId);

      final result = <CourseNode>[];
      var unlockedGiven = false;

      for (final m in rows) {
        final idNum = (m['id'] as num).toInt();
        final id = idNum.toString();

        final title = m['title'] as String? ?? 'Lesson';
        final order = (m['order'] as num?)?.toInt() ?? 0;

        final isDone = completion[id] ?? false;

        NodeStatus status;
        if (isDone) {
          status = NodeStatus.done;
        } else if (!unlockedGiven) {
          status = NodeStatus.available;
          unlockedGiven = true;
        } else {
          status = NodeStatus.locked;
        }

        result.add(
          CourseNode(
            id: id,
            title: title,
            type: NodeType.lesson,
            status: status,
            order: order,
            moduleId: key.moduleId,
          ),
        );
      }

      return result;
    });
