import 'package:flutter/material.dart';

class TaskboardScreen extends StatefulWidget {
  const TaskboardScreen({super.key});

  @override
  State<TaskboardScreen> createState() => _TaskboardScreenState();
}

class TaskItem {
  String id;
  String title;
  String description;
  TaskItem({required this.id, required this.title, required this.description});
}

enum TaskStatus { backlog, todo, inProgress, done }

class _TaskboardScreenState extends State<TaskboardScreen> {
  final Map<TaskStatus, List<TaskItem>> tasks = {
    TaskStatus.backlog: [
      TaskItem(id: '1', title: 'Sample Backlog', description: 'Description'),
    ],
    TaskStatus.todo: [
      TaskItem(id: '2', title: 'Sample To Do', description: 'Description'),
    ],
    TaskStatus.inProgress: [
      TaskItem(
        id: '3',
        title: 'Sample In Progress',
        description: 'Description',
      ),
    ],
    TaskStatus.done: [
      TaskItem(id: '4', title: 'Sample Done', description: 'Description'),
    ],
  };

  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _editTask(TaskStatus status, int index) async {
    final item = tasks[status]![index];
    final result = await showDialog<TaskItem>(
      context: context,
      builder: (context) => TaskEditDialog(item: item),
    );
    if (result != null) {
      setState(() {
        tasks[status]![index] = result;
      });
    }
  }

  void _onDragCompleted(
    TaskItem item,
    TaskStatus fromStatus,
    TaskStatus toStatus,
  ) {
    setState(() {
      tasks[fromStatus]!.removeWhere((task) => task.id == item.id);
      tasks[toStatus]!.add(item);
    });
  }

  String _getStatusLabel(TaskStatus status) {
    switch (status) {
      case TaskStatus.backlog:
        return 'Backlog';
      case TaskStatus.todo:
        return 'To Do';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.done:
        return 'Done';
    }
  }

  Widget _buildColumn(TaskStatus status, {bool isCarousel = false}) {
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
              _getStatusLabel(status),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          Expanded(
            child: DragTarget<Map<String, dynamic>>(
              onWillAcceptWithDetails: (details) => true,
              onAcceptWithDetails: (details) {
                final item = details.data['item'] as TaskItem;
                final fromStatus = details.data['fromStatus'] as TaskStatus;
                if (fromStatus != status) {
                  _onDragCompleted(item, fromStatus, status);
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
                    itemCount: tasks[status]!.length,
                    itemBuilder: (context, index) {
                      final item = tasks[status]![index];
                      return LongPressDraggable<Map<String, dynamic>>(
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
                          child: _buildTaskCard(item, status, index),
                        ),
                        child: _buildTaskCard(item, status, index),
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

  Widget _buildTaskCard(TaskItem item, TaskStatus status, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      child: InkWell(
        onTap: () => _editTask(status, index),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(item.description, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      appBar: AppBar(title: const Text('Kanban Board')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          const columnWidth = 300.0;
          final minWidthForColumns = columnWidth * 1.5;
          final useCarousel = constraints.maxWidth < minWidthForColumns;

          if (useCarousel) {
            return Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    children: TaskStatus.values.map((status) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _buildColumn(status, isCarousel: true),
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      TaskStatus.values.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(
                                  context,
                                ).colorScheme.onSurface.withAlpha(0x40),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: TaskStatus.values.map((status) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _buildColumn(status),
                  ),
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }
}

class TaskEditDialog extends StatefulWidget {
  final TaskItem item;
  const TaskEditDialog({super.key, required this.item});

  @override
  State<TaskEditDialog> createState() => _TaskEditDialogState();
}

class _TaskEditDialogState extends State<TaskEditDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item.title);
    _descController = TextEditingController(text: widget.item.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Task'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          TextField(
            controller: _descController,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(
              TaskItem(
                id: widget.item.id,
                title: _titleController.text,
                description: _descController.text,
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
