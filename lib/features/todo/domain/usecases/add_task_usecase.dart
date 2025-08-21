import 'package:dartz/dartz.dart';

import '../../../../core/error/error_model.dart';
import '../../../../core/usecase/use_case.dart';
import '../respositories/task_repository.dart';

class AddTaskParams {
  final String title;

  AddTaskParams(this.title);
}

class AddTask implements UseCase<int, AddTaskParams> {
  final TaskRepository repo;

  AddTask(this.repo);

  @override
  Future<Either<ErrorModel, int>> call(AddTaskParams params) {
    return repo.addTask(params.title);
  }
}
