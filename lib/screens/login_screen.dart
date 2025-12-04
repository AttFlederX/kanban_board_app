import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kanban_board_app/services/auth_service.dart';
import 'package:kanban_board_app/services/api_service.dart';
import 'package:kanban_board_app/providers/app_state.dart';
import 'package:google_sign_in_web/web_only.dart' as gsw;
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Welcome!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (kIsWeb)
                // Render the official Google Sign-In button and listen for events.
                _WebOfficialButton()
              else
                // Consistent Google-branded button across platforms.
                const _GoogleBrandButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoogleSignInButton extends StatefulWidget {
  @override
  State<_GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<_GoogleSignInButton> {
  bool _loading = false;
  String? _error;

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final appState = context.read<AppState>();
      await appState.signIn();

      if (appState.error != null) {
        setState(() => _error = appState.error);
      }
    } catch (e) {
      setState(
        () => _error = 'Sign-in failed. Please try again.\n${e.toString()}',
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GoogleSignInButton(
          loading: _loading,
          onPressed: _loading ? null : _handleGoogleSignIn,
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!, style: const TextStyle(color: Colors.red)),
        ],
      ],
    );
  }
}

// Consistent Google-branded button widget for non-web platforms.
class GoogleSignInButton extends StatelessWidget {
  final bool loading;
  final VoidCallback? onPressed;
  const GoogleSignInButton({
    super.key,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: kIsWeb ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          side: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading)
              const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              // Simple "G" icon representation; ideally replace with official asset.
              const Icon(Icons.g_mobiledata, color: Colors.black54),
            const SizedBox(width: 8),
            Text(loading ? 'Signing in…' : 'Sign in with Google'),
          ],
        ),
      ),
    );
  }
}

// Wrapper to unify usage in parent layout.
class _GoogleBrandButton extends StatelessWidget {
  const _GoogleBrandButton();
  @override
  Widget build(BuildContext context) {
    return _GoogleSignInButton();
  }
}

class _WebOfficialButton extends StatefulWidget {
  @override
  State<_WebOfficialButton> createState() => _WebOfficialButtonState();
}

class _WebOfficialButtonState extends State<_WebOfficialButton> {
  String? _error;
  bool _initialized = false;
  StreamSubscription<GoogleSignInAuthenticationEvent>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    try {
      await AuthService.ensureInitialized();

      // Navigate when sign-in completes.
      _authSubscription = GoogleSignIn.instance.authenticationEvents.listen(
        (event) async {
          if (event is GoogleSignInAuthenticationEventSignIn) {
            // Get ID token from event for web
            final idToken = event.user.authentication.idToken;

            if (idToken != null) {
              try {
                // Exchange Google token with backend
                final response = await ApiService.authenticateWithGoogle(
                  idToken,
                );
                final backendUser = response.user;

                // Access AppState here, after initialization is complete
                if (mounted) {
                  context.read<AppState>().setUser(backendUser);
                }
              } catch (e) {
                if (mounted) setState(() => _error = e.toString());
              }
            }
          }
        },
        onError: (e) {
          if (mounted) setState(() => _error = e.toString());
        },
      );
      if (mounted) setState(() => _initialized = true);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final button = _initialized
        ? gsw.renderButton()
        : const Center(
            child: SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(),
            ),
          );
    return Column(
      children: [
        SizedBox(height: 48, child: button),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(
            'Sign-in failed. Please try again.\n$_error',
            style: const TextStyle(color: Colors.red),
          ),
        ],
      ],
    );
  }
}
