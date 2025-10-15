import 'package:json_annotation/json_annotation.dart';

part 'course.g.dart';

@JsonSerializable()
class Course {
  Course({
    required this.id,
    required this.title,
    this.description,
    this.coverImage,
    this.isPublished,
  });

  factory Course.fromJson(Map<String, dynamic> json) => _$CourseFromJson(json);
  final int id;
  final String title;
  final String? description;
  final String? coverImage;
  final bool? isPublished;
  Map<String, dynamic> toJson() => _$CourseToJson(this);
}
