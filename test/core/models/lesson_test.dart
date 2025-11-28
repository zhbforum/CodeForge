import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/models/lesson.dart';

void main() {
  group('LessonX.isUnlocked', () {
    Lesson lessonWithPrereqs(List<String> prereqIds) {
      return Lesson(
        id: 'lesson-1',
        title: 'Test lesson',
        type: LessonType.theory,
        status: LessonStatus.locked,
        order: 1,
        sectionId: 'section-1',
        prereqIds: prereqIds,
      );
    }

    test('returns true when there are no prerequisites', () {
      final lesson = lessonWithPrereqs([]);

      final result = lesson.isUnlocked(<String>{});

      expect(result, isTrue);
    });

    test('returns true when all prerequisites are completed', () {
      final lesson = lessonWithPrereqs(['l1', 'l2', 'l3']);

      final completed = <String>{'l1', 'l2', 'l3', 'extra'};

      final result = lesson.isUnlocked(completed);

      expect(result, isTrue);
    });

    test('returns false when at least one prerequisite is missing', () {
      final lesson = lessonWithPrereqs(['l1', 'l2', 'l3']);

      final completed = <String>{'l1', 'l3'};

      final result = lesson.isUnlocked(completed);

      expect(result, isFalse);
    });
  });
}
