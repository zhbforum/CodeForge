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

  Future<List<Track>> getTracks() async {
    final rows = await _client
        .from('courses')
        .select('id,title,description,slug,is_published,created_at')
        .eq('is_published', true)
        .order('created_at', ascending: true);

    return (rows as List).map((row) {
      final m = Map<String, dynamic>.from(row as Map);
      final title = m['title'] as String? ?? 'Untitled';
      final subtitle = m['description'] as String? ?? '';
      final slug = m['slug'] as String?;

      return Track(
        id: _resolveTrackId(slug, title),
        title: title,
        subtitle: subtitle,
        progress: 0.toDouble(),
      );
    }).toList();
  }

  Future<List<Lesson>> getLessons(TrackId id) async {
    final course = await _findCourseRowForTrack(id);
    if (course == null) return _fallbackLessons();

    final courseId = (course['id'] as num).toInt();

    final rows = await _client
        .from('lessons')
        .select('id,title,"order",user_progress(is_completed)')
        .eq('course_id', courseId)
        .order('order', ascending: true);

    if ((rows as List).isEmpty) return _fallbackLessons();

    final lessonsRaw =
        rows.map((r) => Map<String, dynamic>.from(r as Map)).toList()
          ..sort(
            (a, b) => ((a['order'] ?? 0) as int)
                .compareTo((b['order'] ?? 0) as int),
          );

    final completed = <int, bool>{};
    for (var i = 0; i < lessonsRaw.length; i++) {
      final upRaw = (lessonsRaw[i]['user_progress'] as List?) ?? const [];
      final up = upRaw
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(growable: false);
      final isCompleted =
          up.isNotEmpty && (up.first['is_completed'] as bool? ?? false);
      completed[i] = isCompleted;
    }

    bool inProgressUsed = false;
    final result = <Lesson>[];

    for (var i = 0; i < lessonsRaw.length; i++) {
      final m = lessonsRaw[i];
      final dbId = (m['id'] as num).toInt();
      final title = m['title'] as String? ?? 'Lesson ${i + 1}';
      final order = (m['order'] as num?)?.toInt() ?? i + 1;

      final prevCompleted = i == 0 || (completed[i - 1] ?? false);
      final thisCompleted = completed[i] ?? false;

      final status = thisCompleted
          ? LessonStatus.completed
          : (!inProgressUsed && prevCompleted)
              ? (inProgressUsed = true, LessonStatus.inProgress).$2
              : LessonStatus.locked;

      final (x, y) = _autoLayout(i, lessonsRaw.length);

      result.add(
        Lesson(
          id: 'l$dbId',
          title: title,
          type: LessonType.theory,
          status: status,
          order: order,
          sectionId: 'intro',
          prereqIds: i == 0
              ? const []
              : [
                  'l${(lessonsRaw[i - 1]['id'] as num).toInt()}',
                ],
          posX: x,
          posY: y,
        ),
      );
    }

    return result;
  }

  TrackId _resolveTrackId(String? slug, String title) {
    if (slug != null) {
      try {
        return TrackId.values.byName(slug);
      } catch (_) {}
    }
    final t = title.toLowerCase();
    if (t.contains('python')) return TrackId.python;
    if (t.contains('full')) return TrackId.fullstack;
    if (t.contains('back')) return TrackId.backend;
    if (t.contains('vanilla')) return TrackId.vanillaJs;
    if (t.contains('type')) return TrackId.typescript;
    if (t.contains('html')) return TrackId.html;
    if (t.contains('css')) return TrackId.css;
    return TrackId.fullstack;
  }

  Future<Map<String, dynamic>?> _findCourseRowForTrack(TrackId id) async {
    final bySlug = await _client
        .from('courses')
        .select('id,title,slug')
        .eq('is_published', true)
        .eq('slug', id.name)
        .limit(1);

    if ((bySlug as List).isNotEmpty) {
      return Map<String, dynamic>.from(bySlug.first as Map);
    }

    final kw = _titleKeywordFor(id);
    if (kw != null) {
      final like = await _client
          .from('courses')
          .select('id,title,slug')
          .eq('is_published', true)
          .ilike('title', '%$kw%')
          .limit(1);

      if ((like as List).isNotEmpty) {
        return Map<String, dynamic>.from(like.first as Map);
      }
    }

    final any = await _client
        .from('courses')
        .select('id,title,slug')
        .eq('is_published', true)
        .limit(1);

    return (any as List).isEmpty
        ? null
        : Map<String, dynamic>.from(any.first as Map);
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
}
