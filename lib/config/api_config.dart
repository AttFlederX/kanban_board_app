import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  static String get baseUrl {
    // Read from environment variable
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }

    // Default URLs based on platform
    if (kIsWeb) {
      return 'http://localhost:3000';
    }

    // Platform-specific URLs
    try {
      if (Platform.isAndroid) {
        // Android emulator uses 10.0.2.2 to access host machine
        return 'http://10.0.2.2:3000';
      } else if (Platform.isIOS) {
        // iOS simulator can use localhost
        return 'http://localhost:3000';
      } else if (Platform.isMacOS) {
        return 'http://localhost:3000';
      } else if (Platform.isWindows || Platform.isLinux) {
        return 'http://localhost:3000';
      }
    } catch (e) {
      // Fallback if Platform is not available
      return 'http://localhost:3000';
    }

    return 'http://localhost:3000';
  }
}
