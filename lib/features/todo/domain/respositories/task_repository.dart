import 'package:dartz/dartz.dart';

import '../../../../core/error/error_model.dart';
import '../entities/task.dart';

abstract class TaskRepository {
  Future<Either<ErrorModel, List<TaskEntity>>> getTasks();

  Future<Either<ErrorModel, int>> addTask(String title, String description);

  Future<Either<ErrorModel, void>> toggleTask(int id, bool done);

  Future<Either<ErrorModel, void>> deleteTask(int id);

  Future<Either<ErrorModel, void>> updateTask(TaskEntity task);
}
