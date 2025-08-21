import 'package:equatable/equatable.dart';

class TaskEntity extends Equatable {
  final int? id;
  final String title;
  final String description;
  final bool done;
  final DateTime created_at;
  final int? last_notified_at;

  const TaskEntity(
      {this.id, required this.title, required this.description, required this.done, required this.created_at, this.last_notified_at});

  @override
  List<Object?> get props => [id, title, description, done, created_at, last_notified_at];

  TaskEntity copyWith(
      {int? id, String? title, String? description, bool? done, DateTime? created_at, int? last_notified_at}) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      done: done ?? this.done,
      created_at: created_at ?? this.created_at,
      last_notified_at: last_notified_at ?? this.last_notified_at,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'done': done ? 1 : 0,
      'created_at': created_at.millisecondsSinceEpoch,
      'last_notified_at': last_notified_at,
    };
  }

  factory TaskEntity.fromMap(Map<String, dynamic> map) {
    return TaskEntity(
      id: map['id'] != null ? map['id'] as int : null,
      title: map['title'] as String,
      description: map['description'] as String,
      done: (map['done'] as int) == 1,
      created_at: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      last_notified_at: map['last_notified_at'] != null ? map['last_notified_at'] as int : null,
    );
  }
}
