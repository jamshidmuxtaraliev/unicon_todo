// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/services/get_it.dart';
import 'core/theme/app_theme.dart';
import 'features/todo/domain/usecases/add_task_usecase.dart';
import 'features/todo/domain/usecases/delete_task_usecase.dart';
import 'features/todo/domain/usecases/get_task_usecase.dart';

import 'features/todo/domain/usecases/toggle_task_usecase.dart';
import 'features/todo/presentation/logic/task_bloc/task_bloc.dart';
import 'features/todo/presentation/screens/main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Dependency Injection init
  await initDI();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TaskBloc>(
          create:
              (_) => TaskBloc(
                getTasks: sl<GetTasks>(),
                addTask: sl<AddTask>(),
                toggleTask: sl<ToggleTask>(),
                deleteTask: sl<DeleteTask>(),
              ),
        ),
      ],
      child: MaterialApp(
        title: 'Todo App (Clean Architecture)',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light, // AppBar GREEN, TabBar selected GREEN, Scaffold oq
        home: const MainScreen(),
      ),
    );
  }
}
