// lib/features/todo/presentation/pages/main_screen.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unicon_todo/features/todo/presentation/screens/task_list.dart';
import 'package:unicon_todo/features/todo/presentation/widgets/task_item_widget.dart';

import '../../../../core/services/bacground_reminder_service.dart';
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

Future<void> showTaskDialog(BuildContext context, {TaskEntity? task}) async {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final FocusNode descFocus = FocusNode();

  if (task != null) {
    // Agar task tahrirlanayotgan bo‘lsa, ma'lumotlarni to‘ldirish
    titleController.text = task.title;
    descController.text = task.description;
  }

  await showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Yangi vazifa',
    barrierColor: Colors.black.withOpacity(0.25),
    // biroz qoraytirish
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (_, __, ___) {
      // Asl sahifa — blur fon
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: const SizedBox.expand(), // shunchaki fonni tutib turish
      );
    },
    transitionBuilder: (ctx, anim, __, ___) {
      // Karta animatsiyasi: opacity + scale
      final opacity = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      final scale = Tween<double>(begin: 0.95, end: 1).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutBack));

      // Dialogning o‘zi
      final card = Center(
        child: Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            // Klaviatura ko‘tarilganda joy qoldirish
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  // Ichki “frosted glass” qatlam
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      decoration: BoxDecoration(
                        // shaffof gradient + chiziq
                        gradient: LinearGradient(
                          colors: [Colors.white.withOpacity(0.75), Colors.white.withOpacity(0.55)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(color: Colors.white.withOpacity(0.6)),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 24, offset: const Offset(0, 12)),
                        ],
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                      child: Material(
                        type: MaterialType.transparency,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Sarlavha
                            Row(
                              children: [
                                const Icon(Icons.task_alt_rounded, size: 22, color: Colors.indigo),
                                const SizedBox(width: 8),
                                const Text('Yangi vazifa', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                                const Spacer(),
                                IconButton(
                                  splashRadius: 22,
                                  onPressed: () => Navigator.pop(ctx),
                                  icon: const Icon(Icons.close_rounded),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Forma
                            Column(
                              children: [
                                TextField(
                                  controller: titleController,
                                  autofocus: true,
                                  textInputAction: TextInputAction.next,
                                  textCapitalization: TextCapitalization.sentences,
                                  onSubmitted: (_) => FocusScope.of(ctx).requestFocus(descFocus),
                                  decoration: InputDecoration(
                                    hintText: 'Task mavzusi',
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.7),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: descController,
                                  focusNode: descFocus,
                                  textCapitalization: TextCapitalization.sentences,
                                  maxLines: 3,
                                  decoration: InputDecoration(
                                    hintText: 'Task bayonoti',
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.7),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),
                            // Tugmalar
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    ),
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Bekor qilish'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: FilledButton(
                                    style: FilledButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    ),
                                    onPressed: () {
                                      final title = titleController.text.trim();
                                      final desc = descController.text.trim();
                                      if (title.isEmpty || desc.isEmpty) {
                                        // Yengil haptik / snack bar qo‘shsangiz ham bo‘ladi
                                        ScaffoldMessenger.of(
                                          ctx,
                                        ).showSnackBar(const SnackBar(content: Text('Iltimos, maydonlarni to‘ldiring')));
                                        return;
                                      }
                                      // Sizning BLoC'ga yuborish
                                      if (task != null) {
                                        // Agar task tahrirlanayotgan bo‘lsa, yangilash
                                        ctx.read<TaskBloc>().add(UpdateTaskEvent(task.copyWith(title: title, description: desc)));
                                      } else {
                                        // Yangi task qo‘shish
                                        ctx.read<TaskBloc>().add(AddTaskEvent(title, desc));
                                      }
                                      Navigator.pop(ctx);
                                    },
                                    child: const Text('Saqlash'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      return FadeTransition(opacity: opacity, child: ScaleTransition(scale: scale, child: card));
    },
  );
}
