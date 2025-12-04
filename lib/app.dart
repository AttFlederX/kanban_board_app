import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kanban_board_app/screens/login_screen.dart';
import 'package:kanban_board_app/screens/taskboard_screen.dart';
import 'package:kanban_board_app/providers/app_state.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kanban Board',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: Consumer<AppState>(
        builder: (context, appState, _) {
          if (appState.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return appState.isAuthenticated
              ? const TaskboardScreen()
              : const LoginScreen();
        },
      ),
    );
  }
}
