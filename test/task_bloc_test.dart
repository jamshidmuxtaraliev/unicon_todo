import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:mocktail/mocktail.dart';
import 'package:unicon_todo/core/error/error_model.dart';
import 'package:unicon_todo/core/usecase/use_case.dart';
import 'package:unicon_todo/features/todo/domain/entities/task.dart';
import 'package:unicon_todo/features/todo/domain/usecases/add_task_usecase.dart';
import 'package:unicon_todo/features/todo/domain/usecases/delete_task_usecase.dart';
import 'package:unicon_todo/features/todo/domain/usecases/get_task_usecase.dart';
import 'package:unicon_todo/features/todo/domain/usecases/toggle_task_usecase.dart';
import 'package:unicon_todo/features/todo/domain/usecases/update_task_usecase.dart';
import 'package:unicon_todo/features/todo/presentation/logic/task_bloc/task_bloc.dart';
import 'package:unicon_todo/features/todo/presentation/logic/task_bloc/task_event.dart';
import 'package:unicon_todo/features/todo/presentation/logic/task_bloc/task_state.dart';

class UpdateTaskParams {
  final TaskEntity task;

  UpdateTaskParams(this.task);
}

// ====== Mocklar ======
class MockGetTasks extends Mock implements GetTasks {}

class MockAddTask extends Mock implements AddTask {}

class MockToggleTask extends Mock implements ToggleTask {}

class MockDeleteTask extends Mock implements DeleteTask {}

class MockUpdateTask extends Mock implements UpdateTask {}

// Param registratsiyasi (mocktail uchun)
class FakeNoParams extends Fake implements NoParams {}

class FakeAddTaskParams extends Fake implements AddTaskParams {}

class FakeToggleTaskParams extends Fake implements ToggleTaskParams {}

class FakeDeleteTaskParams extends Fake implements DeleteTaskParams {}

class FakeUpdateTaskParams extends Fake implements UpdateTaskParams {}

