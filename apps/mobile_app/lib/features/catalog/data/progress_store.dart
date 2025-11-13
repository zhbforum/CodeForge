import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRequiredException implements Exception {
  @override
  String toString() => 'AuthRequiredException';
}

abstract class ProgressStore {
  Future<Map<String, bool>> getLessonCompletion(String courseId);

  Future<void> setLessonCompleted({
    required String courseId,
    required String lessonId,
    required bool completed,
  });
}

class LocalProgressStore implements ProgressStore {
  static String _key(String courseId) => 'progress_course:$courseId';

  @override
  Future<Map<String, bool>> getLessonCompletion(String courseId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(courseId));
    if (raw == null) return <String, bool>{};

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((k, v) => MapEntry(k, v == true));
  }

  @override
  Future<void> setLessonCompleted({
    required String courseId,
    required String lessonId,
    required bool completed,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(courseId));

    final map = raw == null
        ? <String, bool>{}
        : (jsonDecode(raw) as Map<String, dynamic>).map(
            (k, v) => MapEntry(k, v == true),
          );

    map[lessonId] = completed;
    await prefs.setString(_key(courseId), jsonEncode(map));
  }

  Future<void> clearCourse(String courseId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(courseId));
  }
}

class RemoteProgressStore implements ProgressStore {
  RemoteProgressStore(this._client);
  final SupabaseClient _client;

  @override
  Future<Map<String, bool>> getLessonCompletion(String courseId) async {
    final session = _client.auth.currentSession;
    if (session == null) return <String, bool>{};

    final filterCourseId = int.tryParse(courseId) ?? courseId;

    final rows = await _client
        .from('user_progress')
        .select('lesson_id,is_completed,lessons!inner(course_id)')
        .eq('user_id', session.user.id)
        .eq('lessons.course_id', filterCourseId);

    final list = (rows as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    final result = <String, bool>{};
    for (final r in list) {
      final lid = r['lesson_id'];
      final done = r['is_completed'] == true;
      result[(lid is num ? lid.toString() : lid as String)] = done;
    }
    return result;
  }

  @override
  Future<void> setLessonCompleted({
    required String courseId,
    required String lessonId,
    required bool completed,
  }) async {
    final session = _client.auth.currentSession;
    if (session == null) throw AuthRequiredException();

    final lessonKey = int.tryParse(lessonId) ?? lessonId;

    await _client.from('user_progress').upsert({
      'user_id': session.user.id,
      'lesson_id': lessonKey,
      'is_completed': completed,
      if (completed) 'completed_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id,lesson_id');
  }

  Future<void> setCurrentSlide({
    required String lessonId,
    required int order,
  }) async {
    final session = _client.auth.currentSession;
    if (session == null) throw AuthRequiredException();

    final lessonKey = int.tryParse(lessonId) ?? lessonId;

    await _client.from('user_progress').upsert({
      'user_id': session.user.id,
      'lesson_id': lessonKey,
      'current_slide': order,
    }, onConflict: 'user_id,lesson_id');
  }
}

final progressStoreProvider = Provider<ProgressStore>((ref) {
  final client = Supabase.instance.client;
  final session = client.auth.currentSession;
  final isAnon = session?.user.isAnonymous ?? true;

  if (!isAnon && session != null) {
    return RemoteProgressStore(client);
  } else {
    return LocalProgressStore();
  }
});

Future<void> migrateLocalToRemoteForCourse(String courseId) async {
  final client = Supabase.instance.client;
  final session = client.auth.currentSession;
  if (session == null) return;

  final local = LocalProgressStore();
  final remote = RemoteProgressStore(client);

  final localMap = await local.getLessonCompletion(courseId);
  if (localMap.isEmpty) return;

  for (final entry in localMap.entries) {
    if (entry.value) {
      await remote.setLessonCompleted(
        courseId: courseId,
        lessonId: entry.key,
        completed: true,
      );
    }
  }
  await local.clearCourse(courseId);
}
