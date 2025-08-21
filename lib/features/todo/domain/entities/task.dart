import 'package:equatable/equatable.dart';

class TaskEntity extends Equatable {
  final int? id;
  final String title;
  final bool done;
  final DateTime created_at;

  const TaskEntity({this.id, required this.title, required this.done, required this.created_at});

  @override
  List<Object?> get props => [id, title, done, created_at];

  TaskEntity copyWith({int? id, String? title, bool? done, DateTime? created_at}) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      done: done ?? this.done,
      created_at: created_at ?? this.created_at,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title, 'done': done ? 1 : 0, 'created_at': created_at.millisecondsSinceEpoch};
  }

  factory TaskEntity.fromMap(Map<String, dynamic> map) {
    return TaskEntity(
      id: map['id'] != null ? map['id'] as int : null,
      title: map['title'] as String,
      done: (map['done'] as int) == 1,
      created_at: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }
}
