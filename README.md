# kanban_board_app

A Flutter-based Kanban board application with Google Sign-In authentication across all platforms.

## Features

- **Cross-platform Google Sign-In**: Works on Web, Android, iOS, macOS, Windows, and Linux
- **Backend Authentication**: Exchanges Google ID tokens with backend API for JWT authentication
- **Secure Configuration**: Environment-based configuration without committing secrets
- **Task Management**: Full Kanban board functionality (coming soon)

## Quick Start

### Prerequisites

- Flutter SDK (3.9.0 or higher)
- Dart SDK
- A Google Cloud Console project with OAuth 2.0 credentials

### Setup

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd kanban_board_app
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Configure Google Sign-In**

   See [GOOGLE_SIGNIN_SETUP.md](GOOGLE_SIGNIN_SETUP.md) for detailed instructions on:

   - Creating OAuth 2.0 credentials in Google Cloud Console
   - Configuring client IDs for each platform
   - Setting up server client IDs for backend authentication

4. **Create local.env**

   ```bash
   cp local.env.example local.env
   ```

   Edit `local.env` and add your client IDs:

   ```env
   GOOGLE_CLIENT_ID_WEB=your_web_client_id.apps.googleusercontent.com
   GOOGLE_CLIENT_ID_MACOS=your_macos_client_id.apps.googleusercontent.com
   GOOGLE_SERVER_CLIENT_ID=your_server_client_id.apps.googleusercontent.com
   # ... other platform IDs
   ```

### Running the App

#### Using the helper script (recommended)

```bash
./run_app.sh web      # Run on web
./run_app.sh macos    # Run on macOS
./run_app.sh android  # Run on Android
./run_app.sh ios      # Run on iOS
```

#### Manual commands

```bash
# Web (Chrome, port 58072)
flutter run -d chrome --web-port 58072 --dart-define-from-file local.env

# macOS
flutter run -d macos --dart-define-from-file local.env

# iOS (simulator)
flutter run -d ios --dart-define-from-file local.env

# Android (device/emulator)
flutter run -d android --dart-define-from-file local.env

# Windows
flutter run -d windows --dart-define-from-file local.env

# Linux
flutter run -d linux --dart-define-from-file local.env
```

## Project Structure

```
lib/
├── config/
│   └── api_config.dart          # API endpoint configuration
├── dialogs/
│   └── task_detail_dialog.dart  # Task detail UI
├── models/
│   ├── auth_response.dart       # Authentication response model
│   ├── user.dart                # User model
│   └── ...                      # Other models
├── providers/
│   └── app_state.dart           # App state management
├── screens/
│   └── login_screen.dart        # Login UI
├── services/
│   ├── auth_service.dart        # Google Sign-In integration
│   └── api_service.dart         # Backend API integration
├── widgets/
│   └── ...                      # Reusable widgets
├── app.dart                     # App widget
└── main.dart                    # Entry point
```

## Authentication Flow

1. User clicks "Sign in with Google"
2. Google Sign-In flow is initiated (platform-specific)
3. User authenticates and grants permissions
4. App receives Google ID token
5. ID token is sent to backend `/auth/google` endpoint
6. Backend verifies token and returns JWT
7. JWT is stored securely and used for API requests

## Environment Variables

### Client IDs

- `GOOGLE_CLIENT_ID_WEB`: Web client ID (required for web)
- `GOOGLE_CLIENT_ID_ANDROID`: Android client ID (optional, can use google-services.json)
- `GOOGLE_CLIENT_ID_IOS`: iOS client ID (optional, can use GoogleService-Info.plist)
- `GOOGLE_CLIENT_ID_MACOS`: macOS client ID (optional, can use Info.plist)
- `GOOGLE_CLIENT_ID_WINDOWS`: Windows client ID (required for Windows)
- `GOOGLE_CLIENT_ID_LINUX`: Linux client ID (required for Linux)

### Server Client IDs

- `GOOGLE_SERVER_CLIENT_ID`: Universal server client ID for backend verification
- Platform-specific server client IDs available if needed

### API Configuration

- `API_BASE_URL`: Backend API URL (optional, defaults to platform-specific localhost)

## Platform-Specific Notes

### Web

- Requires explicit web client ID
- Authorized JavaScript origins and redirect URIs must be configured in Google Cloud Console
- Default port: 58072

### Android

- Can use `google-services.json` or environment variable
- Requires SHA-1 fingerprint registration in Google Cloud Console
- Emulator uses `http://10.0.2.2:3000` for localhost access

### iOS/macOS

- Can use `GoogleService-Info.plist` or Info.plist configuration
- Requires URL scheme configuration (reversed client ID)
- Bundle ID must match Google Cloud Console

### Windows/Linux

- Requires client ID via environment variables
- Desktop platforms may have limited Google Sign-In support

## Backend Integration

The app expects a backend API with the following endpoint:

**POST /auth/google**

```json
Request:
{
  "id_token": "eyJhbGciOiJS..."
}

Response:
{
  "token": "jwt_token_here",
  "user": {
    "id": "google_user_id",
    "email": "user@example.com",
    "displayName": "User Name",
    "photoUrl": "https://..."
  }
}
```

See [GOOGLE_SIGNIN_SETUP.md](GOOGLE_SIGNIN_SETUP.md) for backend implementation examples.

## Security

- **Never commit `local.env`** - It's in `.gitignore`
- Use different client IDs for development and production
- Rotate credentials if exposed
- Validate ID tokens on the backend
- Store JWTs securely using `flutter_secure_storage`

## Troubleshooting

See [GOOGLE_SIGNIN_SETUP.md](GOOGLE_SIGNIN_SETUP.md) for common issues and solutions.

## Development Tasks

Pre-configured VS Code tasks are available:

- `Flutter: Web (chrome, port 58072) with local.env`
- `Flutter: macOS with local.env`
- `Flutter: iOS (simulator) with local.env`
- `Flutter: Android (device/emulator) with local.env`
- `Flutter: Windows with local.env`
- `Flutter: Linux with local.env`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is licensed under the MIT License.
