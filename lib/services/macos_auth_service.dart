import 'dart:io' show Platform;
import 'package:flutter/services.dart';

class MacOSAuthService {
  static const _channel = MethodChannel('com.kanban_board_app/macos_auth');

  static bool get isMacOS => Platform.isMacOS;

  static Future<String?> signInWithGoogle() async {
    if (!isMacOS) {
      throw UnsupportedError('This method is only available on macOS');
    }

    try {
      final result = await _channel.invokeMethod('signInWithGoogle');
      if (result is Map) {
        return result['idToken'] as String?;
      }
      return null;
    } on PlatformException catch (e) {
      throw Exception('macOS Google Sign-in failed: ${e.message}');
    }
  }
}
