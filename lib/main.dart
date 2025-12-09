import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kanban_board_app/app.dart';
import 'package:kanban_board_app/providers/app_state.dart';
import 'package:kanban_board_app/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Google Sign-In
  await AuthService.ensureInitialized();

  runApp(
    ChangeNotifierProvider(
      create: (context) {
        final appState = AppState()..initialize();

        // On web, set up a listener for authentication events from the button
        if (kIsWeb) {
          AuthService.listenForSignInEvents((user) {
            if (user != null) {
              appState.setUser(user);
            }
          });
        }

        return appState;
      },
      child: const App(),
    ),
  );
}
