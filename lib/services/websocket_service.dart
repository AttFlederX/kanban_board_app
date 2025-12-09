import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../config/api_config.dart';
import '../models/websocket_message.dart';
import 'api_service.dart';

// Conditional imports for platform-specific WebSocket implementations
import 'websocket_stub.dart'
    if (dart.library.html) 'websocket_html.dart'
    if (dart.library.io) 'websocket_io.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  StreamController<WebSocketMessage>? _messageController;
  String? _userId;
  Timer? _reconnectTimer;
  bool _intentionallyClosed = false;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 3);

  // Stream of incoming WebSocket messages
  Stream<WebSocketMessage> get messageStream =>
      _messageController?.stream ?? const Stream.empty();

  bool get isConnected => _channel != null;

  // Connect to WebSocket with user authentication
  Future<void> connect(String userId) async {
    if (_channel != null) {
      debugPrint('WebSocketService: Already connected');
      return;
    }

    _userId = userId;
    _intentionallyClosed = false;
    _reconnectAttempts = 0;

    await _establishConnection();
  }

  Future<void> _establishConnection() async {
    try {
      final token = await ApiService.getToken();
      if (token == null || _userId == null) {
        debugPrint('WebSocketService: No token or userId available');
        return;
      }

      // Convert HTTP URL to WebSocket URL
      final wsUrl = _getWebSocketUrl();

      // Create URI with userId and token as query parameters
      // Server accepts JWT as query parameter for all clients
      final uri = Uri.parse('$wsUrl/ws?userId=$_userId&token=$token');

      debugPrint(
        'WebSocketService: Connecting to ${uri.replace(queryParameters: {...uri.queryParameters, 'token': '***'})}',
      );

      // Create WebSocket connection using platform-specific implementation
      _channel = createWebSocketChannel(uri);

      // Initialize message controller if not exists
      _messageController ??= StreamController<WebSocketMessage>.broadcast();

      // Listen to incoming messages
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnect,
        cancelOnError: false,
      );

      _reconnectAttempts = 0;
      debugPrint('WebSocketService: Connected successfully');
    } catch (e) {
      debugPrint('WebSocketService: Connection error: $e');
      _scheduleReconnect();
    }
  }

  void _handleMessage(dynamic message) {
    try {
      debugPrint('WebSocketService: Received message: $message');

      final Map<String, dynamic> json = jsonDecode(message as String);
      final wsMessage = WebSocketMessage.fromJson(json);

      _messageController?.add(wsMessage);
    } catch (e) {
      debugPrint('WebSocketService: Error parsing message: $e');
    }
  }

  void _handleError(error) {
    debugPrint('WebSocketService: Stream error: $error');
    if (error is WebSocketChannelException) {
      debugPrint('WebSocketService: WebSocket error details: ${error.message}');
      debugPrint('WebSocketService: Inner exception: ${error.inner}');
    }
    // Connection will be handled by onDone
  }

  void _handleDisconnect() {
    debugPrint('WebSocketService: Disconnected');
    _channel = null;

    if (!_intentionallyClosed) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_intentionallyClosed || _reconnectAttempts >= _maxReconnectAttempts) {
      if (_reconnectAttempts >= _maxReconnectAttempts) {
        debugPrint(
          'WebSocketService: Max reconnect attempts reached, giving up',
        );
      }
      return;
    }

    _reconnectAttempts++;
    debugPrint(
      'WebSocketService: Scheduling reconnect attempt $_reconnectAttempts/$_maxReconnectAttempts',
    );

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_reconnectDelay, () {
      if (!_intentionallyClosed && _userId != null) {
        _establishConnection();
      }
    });
  }

  // Disconnect from WebSocket
  void disconnect() {
    debugPrint('WebSocketService: Disconnecting');
    _intentionallyClosed = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _channel?.sink.close();
    _channel = null;
    _userId = null;
  }

  // Dispose resources
  void dispose() {
    disconnect();
    _messageController?.close();
    _messageController = null;
  }

  // Get WebSocket URL based on API configuration
  String _getWebSocketUrl() {
    final httpUrl = ApiConfig.baseUrl;

    // Convert http:// to ws:// and https:// to wss://
    if (httpUrl.startsWith('https://')) {
      return httpUrl.replaceFirst('https://', 'wss://');
    } else if (httpUrl.startsWith('http://')) {
      return httpUrl.replaceFirst('http://', 'ws://');
    }

    // Default to ws:// if no protocol specified
    return 'ws://$httpUrl';
  }
}
