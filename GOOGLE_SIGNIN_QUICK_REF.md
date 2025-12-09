# Google Sign-In Quick Reference

## Environment Variables Quick Setup

```bash
# 1. Copy the example file
cp local.env.example local.env

# 2. Edit local.env and add your credentials
# Minimum required for web:
GOOGLE_CLIENT_ID_WEB=your_web_client_id.apps.googleusercontent.com
GOOGLE_SERVER_CLIENT_ID=your_server_client_id.apps.googleusercontent.com
```

## Platform-Specific Requirements

| Platform    | Client ID Required         | Additional Config                                 | Notes                                                     |
| ----------- | -------------------------- | ------------------------------------------------- | --------------------------------------------------------- |
| **Web**     | ✅ Required in `local.env` | None                                              | Must configure authorized origins in Google Cloud Console |
| **Android** | ⚠️ Optional                | `google-services.json` OR client ID               | Needs SHA-1 fingerprint in console                        |
| **iOS**     | ⚠️ Optional                | `GoogleService-Info.plist` OR `Info.plist` config | Needs URL scheme (reversed client ID)                     |
| **macOS**   | ⚠️ Optional                | `Info.plist` config                               | Same as iOS                                               |
| **Windows** | ✅ Required in `local.env` | None                                              | Limited support                                           |
| **Linux**   | ✅ Required in `local.env` | None                                              | Limited support                                           |

## Quick Run Commands

```bash
# Using helper script (easiest)
./run_app.sh web
./run_app.sh macos
./run_app.sh android
./run_app.sh ios

# Manual commands
flutter run -d chrome --web-port 58072 --dart-define-from-file local.env
flutter run -d macos --dart-define-from-file local.env
flutter run -d android --dart-define-from-file local.env
flutter run -d ios --dart-define-from-file local.env
```

## Google Cloud Console Checklist

### For Each Platform:

#### Web Application

- [ ] Create Web OAuth 2.0 client
- [ ] Add `http://localhost:58072` to authorized JavaScript origins
- [ ] Add `http://localhost:58072` to authorized redirect URIs
- [ ] Copy Client ID to `GOOGLE_CLIENT_ID_WEB`

#### Android Application

- [ ] Create Android OAuth 2.0 client
- [ ] Add package name: `com.example.kanban_board_app`
- [ ] Add SHA-1 fingerprint (debug):
  ```bash
  keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
  ```
- [ ] Download `google-services.json` (optional) or copy Client ID

#### iOS Application

- [ ] Create iOS OAuth 2.0 client
- [ ] Add Bundle ID from `ios/Runner.xcodeproj`
- [ ] Download `GoogleService-Info.plist` (optional) or copy Client ID
- [ ] Update `ios/Runner/Info.plist` with client ID and URL scheme

#### macOS Application

- [ ] Create macOS OAuth 2.0 client (can reuse iOS if same bundle ID)
- [ ] Add Bundle ID from `macos/Runner.xcodeproj`
- [ ] Update `macos/Runner/Info.plist` with client ID and URL scheme

#### Server Client ID

- [ ] Use the Web Client ID as server client ID
- [ ] Add to `GOOGLE_SERVER_CLIENT_ID` in `local.env`
- [ ] Configure in backend to verify ID tokens

## Common Error Solutions

### "Invalid client ID"

- **Web**: Check `GOOGLE_CLIENT_ID_WEB` is set correctly
- **Native**: Check platform-specific config files or environment variables

### "redirect_uri_mismatch"

- **Web**: Add the exact URL to authorized redirect URIs in Google Cloud Console
- Include protocol (`http://`), host, and port

### "sign_in_failed" on Android

- Verify SHA-1 fingerprint is registered
- Check package name matches `android/app/build.gradle.kts`
- Ensure Google Play Services is installed

### "sign_in_failed" on iOS/macOS

- Check Bundle ID matches Google Cloud Console
- Verify URL scheme in Info.plist (reversed client ID)
- Ensure client IDs are correct

### Backend returns 401

- Verify `GOOGLE_SERVER_CLIENT_ID` matches backend configuration
- Check backend is using correct client ID to verify tokens
- Ensure ID token is being sent correctly

## Code Structure

### Authentication Flow

```
User clicks "Sign in with Google"
    ↓
LoginScreen → AppState.signIn()
    ↓
AuthService.signInWithGoogle()
    ↓
GoogleSignIn.instance.authenticate() (platform-specific)
    ↓
Receive ID token
    ↓
ApiService.authenticateWithGoogle(idToken)
    ↓
Backend verifies token → Returns JWT
    ↓
JWT stored in FlutterSecureStorage
    ↓
User authenticated!
```

### Key Files

- `lib/services/auth_service.dart` - Google Sign-In logic
- `lib/services/api_service.dart` - Backend API communication
- `lib/providers/app_state.dart` - App state management
- `lib/screens/login_screen.dart` - Login UI
- `local.env` - Environment configuration

## Testing Locally

### Web

```bash
# Start your backend (example)
cd ../backend && npm start

# Run Flutter web
./run_app.sh web

# Open http://localhost:58072
```

### Android Emulator

```bash
# Start emulator
emulator -avd Pixel_4_API_30

# Backend should be accessible at http://10.0.2.2:3000
# Update API_BASE_URL in local.env if needed

# Run app
./run_app.sh android
```

### iOS Simulator

```bash
# List available simulators
xcrun simctl list devices available

# Run app
./run_app.sh ios
```

### macOS

```bash
./run_app.sh macos
```

## Production Deployment

### Before deploying:

1. Create separate OAuth credentials for production
2. Use environment-specific client IDs
3. Update authorized domains/URIs for production URLs
4. Never commit `local.env` or production credentials
5. Use secure secret management (e.g., Firebase Remote Config, AWS Secrets Manager)
6. Rotate credentials regularly
7. Enable 2FA on Google Cloud Console

## Getting SHA-1 Fingerprints

### Debug keystore (development)

```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android | grep SHA1
```

### Release keystore (production)

```bash
keytool -list -v -keystore /path/to/your-release.keystore -alias your-alias | grep SHA1
```

### From Google Play Console

- Go to Release Management > App Signing
- Copy SHA-1 from App signing certificate

## Resources

- 📖 [Full Setup Guide](GOOGLE_SIGNIN_SETUP.md)
- 📖 [Main README](README.md)
- 🔗 [google_sign_in package](https://pub.dev/packages/google_sign_in)
- 🔗 [Google Cloud Console](https://console.cloud.google.com/)
- 🔗 [Google Sign-In Documentation](https://developers.google.com/identity)
