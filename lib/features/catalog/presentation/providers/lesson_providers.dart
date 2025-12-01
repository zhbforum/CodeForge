import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/models/lesson.dart';
import 'package:mobile_app/core/services/api_service_provider.dart';
import 'package:mobile_app/features/catalog/data/progress_store.dart';

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
      final api = ref.read(apiServiceProvider);

      final idKey = int.tryParse(lessonId) ?? lessonId;

      final row = await api.single(
        table: 'lessons',
        select: 'id,title,"order"',
        idField: 'id',
        id: idKey,
      );

      return LessonHeader(
        id: (row['id'] is num)
            ? (row['id'] as num).toString()
            : row['id'].toString(),
        title: (row['title'] as String?) ?? 'Lesson',
        order: (row['order'] as num?)?.toInt() ?? 1,
      );
    });

final lessonSlidesProvider = FutureProvider.family
    .autoDispose<List<LessonSlide>, String>((ref, lessonId) async {
      final api = ref.read(apiServiceProvider);

      final idKey = int.tryParse(lessonId) ?? lessonId;

      final rows = await api.query(
        table: 'lesson_slides',
        select: 'id,lesson_id,"order",content_type,content',
        filters: {'lesson_id': idKey},
        orderBy: 'order',
      );

      return rows
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

final lessonQuizzesCompletedProvider = Provider.family
    .autoDispose<bool, String>((ref, String lessonId) {
      final slidesAsync = ref.watch(lessonSlidesProvider(lessonId));

      return slidesAsync.maybeWhen(
        data: (List<LessonSlide> slides) {
          final quizSlides = slides
              .where((s) => s.contentType == 'quiz')
              .toList();

          if (quizSlides.isEmpty) return true;

          for (final slide in quizSlides) {
            final revealed = ref.watch(quizRevealedProvider(slide.id));
            if (!revealed) {
              return false;
            }
          }

          return true;
        },
        orElse: () => false,
      );
    });
