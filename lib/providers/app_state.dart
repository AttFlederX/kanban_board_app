import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:kanban_board_app/models/user.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../services/websocket_service.dart';
import '../models/websocket_message.dart';

class AppState extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
  final WebSocketService _webSocketService = WebSocketService();
  StreamSubscription<WebSocketMessage>? _wsSubscription;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  // Expose WebSocket message stream
  Stream<WebSocketMessage> get taskUpdates => _webSocketService.messageStream;

  // Initialize app state - check for existing token
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await ApiService.getToken();
      if (token != null) {
        // Token exists, but we don't have user info stored
        // You might want to add a /me endpoint to fetch current user
        // For now, we'll just set loading to false
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign in with Google
  Future<void> signIn() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await AuthService.signInWithGoogle();
      debugPrint('AppState: Sign-in completed, user: ${user?.email}');
      _user = user;
      _error = null;

      // Connect to WebSocket after successful sign-in
      if (user != null) {
        await _connectWebSocket(user.id);
      }
    } catch (e) {
      debugPrint('AppState: Sign-in error: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      debugPrint('AppState: isAuthenticated = $isAuthenticated');
      notifyListeners();
    }
  }

  // Sign in with user data (for web callback)
  void setUser(User user) {
    _user = user;
    notifyListeners();

    // Connect to WebSocket
    _connectWebSocket(user.id);
  }

  // Connect to WebSocket
  Future<void> _connectWebSocket(String userId) async {
    try {
      debugPrint('AppState: Connecting to WebSocket for user: $userId');
      await _webSocketService.connect(userId);
    } catch (e) {
      debugPrint('AppState: WebSocket connection error: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await AuthService.signOut();
      _webSocketService.disconnect();
      _user = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _webSocketService.dispose();
    _wsSubscription?.cancel();
    super.dispose();
  }
}
