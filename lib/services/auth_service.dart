import 'package:flutter/foundation.dart'
    show debugPrint, kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kanban_board_app/models/user.dart';
import 'api_service.dart';

class AuthService {
  static bool _initialized = false;

  // Initialize the GoogleSignIn plugin with platform-specific configuration
  static Future<void> _initialize() async {
    if (_initialized) return; // Already initialized

    final String? clientId = _resolveClientId();

    // Note: serverClientId is not supported on web platform
    // On web, only the web client ID is used via the Google JavaScript API
    final String? serverClientId = kIsWeb ? null : _resolveServerClientId();

    // Initialize GoogleSignIn instance with configuration
    await GoogleSignIn.instance.initialize(
      clientId: clientId,
      serverClientId: serverClientId,
    );

    _initialized = true;
  }

  // Expose safe idempotent initialization for callers that need the plugin
  // ready before rendering UI (e.g., web button rendering).
  static Future<void> ensureInitialized() => _initialize();

  // Set up listener for Google Sign-In events (useful for web)
  static void listenForSignInEvents(Function(User?) onSignIn) {
    GoogleSignIn.instance.authenticationEvents.listen((event) {
      if (event is GoogleSignInAuthenticationEventSignIn) {
        debugPrint('AuthService: Sign-in event detected');
        _handleSignInEvent(event).then(onSignIn);
      }
    });
  }

  // Handle a sign-in event and extract user information
  static Future<User?> _handleSignInEvent(
    GoogleSignInAuthenticationEventSignIn event,
  ) async {
    try {
      final googleUser = event.user;
      final auth = googleUser.authentication;

      debugPrint('AuthService: User email: ${googleUser.email}');

      // Get the ID token for backend authentication
      final String? idToken = auth.idToken;

      if (idToken == null) {
        debugPrint('Failed to obtain ID token from Google');
        return User(
          id: googleUser.id,
          displayName: googleUser.displayName,
          email: googleUser.email,
          photoUrl: googleUser.photoUrl,
        );
      }

      debugPrint('Successfully obtained Google ID token');

      // Exchange Google token with backend
      try {
        final response = await ApiService.authenticateWithGoogle(idToken);
        final backendUser = response.user;
        debugPrint('Backend authentication successful');
        return backendUser;
      } catch (e) {
        debugPrint('Backend authentication failed: $e');
        return User(
          id: googleUser.id,
          displayName: googleUser.displayName,
          email: googleUser.email,
          photoUrl: googleUser.photoUrl,
        );
      }
    } catch (e) {
      debugPrint('Error handling sign-in event: $e');
      return null;
    }
  }

  // Returns the platform-appropriate client ID from dart-define
  // Web requires explicit client ID; other platforms use platform configs
  static String? _resolveClientId() {
    if (kIsWeb) {
      // Web requires an explicit web client ID
      final web = const String.fromEnvironment('GOOGLE_CLIENT_ID_WEB');
      if (web.isNotEmpty) return web;
      // Placeholder for development
      return 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com';
    }

    // For native platforms, return the client ID if provided
    // Otherwise, rely on platform-specific configuration files
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

  // Returns the server client ID for backend authentication
  // This is used to obtain ID tokens that can be verified by your backend
  static String? _resolveServerClientId() {
    const serverClientId = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');
    if (serverClientId.isNotEmpty) return serverClientId;

    // Use platform-specific server client IDs if main one not provided
    if (kIsWeb) {
      const web = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID_WEB');
      if (web.isNotEmpty) return web;
    } else {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          const v = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID_ANDROID');
          if (v.isNotEmpty) return v;
          break;
        case TargetPlatform.iOS:
          const v = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID_IOS');
          if (v.isNotEmpty) return v;
          break;
        case TargetPlatform.macOS:
          const v = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID_MACOS');
          if (v.isNotEmpty) return v;
          break;
        case TargetPlatform.linux:
          const v = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID_LINUX');
          if (v.isNotEmpty) return v;
          break;
        case TargetPlatform.windows:
          const v = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID_WINDOWS');
          if (v.isNotEmpty) return v;
          break;
        default:
          break;
      }
    }

    // Placeholder for development - replace with your actual server client ID
    return 'YOUR_SERVER_CLIENT_ID.apps.googleusercontent.com';
  }

  static Future<User?> signInWithGoogle() async {
    try {
      await _initialize();

      debugPrint('AuthService: Starting Google sign-in...');

      // Start listening for sign-in events
      final signInFuture = GoogleSignIn.instance.authenticationEvents
          .where((event) => event is GoogleSignInAuthenticationEventSignIn)
          .cast<GoogleSignInAuthenticationEventSignIn>()
          .first
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () =>
                throw Exception('Sign-in timeout - no event received'),
          );

      // Attempt lightweight authentication (silent sign-in on native, may show popup on web)
      await GoogleSignIn.instance.attemptLightweightAuthentication();

      if (!kIsWeb) {
        // On native platforms, call authenticate() for interactive sign-in
        debugPrint('AuthService: Triggering authentication...');
        await GoogleSignIn.instance.authenticate();
      }

      debugPrint('AuthService: Waiting for sign-in event...');
      final signInEvent = await signInFuture;
      return await _handleSignInEvent(signInEvent);
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

  // Check if user is currently signed in by checking for stored token
  static Future<bool> isSignedIn() async {
    final token = await ApiService.getToken();
    return token != null && token.isNotEmpty;
  }
}
