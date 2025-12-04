import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/task_status.dart';
import '../models/task_detail_result.dart';

class TaskDetailDialog extends StatefulWidget {
  final Task? item;

  const TaskDetailDialog({super.key, this.item});

  @override
  State<TaskDetailDialog> createState() => _TaskDetailDialogState();
}

class _TaskDetailDialogState extends State<TaskDetailDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TaskStatus _selectedStatus;
  late bool _isEditMode;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.item != null;
    _titleController = TextEditingController(text: widget.item?.title ?? '');
    _descController = TextEditingController(
      text: widget.item?.description ?? '',
    );
    _selectedStatus = _isEditMode
        ? TaskStatusExtension.fromApiValue(widget.item!.status)
        : TaskStatus.backlog;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  bool get _isValid => _titleController.text.trim().isNotEmpty;

  void _submit() {
    final title = _titleController.text.trim();
    final description = _descController.text.trim();

    if (title.isNotEmpty) {
      Navigator.of(context).pop(
        TaskDetailResult(
          title: title,
          description: description,
          status: _selectedStatus,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditMode ? 'Edit Task' : 'Create New Task'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Enter task title',
                border: OutlineInputBorder(),
              ),
              autofocus: !_isEditMode,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (value) => setState(() {}),
              onSubmitted: (_) => _isValid ? _submit() : null,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter task description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TaskStatus>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: TaskStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _getStatusColor(status),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(status.label),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedStatus = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isValid ? _submit : null,
          child: Text(_isEditMode ? 'Save' : 'Create'),
        ),
      ],
    );
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.backlog:
        return Colors.grey;
      case TaskStatus.todo:
        return Colors.blue;
      case TaskStatus.inProgress:
        return Colors.orange;
      case TaskStatus.done:
        return Colors.green;
    }
  }
}
