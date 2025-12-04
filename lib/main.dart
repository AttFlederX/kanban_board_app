import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kanban_board_app/app.dart';
import 'package:kanban_board_app/providers/app_state.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState()..initialize(),
      child: const App(),
    ),
  );
}
