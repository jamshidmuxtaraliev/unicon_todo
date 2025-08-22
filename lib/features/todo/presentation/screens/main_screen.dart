import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:unicon_todo/features/todo/presentation/screens/task_list.dart';
import 'package:unicon_todo/features/todo/presentation/widgets/task_item_widget.dart';

import '../../../../core/services/bacground_reminder_service.dart';
import '../../../todo/domain/entities/task.dart';

import '../../../../platform/widget_bridge.dart';
import '../logic/task_bloc/task_bloc.dart';
import '../logic/task_bloc/task_event.dart';
import '../logic/task_bloc/task_state.dart';
import '../widgets/add_and_edit_dialog.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static const _events = MethodChannel('todo/events');

  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(const LoadTasks());

    _events.setMethodCallHandler((call) async {
      if (call.method == 'taskChanged') {
        context.read<TaskBloc>().add(const LoadTasks());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: BlocConsumer<TaskBloc, TaskState>(
        listenWhen: (prev, curr) => prev.items != curr.items || prev.errorMessage != curr.errorMessage,
        listener: (context, state) {
          // Xatolarni Snackbar’da ko‘rsatish
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
          // Home Widget sonlarini yangilash (Android)
          if (state.items.isNotEmpty || state.status.isSuccess) {
            final done = state.items.where((e) => e.done).length;
            final undone = state.items.length - done;
            TaskBackgroundService.refresh();
            WidgetBridge.updateWidgetCounts(all: state.items.length, done: done, undone: undone);
          }
        },
        builder: (context, state) {
          final all = state.items;
          final undone = state.items.where((t) => !t.done).toList();
          final done = state.items.where((t) => t.done).toList();

          return Scaffold(
            appBar: AppBar(
              title: const Text('Todo App'),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  color: Colors.white, // TabBar oq fon
                  child: TabBar(
                    padding: EdgeInsets.zero,
                    labelPadding: EdgeInsets.zero,
                    tabs: [
                      Tab(text: 'Hammasi (${all.length})'),
                      Tab(text: 'Bajarilmagan (${undone.length})'),
                      Tab(text: 'Bajarilgan (${done.length})'),
                    ],
                  ),
                ),
              ),
            ),
            body: Builder(
              builder: (context) {
                if (state.status.isInProgress && state.items.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.status.isFailure && state.items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Xatolik yuz berdi'),
                        if (state.errorMessage != null) ...[
                          const SizedBox(height: 8),
                          Text(state.errorMessage!, textAlign: TextAlign.center),
                        ],
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () => context.read<TaskBloc>().add(const LoadTasks()),
                          child: const Text('Qayta urinish'),
                        ),
                      ],
                    ),
                  );
                }

                return TabBarView(children: [TaskList(items: all), TaskList(items: undone), TaskList(items: done)]);
              },
            ),
            floatingActionButton: FloatingActionButton(onPressed: () => showTaskDialog(context), child: const Icon(Icons.add)),
          );
        },
      ),
    );
  }
}
