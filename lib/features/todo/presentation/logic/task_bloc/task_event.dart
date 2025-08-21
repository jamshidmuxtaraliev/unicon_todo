import 'package:equatable/equatable.dart';

import '../../../domain/entities/task.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

/// DB'dan ro'yxatni olish
class LoadTasks extends TaskEvent {
  const LoadTasks();
}

/// Yangi vazifa qo'shish
class AddTaskEvent extends TaskEvent {
  final String title;
  final String description;

  const AddTaskEvent(this.title, this.description);

  @override
  List<Object?> get props => [title, description];
}

/// Vazifa holatini almashtirish
class ToggleTaskEvent extends TaskEvent {
  final int id;
  final bool done;

  const ToggleTaskEvent(this.id, this.done);

  @override
  List<Object?> get props => [id, done];
}

/// Vazifani o'chirish
class DeleteTaskEvent extends TaskEvent {
  final int id;

  const DeleteTaskEvent(this.id);

  @override
  List<Object?> get props => [id];
}

/// Vazifani tahrirlash
class UpdateTaskEvent extends TaskEvent {
  final TaskEntity task;
  const UpdateTaskEvent(this.task);

  @override
  List<Object?> get props => [task];
}
