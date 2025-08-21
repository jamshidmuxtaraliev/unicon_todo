import 'package:dartz/dartz.dart';

import '../../../../core/error/error_model.dart';
import '../../../../core/usecase/use_case.dart';
import '../respositories/task_repository.dart';

class ToggleTaskParams {
  final int id;
  final bool done;

  ToggleTaskParams(this.id, this.done);
}

class ToggleTask implements UseCase<void, ToggleTaskParams> {
  final TaskRepository repo;

  ToggleTask(this.repo);

  @override
  Future<Either<ErrorModel, void>> call(ToggleTaskParams params) {
    return repo.toggleTask(params.id, params.done);
  }
}
