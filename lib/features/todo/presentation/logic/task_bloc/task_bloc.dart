import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/usecase/use_case.dart';
import '../../../domain/usecases/add_task_usecase.dart';
import '../../../domain/usecases/delete_task_usecase.dart';
import '../../../domain/usecases/get_task_usecase.dart';
import '../../../domain/usecases/toggle_task_usecase.dart';
import '../../../domain/usecases/update_task_usecase.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasks _getTasks;
  final AddTask _addTask;
  final ToggleTask _toggleTask;
  final DeleteTask _deleteTask;
  final UpdateTask _updateTask;

  TaskBloc({
    required GetTasks getTasks,
    required AddTask addTask,
    required ToggleTask toggleTask,
    required DeleteTask deleteTask,
    required UpdateTask updateTask,
  })  : _getTasks = getTasks,
        _addTask = addTask,
        _toggleTask = toggleTask,
        _deleteTask = deleteTask,
        _updateTask = updateTask,
        super(TaskState.initial()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTaskEvent>(_onAddTask);
    on<ToggleTaskEvent>(_onToggleTask);
    on<DeleteTaskEvent>(_onDeleteTask);
    on<UpdateTaskEvent>(_onUpdateTask);
  }

  /// Helpers
  Future<void> _reload(Emitter<TaskState> emit) async {
    emit(state.copyWith(status: TaskStatus.loading, errorMessage: null));
    final either = await _getTasks(NoParams());
    either.fold(
      (err) => emit(state.copyWith(status: TaskStatus.failure, errorMessage: err.message)),
      (list) => emit(state.copyWith(status: TaskStatus.success, items: list, errorMessage: null)),
    );
  }

  /// Handlers
  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    await _reload(emit);
  }

  Future<void> _onAddTask(AddTaskEvent event, Emitter<TaskState> emit) async {
    // optional: optimistic UI uchun statusni loadingga olamiz
    emit(state.copyWith(status: TaskStatus.loading, errorMessage: null));
    final either = await _addTask(AddTaskParams(event.title, event.description));
    await either.fold(
      (err) async => emit(state.copyWith(status: TaskStatus.failure, errorMessage: err.message)),
      (_) async => _reload(emit),
    );
  }

  Future<void> _onToggleTask(ToggleTaskEvent event, Emitter<TaskState> emit) async {
    // optional: juda tez respons uchun optimistic update ham qilsa bo‘ladi.
    final either = await _toggleTask(ToggleTaskParams(event.id, event.done));
    await either.fold(
      (err) async => emit(state.copyWith(status: TaskStatus.failure, errorMessage: err.message)),
      (_) async => _reload(emit),
    );
  }

  Future<void> _onDeleteTask(DeleteTaskEvent event, Emitter<TaskState> emit) async {
    final either = await _deleteTask(DeleteTaskParams(event.id));
    await either.fold(
      (err) async => emit(state.copyWith(status: TaskStatus.failure, errorMessage: err.message)),
      (_) async => _reload(emit),
    );
  }

  Future<void> _onUpdateTask(UpdateTaskEvent event, Emitter<TaskState> emit) async {
    emit(state.copyWith(status: TaskStatus.loading, errorMessage: null));
    final either = await _updateTask(event.task);
    await either.fold(
      (err) async => emit(state.copyWith(status: TaskStatus.failure, errorMessage: err.message)),
      (_) async => _reload(emit),
    );
  }
}
