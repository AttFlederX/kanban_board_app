# API Integration Complete

## Summary

Successfully integrated the Kanban Board API into your Flutter application based on the integration guide. The app now communicates with your backend server running on port 3000.

## What Was Implemented

### 1. Dependencies Added

- `http: ^1.2.2` - HTTP client for API requests
- `flutter_secure_storage: ^9.2.2` - Secure token storage
- `provider: ^6.1.2` - State management

### 2. New Files Created

#### Configuration

- **`lib/config/api_config.dart`** - Manages API base URL with platform-specific defaults:
  - Android Emulator: `http://10.0.2.2:3000`
  - iOS Simulator/Desktop: `http://localhost:3000`
  - Supports custom URL via `API_BASE_URL` environment variable

#### Services

- **`lib/services/api_service.dart`** - Core API service handling:
  - JWT token storage and management
  - Authenticated HTTP requests (GET, POST, PUT, DELETE)
  - Google OAuth token exchange with backend
- **`lib/services/task_service.dart`** - Task-specific API operations:
  - Get all tasks
  - Get task by ID
  - Create task
  - Update task
  - Delete task

#### State Management

- **`lib/providers/app_state.dart`** - App-wide state provider managing:
  - User authentication state
  - Sign in/out functionality
  - JWT token lifecycle
  - Error handling

### 3. Modified Files

#### Models

- **`lib/models/task_item.dart`** - Enhanced with:

  - `status` field ('todo', 'in_progress', 'done')
  - `userId` field
  - JSON serialization (`toJson`/`fromJson`)
  - `copyWith` method for immutable updates

- **`lib/models/task_status.dart`** - Added:
  - `apiValue` getter for API status strings
  - `fromApiValue` static method for parsing API responses

#### Screens

- **`lib/screens/login_screen.dart`** - Updated to:

  - Call backend API after Google sign-in
  - Store JWT token securely
  - Handle both web and native authentication flows
  - Use AppState provider

- **`lib/screens/taskboard_screen.dart`** - Integrated with API:
  - Load tasks from backend on startup
  - Update tasks via API when edited
  - Move tasks between columns with API sync
  - Show loading/error states
  - Added refresh and sign-out buttons
  - Optimistic UI updates with error rollback

#### App Structure

- **`lib/main.dart`** - Wrapped app with `ChangeNotifierProvider`
- **`lib/app.dart`** - Added authentication routing logic
- **`lib/dialogs/task_edit_dialog.dart`** - Fixed to include new required fields

#### Configuration

- **`local.env.example`** - Added API configuration section with instructions

## Authentication Flow

1. User signs in with Google (web or native)
2. App receives Google ID token
3. App sends ID token to backend `/auth/google` endpoint
4. Backend validates token and returns JWT + user info
5. App stores JWT securely using `flutter_secure_storage`
6. All subsequent API requests include JWT in Authorization header

## API Endpoints Used

- **POST `/auth/google`** - Exchange Google token for JWT (no auth required)
- **GET `/tasks`** - Get all user's tasks (requires JWT)
- **GET `/tasks/:id`** - Get specific task (requires JWT)
- **POST `/tasks`** - Create new task (requires JWT)
- **PUT `/tasks/:id`** - Update task (requires JWT)
- **DELETE `/tasks/:id`** - Delete task (requires JWT)

## Configuration

### For Development

The app uses platform-specific defaults. No additional configuration needed if your backend is running on `localhost:3000`.

### For Physical Devices

1. Start your backend server
2. Find your machine's local IP address:
   ```bash
   # macOS/Linux
   ipconfig getifaddr en0
   # or
   ifconfig | grep "inet "
   ```
3. Update `local.env`:
   ```env
   API_BASE_URL=http://YOUR_LOCAL_IP:3000
   ```
4. Restart the app

### For Production

Update `lib/config/api_config.dart` to point to your production backend URL.

## Next Steps

1. **Start your backend server** on port 3000
2. **Run the Flutter app**:
   ```bash
   flutter run -d macos --dart-define-from-file=local.env
   ```
3. **Test the integration**:
   - Sign in with Google
   - Create, edit, and move tasks
   - Verify changes persist after app restart
   - Test refresh functionality
   - Test sign out

## Error Handling

The app includes comprehensive error handling:

- Network errors show user-friendly messages
- Failed API calls display SnackBar notifications
- Optimistic UI updates with automatic rollback on failure
- Retry buttons for failed loads
- Token expiration redirects to login

## Security Features

- JWT tokens stored securely using platform-specific secure storage
- Tokens included in Authorization header for all authenticated requests
- Tokens cleared on sign out
- HTTPS recommended for production

## Troubleshooting

### "Failed to load tasks" Error

- Ensure backend server is running on port 3000
- Check network connectivity
- Verify JWT token is valid (sign out and back in)

### Android Emulator Connection Issues

- Backend should be accessible at `http://10.0.2.2:3000`
- Check backend CORS configuration allows requests

### iOS Simulator Issues

- Backend should be accessible at `http://localhost:3000`
- Check firewall settings

## Files Structure

```
lib/
├── config/
│   └── api_config.dart          # API base URL configuration
├── services/
│   ├── api_service.dart         # Core HTTP & JWT service
│   ├── auth_service.dart        # Google auth (updated)
│   └── task_service.dart        # Task CRUD operations
├── providers/
│   └── app_state.dart           # App state management
├── models/
│   ├── task_item.dart           # Task model (updated)
│   └── task_status.dart         # Task status enum (updated)
├── screens/
│   ├── login_screen.dart        # Login screen (updated)
│   └── taskboard_screen.dart   # Main board (updated)
├── dialogs/
│   └── task_edit_dialog.dart   # Edit dialog (updated)
├── app.dart                     # App widget (updated)
└── main.dart                    # Entry point (updated)
```

All integration is complete and ready to use! 🎉
