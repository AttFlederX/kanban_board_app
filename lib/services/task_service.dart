import 'dart:convert';
import '../models/task.dart';
import 'api_service.dart';

class TaskService {
  // Get all tasks
  static Future<List<Task>> getTasks() async {
    try {
      final response = await ApiService.get('/tasks');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Task.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load tasks: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to load tasks: $e');
    }
  }

  // Get a specific task by ID
  static Future<Task> getTask(String id) async {
    try {
      final response = await ApiService.get('/tasks/$id');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Task.fromJson(data);
      } else {
        throw Exception('Failed to load task: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to load task: $e');
    }
  }

  // Create a new task
  static Future<Task> createTask(Task task) async {
    try {
      final body = {
        'name': task.title,
        'description': task.description,
        'status': task.status,
        'userId': task.userId,
      };

      final response = await ApiService.post('/tasks', body);

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Task.fromJson(data);
      } else {
        throw Exception('Failed to create task: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to create task: $e');
    }
  }

  // Update an existing task
  static Future<Task> updateTask(Task task) async {
    try {
      final body = {
        'name': task.title,
        'description': task.description,
        'status': task.status,
        'userId': task.userId,
      };

      final response = await ApiService.put('/tasks/${task.id}', body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Task.fromJson(data);
      } else {
        throw Exception('Failed to update task: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  // Delete a task
  static Future<void> deleteTask(String id) async {
    try {
      final response = await ApiService.delete('/tasks/$id');

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to delete task: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }
}
