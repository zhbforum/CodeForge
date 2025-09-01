import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/models/lesson.dart';
import 'package:mobile_app/core/models/track.dart';

abstract class TrackRepository {
  Future<List<Track>> getTracks();
  Future<List<Lesson>> getLessons(TrackId id);
}

final trackRepositoryProvider = Provider<TrackRepository>(
  (ref) => MockTrackRepository(),
);

class MockTrackRepository implements TrackRepository {
  @override
  Future<List<Track>> getTracks() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return const <Track>[
      Track(
        id: TrackId.fullstack,
        title: 'Full-Stack Developer',
        subtitle: 'HTML • CSS • JS • React',
        progress: 0.18,
      ),
      Track(
        id: TrackId.python,
        title: 'Python Developer',
        subtitle: 'Syntax • OOP • Tools',
        progress: 0,
      ),
      Track(
        id: TrackId.backend,
        title: 'Back-End Developer',
        subtitle: 'Node.js • DB • Auth',
        progress: 0,
      ),
      Track(
        id: TrackId.vanillaJs,
        title: 'Vanilla JS',
        subtitle: 'Core JavaScript',
        progress: 0.35,
      ),
      Track(
        id: TrackId.typescript,
        title: 'TypeScript',
        subtitle: 'Types • Tooling',
        progress: 0,
      ),
      Track(
        id: TrackId.html,
        title: 'HTML',
        subtitle: 'Elements • Semantics',
        progress: 1,
      ),
      Track(
        id: TrackId.css,
        title: 'CSS',
        subtitle: 'Selectors • Layout',
        progress: 0.62,
      ),
    ];
  }

  @override
  Future<List<Lesson>> getLessons(TrackId id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return switch (id) {
      TrackId.fullstack => const [
        Lesson(
          id: 'fs_intro',
          title: 'Introduction to Full-Stack',
          type: LessonType.theory,
          status: LessonStatus.completed,
          order: 1,
          sectionId: 'intro',
          posX: .10,
          posY: .30,
        ),
        Lesson(
          id: 'fs_http',
          title: 'HTTP Basics',
          type: LessonType.theory,
          status: LessonStatus.inProgress,
          order: 2,
          sectionId: 'intro',
          prereqIds: ['fs_intro'],
          posX: .32,
          posY: .42,
        ),
        Lesson(
          id: 'fs_html_basics',
          title: 'HTML Basics',
          type: LessonType.theory,
          status: LessonStatus.locked,
          order: 3,
          sectionId: 'intro',
          prereqIds: ['fs_http'],
          posX: .55,
          posY: .28,
        ),
        Lesson(
          id: 'fs_css_selectors',
          title: 'CSS Selectors (Fill-in)',
          type: LessonType.fillIn,
          status: LessonStatus.locked,
          order: 4,
          sectionId: 'intro',
          prereqIds: ['fs_html_basics'],
          posX: .78,
          posY: .40,
        ),
      ],

      _ => const [
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
          posY: .40,
        ),
      ],
    };
  }
}
