import 'task_status.dart';

class TaskDetailResult {
  final String title;
  final String description;
  final TaskStatus status;

  TaskDetailResult({
    required this.title,
    required this.description,
    required this.status,
  });
}
