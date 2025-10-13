import 'dart:math';
import 'package:mobile_app/core/models/course.dart';
import 'package:mobile_app/core/models/lesson.dart';
import 'package:mobile_app/core/models/track.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CourseRepository {
  CourseRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<Course>> getCourses() async {
    final rows = await _client
        .from('courses')
        .select('id,title,description,cover_image,is_published,created_at')
        .eq('is_published', true)
        .order('created_at', ascending: true);

    return (rows as List)
        .map((row) => Course.fromJson(Map<String, dynamic>.from(row as Map)))
        .toList();
  }

  Future<Course> getCourse(String id) async {
    final row = await _client
        .from('courses')
        .select('id,title,description,cover_image,is_published,created_at')
        .eq('id', _normalizeId(id))
        .single();

    return Course.fromJson(Map<String, dynamic>.from(row as Map));
  }

  Future<List<Lesson>> getLessonsByCourseId(String courseId) async {
    final uid = _client.auth.currentUser?.id;

    final base = _client
        .from('lessons')
        .select('id,title,"order",user_progress(is_completed,user_id)')
        .eq('course_id', _normalizeId(courseId));

    final filtered = uid != null ? base.eq('user_progress.user_id', uid) : base;

    final rows = await filtered.order('order', ascending: true);

    final list = (rows as List)
        .map((r) => Map<String, dynamic>.from(r as Map))
        .toList();

    if (list.isEmpty) return _fallbackLessons();

    list.sort(
      (a, b) => ((a['order'] ?? 0) as int).compareTo((b['order'] ?? 0) as int),
    );

    final completedByLessonId = <String, bool>{};
    for (final m in list) {
      final upRaw = (m['user_progress'] as List?) ?? const [];
      final up = upRaw
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(growable: false);

      final isDone = up.any((e) => e['is_completed'] == true);
      completedByLessonId[_asString(m['id'])] = isDone;
    }

    var inProgressUsed = false;
    final result = <Lesson>[];

    for (var i = 0; i < list.length; i++) {
      final m = list[i];

      final dbId = _asString(m['id']);
      final title = m['title'] as String? ?? 'Lesson ${i + 1}';
      final order = (m['order'] as num?)?.toInt() ?? (i + 1);

      final prevId = i == 0 ? null : _asString(list[i - 1]['id']);
      final prevCompleted = i == 0 || (completedByLessonId[prevId!] ?? false);
      final thisCompleted = completedByLessonId[dbId] ?? false;

      final LessonStatus status;
      if (thisCompleted) {
        status = LessonStatus.completed;
      } else if (!inProgressUsed && prevCompleted) {
        inProgressUsed = true;
        status = LessonStatus.inProgress;
      } else {
        status = LessonStatus.locked;
      }

      final (x, y) = _autoLayout(i, list.length);

      result.add(
        Lesson(
          id: dbId,
          title: title,
          type: LessonType.theory,
          status: status,
          order: order,
          sectionId: 'intro',
          prereqIds: i == 0 ? const [] : [_asString(list[i - 1]['id'])],
          posX: x,
          posY: y,
        ),
      );
    }

    return result;
  }

  Future<void> markLessonDone({
    required String courseId,
    required String lessonId,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('Not authenticated');
    }

    final lessonKey = int.tryParse(lessonId) ?? lessonId;

    await _client.from('user_progress').upsert({
      'user_id': userId,
      'lesson_id': lessonKey,
      'is_completed': true,
      'completed_at': DateTime.now().toIso8601String(),
    });
  }

  @Deprecated('Use getCourses() + navigate by real course id (int)')
  Future<List<Track>> getTracks() async {
    final rows = await _client
        .from('courses')
        .select('id,title,description,is_published,created_at')
        .eq('is_published', true)
        .order('created_at', ascending: true);

    return (rows as List).map((row) {
      final m = Map<String, dynamic>.from(row as Map);
      return Track(
        id: TrackId.fullstack,
        title: m['title'] as String? ?? 'Untitled',
        subtitle: m['description'] as String? ?? '',
        progress: 0,
      );
    }).toList();
  }

  @Deprecated('Navigate by real course id and call getLessonsByCourseId')
  Future<List<Lesson>> getLessons(TrackId id) async {
    final courseId = await _findCourseIdByTitleKeyword(id);
    if (courseId == null) return _fallbackLessons();
    return getLessonsByCourseId(courseId);
  }

  Future<String?> _findCourseIdByTitleKeyword(TrackId id) async {
    final kw = _titleKeywordFor(id);
    if (kw == null) return null;

    final like = await _client
        .from('courses')
        .select('id,title')
        .eq('is_published', true)
        .ilike('title', '%$kw%')
        .limit(1);

    if ((like as List).isEmpty) return null;
    final m = Map<String, dynamic>.from(like.first as Map);
    return _asString(m['id']);
  }

  String? _titleKeywordFor(TrackId id) => switch (id) {
    TrackId.python => 'python',
    TrackId.fullstack => 'full',
    TrackId.backend => 'back',
    TrackId.vanillaJs => 'vanilla',
    TrackId.typescript => 'type',
    TrackId.html => 'html',
    TrackId.css => 'css',
  };

  (double, double) _autoLayout(int index, int total) {
    final t = max(1, total);
    final x = 0.1 + (0.8 * (index / max(1, t - 1)));
    final y = index.isEven ? 0.30 : 0.42;
    return (x, y);
  }

  List<Lesson> _fallbackLessons() => const [
    Lesson(
      id: 'intro',
      title: 'Introduction',
      type: LessonType.theory,
      status: LessonStatus.inProgress,
      order: 1,
      sectionId: 'intro',
      posX: .20,
      posY: .30,
    ),
    Lesson(
      id: 'practice_1',
      title: 'First Practice',
      type: LessonType.fillIn,
      status: LessonStatus.locked,
      order: 2,
      sectionId: 'intro',
      prereqIds: ['intro'],
      posX: .40,
      posY: .40,
    ),
  ];

  String _asString(dynamic v) =>
      v is String ? v : (v is num ? v.toString() : '$v');

  Object _normalizeId(String id) => int.tryParse(id) ?? id;
}
