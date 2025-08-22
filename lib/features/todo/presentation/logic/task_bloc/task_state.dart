import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:unicon_todo/features/todo/domain/entities/task.dart';

class TaskState extends Equatable {
  final FormzSubmissionStatus status;
  final List<TaskEntity> items;
  final String? errorMessage;

  const TaskState({required this.status, required this.items, this.errorMessage});

  factory TaskState.initial() => const TaskState(status: FormzSubmissionStatus.initial, items: []);

  TaskState copyWith({
    FormzSubmissionStatus? status,
    List<TaskEntity>? items,
    String? errorMessage, // null kelsa ham override bo'lsin desangiz explicit yuboring
  }) {
    return TaskState(status: status ?? this.status, items: items ?? this.items, errorMessage: errorMessage);
  }

  @override
  List<Object?> get props => [status, items, errorMessage];
}
