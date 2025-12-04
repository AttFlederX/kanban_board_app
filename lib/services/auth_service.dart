import 'package:flutter/foundation.dart'
    show debugPrint, kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kanban_board_app/models/user.dart';
import 'api_service.dart';

class AuthService {
  // Initialize the plugin (required on v7+), providing web clientId when on web.
  static Future<void> _initialize() async {
    final String? clientId = _resolveClientId();
    await GoogleSignIn.instance.initialize(clientId: clientId);
  }

  // Expose safe idempotent initialization for callers that need the plugin
  // ready before rendering UI (e.g., web button rendering).
  static Future<void> ensureInitialized() => _initialize();

  // Returns the platform-appropriate client ID from dart-define, or a
  // placeholder for non-web platforms when not provided.
  static String? _resolveClientId() {
    if (kIsWeb) {
      // Web requires an explicit web client ID.
      final web = const String.fromEnvironment('GOOGLE_CLIENT_ID_WEB');
      return web.isNotEmpty ? web : null;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        final v = const String.fromEnvironment('GOOGLE_CLIENT_ID_ANDROID');
        return v.isNotEmpty ? v : null;
      case TargetPlatform.iOS:
        final v = const String.fromEnvironment('GOOGLE_CLIENT_ID_IOS');
        return v.isNotEmpty ? v : null;
      case TargetPlatform.macOS:
        final v = const String.fromEnvironment('GOOGLE_CLIENT_ID_MACOS');
        return v.isNotEmpty ? v : null;
      case TargetPlatform.linux:
        final v = const String.fromEnvironment('GOOGLE_CLIENT_ID_LINUX');
        return v.isNotEmpty ? v : null;
      case TargetPlatform.windows:
        final v = const String.fromEnvironment('GOOGLE_CLIENT_ID_WINDOWS');
        return v.isNotEmpty ? v : null;
      case TargetPlatform.fuchsia:
        return null;
    }
  }

  static Future<User?> signInWithGoogle() async {
    try {
      await _initialize();

      // Start lightweight auth (does not prompt the user).
      GoogleSignIn.instance.attemptLightweightAuthentication();
      if (kIsWeb) {
        // On web, interactive auth must be started via the Google-rendered button.
        // The login_screen will render it and listen for events; return null here.
        return null;
      }

      // On non-web platforms, interactive authenticate is supported.
      await GoogleSignIn.instance.authenticate();

      // Wait for the sign-in event and extract identity details.
      final GoogleSignInAuthenticationEventSignIn evt = await GoogleSignIn
          .instance
          .authenticationEvents
          .where((e) => e is GoogleSignInAuthenticationEventSignIn)
          .cast<GoogleSignInAuthenticationEventSignIn>()
          .first;

      // v7 provides identity fields in the sign-in event.
      final id = evt.user.id;
      final displayName = evt.user.displayName;
      final email = evt.user.email;
      final photoUrl = evt.user.photoUrl;

      if (id.isEmpty) return null;

      // Get Google ID token for backend authentication from the event
      final idToken = evt.user.authentication.idToken;

      if (idToken != null) {
        // Exchange Google token with backend
        final response = await ApiService.authenticateWithGoogle(idToken);
        final backendUser = response.user;

        return backendUser;
      }

      return User(
        id: id,
        displayName: displayName,
        email: email,
        photoUrl: photoUrl,
      );
    } on Exception catch (e) {
      debugPrint('Google sign-in failed: $e');
      rethrow;
    }
  }

  static Future<void> signOut() async {
    try {
      await _initialize();
      await GoogleSignIn.instance.signOut();
      await ApiService.clearToken();
    } on Exception catch (e) {
      debugPrint('Google sign-out failed: $e');
    }
  }
}
