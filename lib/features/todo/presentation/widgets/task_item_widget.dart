import 'package:flutter/material.dart';
import 'package:unicon_todo/features/todo/domain/entities/task.dart';

class TaskItemCard extends StatelessWidget {
  final TaskEntity task;
  final Function(bool value) onToggleCompleted;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskItemCard({
    super.key,
    required this.task,
    required this.onToggleCompleted,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateText = task.created_at.toLocal().toString().substring(0, 16);
    final completed = task.done ?? false;
    final title = task.title.isNotEmpty ? task.title : 'No Title';
    final subtitle = task.description.isNotEmpty ? task.description : 'No Description';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: completed ? Colors.grey.shade100 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(blurRadius: 16, offset: Offset(0, 6), color: Color(0x14000000))],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + edit icon (on small screens icon is at the right column)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))),
                    PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 0),
                      tooltip: '',
                      child: const SizedBox(width: 28, height: 28, child: Center(child: Icon(Icons.more_vert, size: 18))),
                      onSelected: (value) {
                        if (value == 'edit') {
                          onEdit();
                        } else if (value == 'delete') {
                          onDelete();
                        }
                      },
                      itemBuilder:
                          (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              height: 32, // element balandligini kichraytirish
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.edit, color: Colors.blue, size: 18),
                                    SizedBox(width: 6),
                                    Text("Tahrirlash"),
                                  ],
                                ),
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              height: 32,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.delete, color: Colors.red, size: 18),
                                    SizedBox(width: 6),
                                    Text("O'chirish"),
                                  ],
                                ),
                              ),
                            ),
                          ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black.withOpacity(0.45), fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      dateText,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.black.withOpacity(0.65),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () => onToggleCompleted(!(task.done ?? false)),
                      borderRadius: BorderRadius.circular(8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Bajarildi qilish',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: completed ? Colors.green.shade700 : Colors.black.withOpacity(0.65),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 10),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              border: completed ? null : Border.all(color: Colors.black.withOpacity(0.5), width: 1.6),
                              color: completed ? Colors.green : Colors.white,
                            ),
                            child: completed ? const Icon(Icons.check, size: 18, color: Colors.white) : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
