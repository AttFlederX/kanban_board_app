import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kanban_board_app/providers/app_state.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';

// Conditionally import web-specific button - only loads on web platform
import 'web_button_stub.dart'
    if (dart.library.js_interop) 'package:google_sign_in_web/google_sign_in_web.dart';

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
              // Use the same branded button across all platforms
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

      if (mounted && appState.error != null) {
        setState(() => _error = appState.error);
      }
    } catch (e) {
      if (mounted) {
        setState(
          () => _error = 'Sign-in failed. Please try again.\n${e.toString()}',
        );
      }
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
      width: 240,
      child: ElevatedButton(
        onPressed: onPressed,
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
    if (kIsWeb) {
      return _WebGoogleSignInButton();
    }
    return _GoogleSignInButton();
  }
}

// Web-specific button that uses the platform's button rendering
class _WebGoogleSignInButton extends StatefulWidget {
  @override
  State<_WebGoogleSignInButton> createState() => _WebGoogleSignInButtonState();
}

class _WebGoogleSignInButtonState extends State<_WebGoogleSignInButton> {
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (kIsWeb)
          SizedBox(
            height: 50,
            child: (GoogleSignInPlatform.instance as GoogleSignInPlugin)
                .renderButton(),
          )
        else
          const SizedBox(
            height: 50,
            child: Center(child: Text('Web only button')),
          ),
        if (appState.isLoading) ...[
          const SizedBox(height: 8),
          const CircularProgressIndicator(),
        ],
        if (appState.error != null) ...[
          const SizedBox(height: 8),
          Text(
            appState.error!,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
