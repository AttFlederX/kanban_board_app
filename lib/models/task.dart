class Task {
  String id;
  String title;
  String description;
  String status; // 'todo', 'in_progress', or 'done'
  String userId;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.userId,
  });

  // Create Task from JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['name'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      userId: json['userId'] as String,
    );
  }

  // Convert Task to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': title,
      'description': description,
      'status': status,
      'userId': userId,
    };
  }

  // Create a copy with updated fields
  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    String? userId,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      userId: userId ?? this.userId,
    );
  }
}
