// Stub file for non-web platforms
// This file is only used when dart.library.html is not available
// On web, the actual google_sign_in_web package is imported instead

import 'package:flutter/material.dart';

class GoogleSignInPlugin {
  Widget renderButton() {
    throw UnimplementedError('Web-only functionality');
  }
}
