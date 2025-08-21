import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unicon_todo/features/todo/presentation/screens/main_screen.dart';

import '../../../../core/services/local_notification_service.dart';
import '../../domain/entities/task.dart';
import '../logic/task_bloc/task_bloc.dart';
import '../logic/task_bloc/task_event.dart';
import '../widgets/task_item_widget.dart';

class TaskList extends StatelessWidget {
  final List<TaskEntity> items;

  const TaskList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async => context.read<TaskBloc>().add(const LoadTasks()),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [SizedBox(height: 200), Center(child: Text('Hozircha vazifa yo‘q'))],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => context.read<TaskBloc>().add(const LoadTasks()),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 96),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final task = items[index];
          return TaskItemCard(
            task: task,
            onToggleCompleted: (bool value) {
              context.read<TaskBloc>().add(ToggleTaskEvent(task.id!, !task.done));
              //done false bolganda demak rue qilish uchun bosgan
              if (task.done == false) {
                AwesomeNotifications().createNotification(
                  content: NotificationContent(
                    id: Random().nextInt(100000),
                    channelKey: 'todo_channel',
                    title: '✅ Vazifa bajarildi',
                    body: 'Task bajarildi va yangilandi',
                  ),
                );
              }
              ;
            },
            onEdit: () {
              showTaskDialog(context, task: task);
            },
            onDelete: () {
              context.read<TaskBloc>().add(DeleteTaskEvent(task.id!));
            },
          );
        },
      ),
    );
  }
}
