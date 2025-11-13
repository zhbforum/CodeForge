import 'dart:math';

import 'package:mobile_app/core/models/course.dart';
import 'package:mobile_app/core/models/lesson.dart';
import 'package:mobile_app/core/models/track.dart';
import 'package:mobile_app/core/services/api_service.dart';
import 'package:mobile_app/core/services/error_handler.dart';
import 'package:mobile_app/features/catalog/data/progress_store.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CourseRepository {
  CourseRepository({
    ApiService? api,
    ErrorHandler? errorHandler,
  })  : _api = api ?? ApiService(),
        _errorHandler = errorHandler ?? ErrorHandler();

  final ApiService _api;
  final ErrorHandler _errorHandler;

  Future<List<Course>> getCourses() async {
    try {
      final rows = await _api.query(
        table: 'courses',
        select: 'id,title,description,cover_image,is_published,created_at',
        filters: {'is_published': true},
        orderBy: 'created_at',
      );

      return rows.map(Course.fromJson).toList();
    } catch (e, st) {
      _errorHandler.handle(e, st);
      rethrow;
    }
  }

  Future<Course> getCourse(String id) async {
    try {
      final rows = await _api.query(
        table: 'courses',
        select: 'id,title,description,cover_image,is_published,created_at',
        filters: {'id': _normalizeId(id)},
      );

      if (rows.isEmpty) {
        throw Exception('Course not found');
      }

      return Course.fromJson(rows.first);
    } catch (e, st) {
      _errorHandler.handle(e, st);
      rethrow;
    }
  }

  Future<List<Lesson>> getLessonsByCourseId(String courseId) async {
    try {
      final client = Supabase.instance.client;
      final session = client.auth.currentSession;

      final rows = await _api.query(
        table: 'lessons',
        select: 'id,title,"order"',
        filters: {'course_id': _normalizeId(courseId)},
        orderBy: 'order',
      );

      if (rows.isEmpty) return _fallbackLessons();

      final store = session == null
          ? LocalProgressStore()
          : RemoteProgressStore(client);

      final completionMap = await store.getLessonCompletion(courseId);

      rows.sort(
        (a, b) =>
            ((a['order'] ?? 0) as int).compareTo((b['order'] ?? 0) as int),
      );

      var nextShouldBeInProgress = true;
      final result = <Lesson>[];

      for (var i = 0; i < rows.length; i++) {
        final m = rows[i];

        final id = _asString(m['id']);
        final title = m['title'] as String? ?? 'Lesson ${i + 1}';
        final order = (m['order'] as num?)?.toInt() ?? (i + 1);

        final completed = completionMap[id] ?? false;

        late final LessonStatus status;

        if (completed) {
          status = LessonStatus.completed;
        } else if (nextShouldBeInProgress) {
          status = LessonStatus.inProgress;
          nextShouldBeInProgress = false;
        } else {
          status = LessonStatus.locked;
        }

        final (x, y) = _autoLayout(i, rows.length);

        result.add(
          Lesson(
            id: id,
            title: title,
            type: LessonType.theory,
            status: status,
            order: order,
            sectionId: 'intro',
            prereqIds: i == 0 ? const [] : [_asString(rows[i - 1]['id'])],
            posX: x,
            posY: y,
          ),
        );
      }

      return result;
    } catch (e, st) {
      _errorHandler.handle(e, st);
      rethrow;
    }
  }

  Future<void> markLessonDone({
    required String courseId,
    required String lessonId,
  }) async {
    final client = Supabase.instance.client;
    final session = client.auth.currentSession;

    if (session == null) {
      throw Exception('Not authenticated');
    }

    final lessonKey = int.tryParse(lessonId) ?? lessonId;

    await _api.upsert(
      table: 'user_progress',
      values: {
        'user_id': session.user.id,
        'lesson_id': lessonKey,
        'is_completed': true,
        'completed_at': DateTime.now().toIso8601String(),
      },
      onConflict: 'user_id,lesson_id',
    );
  }

  @Deprecated('Use getCourses() + navigate by real course id (int)')
  Future<List<Track>> getTracks() async {
    final rows = await _api.query(
      table: 'courses',
      select: 'id,title,description,is_published,created_at',
      filters: {'is_published': true},
      orderBy: 'created_at',
    );

    return rows.map((row) {
      final m = Map<String, dynamic>.from(row);
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

    final rows = await _api.query(
      table: 'courses',
      select: 'id,title',
      filters: {
        'is_published': true,
        'title': 'like:$kw',
      },
      limit: 1,
    );

    if (rows.isEmpty) return null;

    return _asString(rows.first['id']);
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
