import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/models/course_node.dart';
import 'package:mobile_app/core/models/module.dart';
import 'package:mobile_app/features/catalog/presentation/viewmodels/lesson_providers.dart';

typedef ModuleKey = ({String courseId, String moduleId});

final courseModulesProvider = FutureProvider.family
    .autoDispose<List<CourseModule>, String>((ref, courseId) async {
      final client = ref.read(supabaseProvider);
      final courseKey = int.tryParse(courseId) ?? courseId;

      final modRows = await client
          .from('modules')
          .select('id,title,"order"')
          .eq('course_id', courseKey)
          .order('order', ascending: true);

      final modules = (modRows as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      if (modules.isEmpty) return const <CourseModule>[];

      final moduleIds = modules
          .map<int>((m) => (m['id'] as num).toInt())
          .toList(growable: false);

      final lessonRows = await client
          .from('lessons')
          .select('id,module_id')
          .inFilter('module_id', moduleIds);

      final lessons = (lessonRows as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      final lessonsByModule = <int, List<int>>{};
      for (final row in lessons) {
        final mid = (row['module_id'] as num).toInt();
        final lid = (row['id'] as num).toInt();
        (lessonsByModule[mid] ??= <int>[]).add(lid);
      }

      final uid = client.auth.currentUser?.id;
      final completedLessonIds = <int>{};
      if (uid != null && lessons.isNotEmpty) {
        final allLessonIds = lessons
            .map<int>((l) => (l['id'] as num).toInt())
            .toList(growable: false);

        final upRows = await client
            .from('user_progress')
            .select('lesson_id,is_completed')
            .eq('user_id', uid)
            .inFilter('lesson_id', allLessonIds);

        for (final e in (upRows as List)) {
          final m = Map<String, dynamic>.from(e as Map);
          if (m['is_completed'] == true) {
            completedLessonIds.add((m['lesson_id'] as num).toInt());
          }
        }
      }

      final result = <CourseModule>[];
      for (final m in modules) {
        final mid = (m['id'] as num).toInt();
        final title = (m['title'] as String?) ?? 'Module';
        final order = (m['order'] as num?)?.toInt() ?? 1;

        final lessonIds = lessonsByModule[mid] ?? const <int>[];
        final total = lessonIds.length;
        var done = 0;
        for (final id in lessonIds) {
          if (completedLessonIds.contains(id)) done++;
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
      final client = ref.read(supabaseProvider);
      final modKey = int.tryParse(key.moduleId) ?? key.moduleId;

      final rows = await client
          .from('lessons')
          .select('id,title,"order"')
          .eq('module_id', modKey)
          .order('order', ascending: true);

      final lessons = (rows as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      final ids = lessons
          .map<int>((l) => (l['id'] as num).toInt())
          .toList(growable: false);

      final uid = client.auth.currentUser?.id;
      final completed = <int>{};
      if (uid != null && ids.isNotEmpty) {
        final upRows = await client
            .from('user_progress')
            .select('lesson_id,is_completed')
            .eq('user_id', uid)
            .inFilter('lesson_id', ids);

        for (final e in (upRows as List)) {
          final m = Map<String, dynamic>.from(e as Map);
          if (m['is_completed'] == true) {
            completed.add((m['lesson_id'] as num).toInt());
          }
        }
      }

      final result = <CourseNode>[];
      var unlockedGiven = false;

      for (final m in lessons) {
        final idNum = (m['id'] as num).toInt();
        final title = (m['title'] as String?) ?? 'Lesson';
        final order = (m['order'] as num?)?.toInt() ?? 0;

        NodeStatus status;
        if (completed.contains(idNum)) {
          status = NodeStatus.done;
        } else if (!unlockedGiven) {
          status = NodeStatus.available;
          unlockedGiven = true;
        } else {
          status = NodeStatus.locked;
        }

        result.add(
          CourseNode(
            id: '$idNum',
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
