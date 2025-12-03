# kanban_board_app

A new Flutter project.

## Development

### Local environment (Google Sign-In)

Use a local env file to provide OAuth client IDs without committing secrets:

- Copy `local.env.example` to `local.env` and set values as needed.
- Web builds require `GOOGLE_CLIENT_ID_WEB`.
- Other platforms: `GOOGLE_CLIENT_ID_<PLATFORM>` is optional here; if unset,
  the plugin initializes without a clientId and relies on platform-side
  configuration (e.g., Info.plist, Android config, etc.). No fallback
  placeholders are used in code.

Run Flutter with dart-defines from the file (examples):

```zsh
# Web
flutter run -d chrome --dart-define-from-file=local.env

# macOS (task provided in workspace)
flutter run -d macos --dart-define-from-file=local.env

# iOS (simulator)
flutter run -d ios --dart-define-from-file=local.env

# Android (emulator/device)
flutter run -d android --dart-define-from-file=local.env

# Linux / Windows (if supported by your Flutter/toolchain)
flutter run -d linux --dart-define-from-file=local.env
flutter run -d windows --dart-define-from-file=local.env
```

`lib/services/auth_service.dart` resolves a per-platform `clientId` at runtime
using `String.fromEnvironment`. If a value is not provided, `null` is passed to
initialization (no server client ID is used), letting the platform handle
configuration. On web there is no legacy fallback variable; only
`GOOGLE_CLIENT_ID_WEB` is used.
