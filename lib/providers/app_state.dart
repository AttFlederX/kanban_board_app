import 'package:flutter/foundation.dart';
import 'package:kanban_board_app/models/user.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class AppState extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

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
  }

  // Sign out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await AuthService.signOut();
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
}
