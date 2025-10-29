enum LessonType { theory, fillIn, quiz }

enum LessonStatus { locked, inProgress, completed }

class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    required this.order,
    this.sectionId = 'default',
    this.prereqIds = const [],
    this.posX = .5,
    this.posY = .5,
  });

  final String id;
  final String title;
  final LessonType type;
  final LessonStatus status;
  final int order;

  final String sectionId;
  final List<String> prereqIds;
  final double posX;
  final double posY;
}

class LessonHeader {
  LessonHeader({required this.id, required this.title, required this.order});
  final String id;
  final String title;
  final int order;
}

class LessonSlide {
  LessonSlide({
    required this.id,
    required this.contentType,
    required this.content,
    required this.order,
  });
  final String id;
  final String contentType;
  final Map<String, dynamic> content;
  final int order;
}

typedef LessonKey = ({String courseId, String lessonId});

extension LessonX on Lesson {
  bool isUnlocked(Set<String> completed) => prereqIds.every(completed.contains);
}
