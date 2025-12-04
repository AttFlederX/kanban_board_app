import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/task_status.dart';
import 'task_card.dart';

class KanbanColumn extends StatelessWidget {
  final TaskStatus status;
  final List<Task> tasks;
  final bool isCarousel;
  final Function(Task item, TaskStatus fromStatus, TaskStatus toStatus)
  onDragCompleted;
  final Function(TaskStatus status, int index) onEditTask;

  const KanbanColumn({
    super.key,
    required this.status,
    required this.tasks,
    required this.isCarousel,
    required this.onDragCompleted,
    required this.onEditTask,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: isCarousel ? const EdgeInsets.symmetric(horizontal: 4) : null,
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surface
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: isCarousel ? BorderRadius.circular(8) : null,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              status.label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          Expanded(
            child: DragTarget<Map<String, dynamic>>(
              onWillAcceptWithDetails: (details) => true,
              onAcceptWithDetails: (details) {
                final item = details.data['item'] as Task;
                final fromStatus = details.data['fromStatus'] as TaskStatus;
                if (fromStatus != status) {
                  onDragCompleted(item, fromStatus, status);
                }
              },
              builder: (context, candidateData, rejectedData) {
                final theme = Theme.of(context);
                return Container(
                  decoration: BoxDecoration(
                    color: candidateData.isNotEmpty
                        ? theme.colorScheme.primary.withAlpha(0x40)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final item = tasks[index];
                      return LongPressDraggable<Map<String, dynamic>>(
                        delay: const Duration(milliseconds: 200),
                        data: {'item': item, 'fromStatus': status},
                        feedback: Material(
                          elevation: 8,
                          borderRadius: BorderRadius.circular(8),
                          color: Theme.of(context).colorScheme.surface,
                          child: Container(
                            width: 280,
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  item.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.description,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.3,
                          child: TaskCard(
                            item: item,
                            onTap: () => onEditTask(status, index),
                          ),
                        ),
                        child: TaskCard(
                          item: item,
                          onTap: () => onEditTask(status, index),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
