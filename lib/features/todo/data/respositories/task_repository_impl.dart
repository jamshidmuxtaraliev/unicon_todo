import 'package:dartz/dartz.dart';
import 'package:unicon_todo/features/todo/domain/entities/task.dart';

import '../../../../core/error/error_model.dart';
import '../../domain/respositories/task_repository.dart';
import '../datasource/task_local_datasource.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource local;

  TaskRepositoryImpl({required this.local});

  @override
  Future<Either<ErrorModel, List<TaskEntity>>> getTasks() async {
    try {
      final tasks = await local.getTasks();
      return Right(tasks);
    } catch (e) {
      return Left(ErrorModel(message: e.toString()));
    }
  }

  @override
  Future<Either<ErrorModel, int>> addTask(String title, String description) async {
    try {
      final id = await local.addTask(title, description);
      return Right(id);
    } catch (e) {
      return Left(ErrorModel(message: e.toString()));
    }
  }

  @override
  Future<Either<ErrorModel, void>> toggleTask(int id, bool done) async {
    try {
      await local.toggleTask(id, done);
      return const Right(null);
    } catch (e) {
      return Left(ErrorModel(message: e.toString()));
    }
  }

  @override
  Future<Either<ErrorModel, void>> deleteTask(int id) async {
    try {
      await local.deleteTask(id);
      return const Right(null);
    } catch (e) {
      return Left(ErrorModel(message: e.toString()));
    }
  }

  @override
  Future<Either<ErrorModel, void>> updateTask(TaskEntity task) async {
    try {
      await local.updateTask(task);
      return const Right(null);
    } catch (e) {
      return Left(ErrorModel(message: e.toString()));
    }
  }
}
