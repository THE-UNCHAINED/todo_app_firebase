import 'package:cloud_firestore/cloud_firestore.dart';

class TodoModel {
  final String id;
  final String title;
  final String description;
  final bool completed;
  final DateTime createdAt;

  TodoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.completed,
    required this.createdAt,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      completed: json['completed'] as bool,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }
}
