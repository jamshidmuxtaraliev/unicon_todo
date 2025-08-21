import 'package:dartz/dartz.dart';

import '../../../../core/error/error_model.dart';
import '../../../../core/usecase/use_case.dart';
import '../entities/task.dart';
import '../respositories/task_repository.dart';

class GetTasks implements UseCase<List<TaskEntity>, NoParams> {
  final TaskRepository repo;

  GetTasks(this.repo);

  @override
  Future<Either<ErrorModel, List<TaskEntity>>> call(NoParams params) {
    return repo.getTasks();
  }
}
