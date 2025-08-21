import 'package:dartz/dartz.dart';

import '../../../../core/error/error_model.dart';
import '../../../../core/usecase/use_case.dart';
import '../respositories/task_repository.dart';

class DeleteTaskParams {
  final int id;
  DeleteTaskParams(this.id);
}

class DeleteTask implements UseCase<void, DeleteTaskParams> {
  final TaskRepository repo;
  DeleteTask(this.repo);

  @override
  Future<Either<ErrorModel, void>> call(DeleteTaskParams params) {
    return repo.deleteTask(params.id);
  }
}
