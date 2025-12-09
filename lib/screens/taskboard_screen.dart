import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../models/task_status.dart';
import '../models/task_detail_result.dart';
import '../widgets/kanban_column.dart';
import '../dialogs/task_detail_dialog.dart';
import '../services/task_service.dart';
import '../providers/app_state.dart';

class TaskboardScreen extends StatefulWidget {
  const TaskboardScreen({super.key});

  @override
  State<TaskboardScreen> createState() => _TaskboardScreenState();
}

class _TaskboardScreenState extends State<TaskboardScreen> {
  Map<TaskStatus, List<Task>> tasks = {
    TaskStatus.backlog: [],
    TaskStatus.todo: [],
    TaskStatus.inProgress: [],
    TaskStatus.done: [],
  };

  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final allTasks = await TaskService.getTasks();

      // Group tasks by status
      final grouped = <TaskStatus, List<Task>>{
        TaskStatus.backlog: [],
        TaskStatus.todo: [],
        TaskStatus.inProgress: [],
        TaskStatus.done: [],
      };

      for (final task in allTasks) {
        final status = TaskStatusExtension.fromApiValue(task.status);
        grouped[status]!.add(task);
      }

      setState(() {
        tasks = grouped;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _editTask(TaskStatus status, int index) async {
    final item = tasks[status]![index];
    final result = await showDialog<TaskDetailResult>(
      context: context,
      builder: (context) => TaskDetailDialog(item: item),
    );
    if (result != null) {
      try {
        final updatedTask = item.copyWith(
          title: result.title,
          description: result.description,
          status: result.status.apiValue,
        );

        // Update task via API
        await TaskService.updateTask(updatedTask);

        // Update UI - handle status change
        setState(() {
          tasks[status]!.removeAt(index);
          tasks[result.status]!.add(updatedTask);
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to update task: $e')));
        }
      }
    }
  }

  void _onDragCompleted(
    Task item,
    TaskStatus fromStatus,
    TaskStatus toStatus,
  ) async {
    // Update task status via API
    final updatedTask = item.copyWith(status: toStatus.apiValue);

    // Update UI immediately for better UX
    setState(() {
      tasks[fromStatus]!.removeWhere((task) => task.id == item.id);
      tasks[toStatus]!.add(updatedTask);
    });

    try {
      await TaskService.updateTask(updatedTask);
    } catch (e) {
      // Revert on error
      setState(() {
        tasks[toStatus]!.removeWhere((task) => task.id == item.id);
        tasks[fromStatus]!.add(item);
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to move task: $e')));
      }
    }
  }

  void _createTask() async {
    final result = await showDialog<TaskDetailResult>(
      context: context,
      builder: (context) => const TaskDetailDialog(),
    );

    if (result != null && mounted) {
      try {
        final appState = context.read<AppState>();
        final userId = appState.user?.id ?? '';

        final newTask = Task(
          id: '', // Will be assigned by the server
          title: result.title,
          description: result.description,
          status: result.status.apiValue,
          userId: userId,
        );

        // Create task via API
        final createdTask = await TaskService.createTask(newTask);

        // Add to the appropriate column
        setState(() {
          tasks[result.status]!.add(createdTask);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Task created successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to create task: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      appBar: AppBar(
        title: const Text('Kanban Board'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTasks,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final appState = context.read<AppState>();
              await appState.signOut();
            },
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: $_error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadTasks,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : LayoutBuilder(
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
                              child: KanbanColumn(
                                status: status,
                                tasks: tasks[status]!,
                                isCarousel: true,
                                onDragCompleted: _onDragCompleted,
                                onEditTask: _editTask,
                                onNavigateToColumn: (targetStatus) {
                                  final targetIndex = TaskStatus.values.indexOf(
                                    targetStatus,
                                  );
                                  _pageController.animateToPage(
                                    targetIndex,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                              ),
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
                          child: KanbanColumn(
                            status: status,
                            tasks: tasks[status]!,
                            isCarousel: false,
                            onDragCompleted: _onDragCompleted,
                            onEditTask: _editTask,
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createTask,
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
        tooltip: 'Create new task',
      ),
    );
  }
}
