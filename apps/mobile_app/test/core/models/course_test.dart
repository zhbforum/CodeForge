import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/models/course.dart';

void main() {
  group('Course', () {
    test('fromJson parses all fields correctly', () {
      final json = <String, dynamic>{
        'id': 1,
        'title': 'Fullstack course',
        'description': 'Learn fullstack basics',
        'coverImage': 'fullstack.png',
        'isPublished': true,
      };

      final course = Course.fromJson(json);

      expect(course.id, 1);
      expect(course.title, 'Fullstack course');
      expect(course.description, 'Learn fullstack basics');
      expect(course.coverImage, 'fullstack.png');
      expect(course.isPublished, isTrue);
    });

    test('toJson returns correct map', () {
      final course = Course(
        id: 2,
        title: 'Backend course',
        description: 'APIs and databases',
        coverImage: 'backend.png',
        isPublished: false,
      );

      final json = course.toJson();

      expect(json['id'], 2);
      expect(json['title'], 'Backend course');
      expect(json['description'], 'APIs and databases');
      expect(json['coverImage'], 'backend.png');
      expect(json['isPublished'], false);
    });

    test('toJson/fromJson roundtrip keeps data', () {
      final original = Course(
        id: 3,
        title: 'Python course',
        description: 'Python basics',
      );

      final json = original.toJson();
      final restored = Course.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.description, original.description);
      expect(restored.coverImage, original.coverImage);
      expect(restored.isPublished, original.isPublished);
    });
  });
}
