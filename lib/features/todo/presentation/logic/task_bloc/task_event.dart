import 'package:equatable/equatable.dart';

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

  const AddTaskEvent(this.title);

  @override
  List<Object?> get props => [title];
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
