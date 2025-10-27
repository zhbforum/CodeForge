import 'package:flutter/foundation.dart';

enum NodeType { lesson, practice, quiz, boss }
enum NodeStatus { locked, available, done }

@immutable
class CourseNode {
  const CourseNode({
    required this.id,
    required this.title,
    required this.type,
    this.status = NodeStatus.locked,
    this.progress = 0,
    this.prerequisites = const [],
    this.order = 0,
    this.moduleId,
    this.moduleTitle,
    this.moduleOrder,
  });

  final String id;
  final String title;
  final NodeType type;
  final NodeStatus status;
  final int progress;
  final List<String> prerequisites;
  final int order;

  final String? moduleId;
  final String? moduleTitle;
  final int? moduleOrder;

  CourseNode copyWith({
    String? id,
    String? title,
    NodeType? type,
    NodeStatus? status,
    int? progress,
    List<String>? prerequisites,
    int? order,
    String? moduleId,
    String? moduleTitle,
    int? moduleOrder,
  }) {
    return CourseNode(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      prerequisites: prerequisites ?? this.prerequisites,
      order: order ?? this.order,
      moduleId: moduleId ?? this.moduleId,
      moduleTitle: moduleTitle ?? this.moduleTitle,
      moduleOrder: moduleOrder ?? this.moduleOrder,
    );
  }
}
