import 'task.dart';

enum WebSocketMessageType {
  create,
  update,
  delete;

  static WebSocketMessageType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'create':
        return WebSocketMessageType.create;
      case 'update':
        return WebSocketMessageType.update;
      case 'delete':
        return WebSocketMessageType.delete;
      default:
        throw ArgumentError('Unknown message type: $value');
    }
  }

  String toApiValue() {
    switch (this) {
      case WebSocketMessageType.create:
        return 'create';
      case WebSocketMessageType.update:
        return 'update';
      case WebSocketMessageType.delete:
        return 'delete';
    }
  }
}

class WebSocketMessage {
  final WebSocketMessageType type;
  final String taskId;
  final String userId;
  final Task? data;

  WebSocketMessage({
    required this.type,
    required this.taskId,
    required this.userId,
    this.data,
  });

  factory WebSocketMessage.fromJson(Map<String, dynamic> json) {
    return WebSocketMessage(
      type: WebSocketMessageType.fromString(json['type'] as String),
      taskId: json['taskId'] as String,
      userId: json['userId'] as String,
      data: json['data'] != null
          ? Task.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toApiValue(),
      'taskId': taskId,
      'userId': userId,
      'data': data?.toJson(),
    };
  }
}
