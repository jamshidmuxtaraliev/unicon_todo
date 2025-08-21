// lib/features/todo/presentation/pages/main_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../todo/domain/entities/task.dart';

// WidgetBridge orqali Android Home Widget’ni yangilaymiz
import '../../../../platform/widget_bridge.dart';
import '../logic/task_bloc/task_bloc.dart';
import '../logic/task_bloc/task_event.dart';
import '../logic/task_bloc/task_state.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(const LoadTasks());
  }

  Future<void> _addTaskDialog() async {
    final ctrl = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Yangi vazifa'),
            content: TextField(
              controller: ctrl,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Masalan: UI tugatish', border: OutlineInputBorder()),
              onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Bekor qilish')),
              FilledButton(onPressed: () => Navigator.pop(ctx, ctrl.text.trim()), child: const Text('Saqlash')),
            ],
          ),
    );
    if (title != null && title.isNotEmpty) {
      context.read<TaskBloc>().add(AddTaskEvent(title));
    }
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
          if (state.items.isNotEmpty || state.status == TaskStatus.success) {
            final done = state.items.where((e) => e.done).length;
            final undone = state.items.length - done;
            WidgetBridge.updateWidgetCounts(done: done, undone: undone);
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
                  child: const TabBar(tabs: [Tab(text: 'Hammasi'), Tab(text: 'Bajarilmagan'), Tab(text: 'Bajarilgan')]),
                ),
              ),
            ),
            body: Builder(
              builder: (context) {
                if (state.status == TaskStatus.loading && state.items.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.status == TaskStatus.failure && state.items.isEmpty) {
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

                return TabBarView(children: [_TaskList(items: all), _TaskList(items: undone), _TaskList(items: done)]);
              },
            ),
            floatingActionButton: FloatingActionButton(onPressed: _addTaskDialog, child: const Icon(Icons.add)),
          );
        },
      ),
    );
  }
}

class _TaskList extends StatelessWidget {
  final List<TaskEntity> items;

  const _TaskList({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async => context.read<TaskBloc>().add(const LoadTasks()),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [SizedBox(height: 180), Center(child: Text('Hozircha vazifa yo‘q'))],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => context.read<TaskBloc>().add(const LoadTasks()),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final t = items[i];
          return Dismissible(
            key: ValueKey('task-${t.id}'),
            background: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: Colors.redAccent,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            direction: DismissDirection.startToEnd,
            onDismissed: (_) => context.read<TaskBloc>().add(DeleteTaskEvent(t.id!)),
            child: Card(
              child: ListTile(
                leading: Checkbox(
                  value: t.done,
                  onChanged: (v) => context.read<TaskBloc>().add(ToggleTaskEvent(t.id!, v ?? false)),
                ),
                title: Text(t.title, style: TextStyle(decoration: t.done ? TextDecoration.lineThrough : null)),
                subtitle: Text(
                  t.done ? 'Bajarilgan' : 'Bajarilmagan',
                  style: TextStyle(color: t.done ? Colors.green : Colors.orange),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => context.read<TaskBloc>().add(DeleteTaskEvent(t.id!)),
                ),
                onTap: () => context.read<TaskBloc>().add(ToggleTaskEvent(t.id!, !t.done)),
              ),
            ),
          );
        },
      ),
    );
  }
}
