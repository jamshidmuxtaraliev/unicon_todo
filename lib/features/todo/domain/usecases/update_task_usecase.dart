import 'package:dartz/dartz.dart';
import '../../../../core/error/error_model.dart';
import '../../../../core/usecase/use_case.dart';
import '../entities/task.dart';
import '../respositories/task_repository.dart';

class UpdateTask implements UseCase<void, TaskEntity>{
  final TaskRepository repository;
  UpdateTask(this.repository);

  @override
  Future<Either<ErrorModel, void>> call(TaskEntity task) {
    return repository.updateTask(task);
  }
}

