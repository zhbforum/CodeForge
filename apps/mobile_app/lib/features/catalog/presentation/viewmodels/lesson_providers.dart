import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/models/lesson.dart';
import 'package:mobile_app/features/catalog/data/progress_store.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

final quizSelectedProvider = StateProvider.family.autoDispose<int?, String>(
  (ref, _) => null,
);

final quizRevealedProvider = StateProvider.family.autoDispose<bool, String>(
  (ref, _) => false,
);

final quizWrongIndexProvider = StateProvider.family.autoDispose<int?, String>(
  (ref, _) => null,
);

final lessonHeaderProvider = FutureProvider.family
    .autoDispose<LessonHeader, String>((ref, lessonId) async {
  final client = ref.read(supabaseProvider);
  final idKey = int.tryParse(lessonId) ?? lessonId;

  final row = await client
      .from('lessons')
      .select('id,title,"order"')
      .eq('id', idKey)
      .single();

  final m = Map<String, dynamic>.from(row as Map);
  return LessonHeader(
    id: (m['id'] is num) ? (m['id'] as num).toString() : m['id'].toString(),
    title: (m['title'] as String?) ?? 'Lesson',
    order: (m['order'] as num?)?.toInt() ?? 1,
  );
});

final lessonSlidesProvider = FutureProvider.family
    .autoDispose<List<LessonSlide>, String>((ref, lessonId) async {
  final client = ref.read(supabaseProvider);
  final idKey = int.tryParse(lessonId) ?? lessonId;

  final rows = await client
      .from('lesson_slides')
      .select('id,lesson_id,"order",content_type,content')
      .eq('lesson_id', idKey)
      .order('order', ascending: true);

  final list = (rows as List)
      .map((e) => Map<String, dynamic>.from(e as Map))
      .map(
        (m) => LessonSlide(
          id: (m['id'] is num)
              ? (m['id'] as num).toString()
              : m['id'].toString(),
          contentType: m['content_type'] as String,
          content: Map<String, dynamic>.from(m['content'] as Map),
          order: (m['order'] as num?)?.toInt() ?? 1,
        ),
      )
      .toList();

  return list;
});

final currentOrderProvider = StateProvider.family.autoDispose<int, String>(
  (ref, _) => 1,
);

final lessonCompletedProvider = FutureProvider.family
    .autoDispose<bool, LessonKey>((ref, key) async {
  final store = ref.read(progressStoreProvider);
  final map = await store.getLessonCompletion(key.courseId);
  return map[key.lessonId] ?? false;
});
