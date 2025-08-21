import 'package:get_it/get_it.dart';

import '../../features/todo/data/datasource/task_local_datasource.dart';
import '../../features/todo/data/respositories/task_repository_impl.dart';
import '../../features/todo/domain/respositories/task_repository.dart';
import '../../features/todo/domain/usecases/add_task_usecase.dart';
import '../../features/todo/domain/usecases/delete_task_usecase.dart';
import '../../features/todo/domain/usecases/get_task_usecase.dart';
import '../../features/todo/domain/usecases/toggle_task_usecase.dart';

final sl = GetIt.instance;

Future<void> initDI() async {
  // DataSources
  sl.registerLazySingleton<TaskLocalDataSource>(() => TaskLocalDataSourceImpl());

  // Repository
  sl.registerLazySingleton<TaskRepository>(
        () => TaskRepositoryImpl(local: sl()),
  );

  // UseCases
  sl.registerLazySingleton(() => GetTasks(sl()));
  sl.registerLazySingleton(() => AddTask(sl()));
  sl.registerLazySingleton(() => ToggleTask(sl()));
  sl.registerLazySingleton(() => DeleteTask(sl()));
}
