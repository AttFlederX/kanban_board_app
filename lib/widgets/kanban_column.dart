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
  final Function(TaskStatus status)? onNavigateToColumn;

  const KanbanColumn({
    super.key,
    required this.status,
    required this.tasks,
    required this.isCarousel,
    required this.onDragCompleted,
    required this.onEditTask,
    this.onNavigateToColumn,
  });

  void _showMoveTaskMenu(
    BuildContext context,
    Task task,
    TaskStatus currentStatus,
  ) {
    final availableStatuses = TaskStatus.values
        .where((s) => s != currentStatus)
        .toList();

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Move "${task.title}" to:',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            ...availableStatuses.map(
              (toStatus) => ListTile(
                leading: Icon(
                  _getStatusIcon(toStatus),
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(toStatus.label),
                onTap: () {
                  Navigator.pop(context);
                  onDragCompleted(task, currentStatus, toStatus);
                  // Navigate to the destination column in carousel view
                  if (isCarousel && onNavigateToColumn != null) {
                    onNavigateToColumn!(toStatus);
                  }
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.backlog:
        return Icons.inbox;
      case TaskStatus.todo:
        return Icons.list;
      case TaskStatus.inProgress:
        return Icons.hourglass_empty;
      case TaskStatus.done:
        return Icons.check_circle;
    }
  }

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

                      // In carousel view, wrap task card with move button
                      if (isCarousel) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          elevation: 2,
                          child: InkWell(
                            onTap: () => onEditTask(status, index),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.open_with),
                                        iconSize: 20,
                                        tooltip: 'Move task',
                                        onPressed: () => _showMoveTaskMenu(
                                          context,
                                          item,
                                          status,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.description,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      // In full view, use drag and drop
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
