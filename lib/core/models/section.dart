import 'package:mobile_app/core/models/lesson.dart';

class Section {
  const Section({required this.id, required this.title, required this.lessons});

  final String id;
  final String title;
  final List<Lesson> lessons;
}
