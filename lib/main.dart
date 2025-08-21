// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:unicon_todo/features/todo/domain/usecases/update_task_usecase.dart';
import 'package:unicon_todo/platform/widget_bridge.dart';

import 'core/services/bacground_reminder_service.dart';
import 'core/services/get_it.dart';
import 'core/services/local_notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/todo/domain/usecases/add_task_usecase.dart';
import 'features/todo/domain/usecases/delete_task_usecase.dart';
import 'features/todo/domain/usecases/get_task_usecase.dart';

import 'features/todo/domain/usecases/toggle_task_usecase.dart';
import 'features/todo/presentation/logic/task_bloc/task_bloc.dart';
import 'features/todo/presentation/screens/main_screen.dart';

void setupBgListenersInUI() {
  // BG izolat "widget_refresh" yuborganda, UI izolat home widgetni yangilaydi
  FlutterBackgroundService().on('widget_refresh').listen((data) async {
    final all = (data?['all'] as int?) ?? 0;
    final done = (data?['done'] as int?) ?? 0;
    final undone = (data?['undone'] as int?) ?? 0;
    await WidgetBridge.updateWidgetCounts(all: all, done: done, undone: undone);
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDI();
  await Permission.notification.request();
  await LocalNotificationService.init();
  await TaskBackgroundService.configureAndStart();
  setupBgListenersInUI();

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
                updateTask: sl<UpdateTask>(),
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