void main() {
  late MockGetTasks getTasks;
  late MockAddTask addTask;
  late MockToggleTask toggleTask;
  late MockDeleteTask deleteTask;
  late MockUpdateTask updateTask;

  late TaskBloc bloc;

  // Fixturelar
  final tasks = <TaskEntity>[
    TaskEntity(id: 1, title: 'A', description: 'jhsdbvkucsbow sbcosof', done: false, created_at: DateTime.now()),
    TaskEntity(
      id: 2,
      title: 'B',
      description: 'jhslbvhjlsd hsdbcvlsdbclsd',
      done: true,
      created_at: DateTime.now().add(Duration(minutes: 3)),
    ),
  ];

  setUpAll(() {
    registerFallbackValue(FakeNoParams());
    registerFallbackValue(FakeAddTaskParams());
    registerFallbackValue(FakeToggleTaskParams());
    registerFallbackValue(FakeDeleteTaskParams());
    registerFallbackValue(FakeUpdateTaskParams());
  });

  setUp(() {
    getTasks = MockGetTasks();
    addTask = MockAddTask();
    toggleTask = MockToggleTask();
    deleteTask = MockDeleteTask();
    updateTask = MockUpdateTask();

    bloc = TaskBloc(getTasks: getTasks, addTask: addTask, toggleTask: toggleTask, deleteTask: deleteTask, updateTask: updateTask);
  });

  tearDown(() => bloc.close());

  group('TaskBloc - LoadTasks', () {
    blocTest<TaskBloc, TaskState>(
      'success: emits inProgress -> success with items',
      build: () {
        when(() => getTasks(any())).thenAnswer((_) async => Right(tasks));
        return bloc;
      },
      act: (b) => b.add(const LoadTasks()),
      expect:
          () => [
            // _reload() da inProgress
            predicate<TaskState>((s) => s.status == FormzSubmissionStatus.inProgress && s.errorMessage == null),
            // va keyin success + items
            predicate<TaskState>(
              (s) => s.status == FormzSubmissionStatus.success && s.items.length == tasks.length && s.errorMessage == null,
            ),
          ],
      verify: (_) {
        verify(() => getTasks(any())).called(1);
      },
    );

    blocTest<TaskBloc, TaskState>(
      'failure: emits inProgress -> failure with errorMessage',
      build: () {
        when(() => getTasks(any())).thenAnswer((_) async => Left(ErrorModel(message: 'load failed')));
        return bloc;
      },
      act: (b) => b.add(const LoadTasks()),
      expect:
          () => [
            predicate<TaskState>((s) => s.status == FormzSubmissionStatus.inProgress),
            predicate<TaskState>((s) => s.status == FormzSubmissionStatus.failure && s.errorMessage == 'load failed'),
          ],
    );
  });

  group('TaskBloc - AddTaskEvent', () {
    blocTest<TaskBloc, TaskState>(
      'success: emits inProgress -> inProgress(reload) -> success',
      build: () {
        when(() => addTask(any())).thenAnswer((_) async => const Right(1)); // add ok
        when(() => getTasks(any())).thenAnswer((_) async => Right(tasks)); // reload ok
        return bloc;
      },
      act: (b) => b.add(const AddTaskEvent('New Title', 'New Desc')),
      expect:
          () => [
            // Add oldidan loading
            predicate<TaskState>((s) => s.status == FormzSubmissionStatus.inProgress),
            // reload ichidagi loading
            predicate<TaskState>((s) => s.status == FormzSubmissionStatus.inProgress),
            // yakuniy success
            predicate<TaskState>((s) => s.status == FormzSubmissionStatus.success && s.items.length == tasks.length),
          ],
      verify: (_) {
        verify(() => addTask(any())).called(1);
        verify(() => getTasks(any())).called(1);
      },
    );

    blocTest<TaskBloc, TaskState>(
      'failure: emits inProgress -> failure with message',
      build: () {
        when(() => addTask(any())).thenAnswer((_) async => Left(ErrorModel(message: 'add failed')));
        return bloc;
      },
      act: (b) => b.add(const AddTaskEvent('New Title', 'New Desc')),
      expect:
          () => [
            predicate<TaskState>((s) => s.status == FormzSubmissionStatus.inProgress),
            predicate<TaskState>((s) => s.status == FormzSubmissionStatus.failure && s.errorMessage == 'add failed'),
          ],
    );
  });

  group('TaskBloc - ToggleTaskEvent', () {
    blocTest<TaskBloc, TaskState>(
      'success: emits inProgress(reload) -> success',
      build: () {
        when(() => toggleTask(any())).thenAnswer((_) async => const Right(unit));
        when(() => getTasks(any())).thenAnswer((_) async => Right([tasks.first.copyWith(done: true), tasks[1]]));
        return bloc;
      },
      act: (b) => b.add(const ToggleTaskEvent(1, true)),
      expect:
          () => [
            predicate<TaskState>((s) => s.status == FormzSubmissionStatus.inProgress),
            predicate<TaskState>(
              (s) => s.status == FormzSubmissionStatus.success && s.items.firstWhere((e) => e.id == 1).done == true,
            ),
          ],
      verify: (_) {
        verify(() => toggleTask(any())).called(1);
        verify(() => getTasks(any())).called(1);
      },
    );

    blocTest<TaskBloc, TaskState>(
      'failure: emits failure with message',
      build: () {
        when(() => toggleTask(any())).thenAnswer((_) async => Left(ErrorModel(message: 'toggle failed')));
        return bloc;
      },
      act: (b) => b.add(const ToggleTaskEvent(1, true)),
      expect: () => [predicate<TaskState>((s) => s.status == FormzSubmissionStatus.failure && s.errorMessage == 'toggle failed')],
    );
  });

  group('TaskBloc - DeleteTaskEvent', () {
    blocTest<TaskBloc, TaskState>(
      'success: emits inProgress(reload) -> success',
      build: () {
        when(() => deleteTask(any())).thenAnswer((_) async => const Right(unit));
        when(() => getTasks(any())).thenAnswer((_) async => Right(tasks.where((t) => t.id != 1).toList()));
        return bloc;
      },
      act: (b) => b.add(const DeleteTaskEvent(1)),
      expect:
          () => [
            predicate<TaskState>((s) => s.status == FormzSubmissionStatus.inProgress),
            predicate<TaskState>((s) => s.status == FormzSubmissionStatus.success && s.items.every((t) => t.id != 1)),
          ],
    );

    blocTest<TaskBloc, TaskState>(
      'failure: emits failure with message',
      build: () {
        when(() => deleteTask(any())).thenAnswer((_) async => Left(ErrorModel(message: 'delete failed')));
        return bloc;
      },
      act: (b) => b.add(const DeleteTaskEvent(1)),
      expect: () => [predicate<TaskState>((s) => s.status == FormzSubmissionStatus.failure && s.errorMessage == 'delete failed')],
    );
  });

  group('TaskBloc - UpdateTaskEvent', () {
    final updated = TaskEntity(id: 2, title: 'B+', description: 'ksbvjlnjlzvcns', done: true, created_at: DateTime.now());

    blocTest<TaskBloc, TaskState>(
      'success: emits inProgress -> inProgress(reload) -> success',
      build: () {
        when(() => updateTask(any())).thenAnswer((_) async => const Right(unit));
        when(() => getTasks(any())).thenAnswer((_) async => Right([tasks.first, updated]));
        return bloc;
      },
      act: (b) => b.add(UpdateTaskEvent(updated)),
      expect:
          () => [
            predicate<TaskState>((s) => s.status == FormzSubmissionStatus.inProgress),
            predicate<TaskState>((s) => s.status == FormzSubmissionStatus.inProgress),
            predicate<TaskState>(
              (s) =>
                  s.status == FormzSubmissionStatus.success && s.items.any((t) => t.id == 2 && t.title == 'B+' && t.done == true),
            ),
          ],
    );

    blocTest<TaskBloc, TaskState>(
      'failure: emits inProgress -> failure with message',
      build: () {
        when(() => updateTask(any())).thenAnswer((_) async => Left(ErrorModel(message: 'update failed')));
        return bloc;
      },
      act: (b) => b.add(UpdateTaskEvent(updated)),
      expect:
          () => [
            predicate<TaskState>((s) => s.status == FormzSubmissionStatus.inProgress),
            predicate<TaskState>((s) => s.status == FormzSubmissionStatus.failure && s.errorMessage == 'update failed'),
          ],
    );
  });
}
