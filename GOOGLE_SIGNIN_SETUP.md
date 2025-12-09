# Google Sign-In Configuration Guide

This document explains how to configure Google Sign-In for all platforms in your Flutter app.

## Overview

The app uses `google_sign_in` package (v7.x) with support for:

- Web
- Android
- iOS
- macOS
- Windows
- Linux

## Configuration Steps

### 1. Google Cloud Console Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the **Google Sign-In API**
4. Create OAuth 2.0 credentials for each platform:

#### Web Client ID

- Type: Web application
- Authorized JavaScript origins: `http://localhost:58072` (or your web server URL)
- Authorized redirect URIs: `http://localhost:58072` (or your web server URL)

#### Android Client ID

- Type: Android
- Package name: `com.example.kanban_board_app` (from `android/app/build.gradle.kts`)
- SHA-1 certificate fingerprint (debug): Get using `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`

#### iOS Client ID

- Type: iOS
- Bundle ID: `com.example.kanbanBoardApp` (from `ios/Runner.xcodeproj`)

#### macOS Client ID

- Type: macOS
- Bundle ID: `com.example.kanbanBoardApp` (from `macos/Runner.xcodeproj`)

#### Server Client ID (Important!)

- This is typically your **Web Client ID** that your backend will use to verify ID tokens
- All platforms can share the same server client ID

### 2. Environment Configuration

Update `local.env` with your client IDs:

```env
# Web (Required for web platform)
GOOGLE_CLIENT_ID_WEB=YOUR_WEB_CLIENT_ID.apps.googleusercontent.com

# Android (Optional - can use google-services.json instead)
GOOGLE_CLIENT_ID_ANDROID=YOUR_ANDROID_CLIENT_ID.apps.googleusercontent.com

# iOS (Optional - can use GoogleService-Info.plist instead)
GOOGLE_CLIENT_ID_IOS=YOUR_IOS_CLIENT_ID.apps.googleusercontent.com

# macOS (Optional - can use Info.plist instead)
GOOGLE_CLIENT_ID_MACOS=YOUR_MACOS_CLIENT_ID.apps.googleusercontent.com

# Windows (Required for Windows)
GOOGLE_CLIENT_ID_WINDOWS=YOUR_WINDOWS_CLIENT_ID.apps.googleusercontent.com

# Linux (Required for Linux)
GOOGLE_CLIENT_ID_LINUX=YOUR_LINUX_CLIENT_ID.apps.googleusercontent.com

# Server Client ID - Used for backend authentication
GOOGLE_SERVER_CLIENT_ID=YOUR_SERVER_CLIENT_ID.apps.googleusercontent.com
```

### 3. Platform-Specific Configuration

#### Web

- Client ID is configured via environment variables
- No additional files needed

#### Android

**Option 1: Using google-services.json (Recommended)**

1. Download `google-services.json` from Firebase Console or Google Cloud Console
2. Place it in `android/app/google-services.json`

**Option 2: Using environment variables**

- Set `GOOGLE_CLIENT_ID_ANDROID` in `local.env`

#### iOS

**Option 1: Using GoogleService-Info.plist (Recommended)**

1. Download `GoogleService-Info.plist` from Firebase Console or Google Cloud Console
2. Add it to your Xcode project in `ios/Runner`

**Option 2: Manual configuration (Current setup)**

1. Update `ios/Runner/Info.plist`:
   ```xml
   <key>GIDClientID</key>
   <string>YOUR_IOS_CLIENT_ID.apps.googleusercontent.com</string>
   <key>GIDServerClientID</key>
   <string>YOUR_SERVER_CLIENT_ID.apps.googleusercontent.com</string>
   <key>CFBundleURLTypes</key>
   <array>
       <dict>
           <key>CFBundleURLSchemes</key>
           <array>
               <string>com.googleusercontent.apps.YOUR_IOS_CLIENT_ID</string>
           </array>
       </dict>
   </array>
   ```

#### macOS

Update `macos/Runner/Info.plist` (similar to iOS):

```xml
<key>GIDClientID</key>
<string>YOUR_MACOS_CLIENT_ID.apps.googleusercontent.com</string>
<key>GIDServerClientID</key>
<string>YOUR_SERVER_CLIENT_ID.apps.googleusercontent.com</string>
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.YOUR_MACOS_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

#### Windows & Linux

- Configure client IDs via environment variables in `local.env`

## Running the App

### Web

```bash
flutter run -d chrome --web-port 58072 --dart-define-from-file local.env
```

### Android

```bash
flutter run -d android --dart-define-from-file local.env
```

### iOS

```bash
flutter run -d ios --dart-define-from-file local.env
```

### macOS

```bash
flutter run -d macos --dart-define-from-file local.env
```

### Windows

```bash
flutter run -d windows --dart-define-from-file local.env
```

### Linux

```bash
flutter run -d linux --dart-define-from-file local.env
```

## Backend Authentication

The app sends the Google ID token to your backend at `/auth/google` endpoint:

```dart
POST /auth/google
{
  "id_token": "eyJhbGciOiJS..."
}
```

Your backend should:

1. Verify the ID token using Google's token verification library
2. Extract user information (email, name, etc.)
3. Create or update user in your database
4. Return a JWT token for subsequent API calls

Example verification (Node.js):

```javascript
const { OAuth2Client } = require("google-auth-library");
const client = new OAuth2Client(process.env.GOOGLE_SERVER_CLIENT_ID);

async function verifyGoogleToken(idToken) {
  const ticket = await client.verifyIdToken({
    idToken: idToken,
    audience: process.env.GOOGLE_SERVER_CLIENT_ID,
  });
  const payload = ticket.getPayload();
  return payload; // Contains email, name, picture, etc.
}
```

## Troubleshooting

### Web

- Ensure authorized JavaScript origins and redirect URIs are set correctly
- Check browser console for CORS or configuration errors

### Android

- Verify SHA-1 fingerprint matches the one in Google Cloud Console
- Check package name matches `android/app/build.gradle.kts`
- Ensure Google Play Services is installed on device/emulator

### iOS/macOS

- Verify Bundle ID matches the one in Google Cloud Console
- Check URL scheme is properly configured (reversed client ID)
- Ensure Info.plist has correct client IDs

### Common Errors

- `PlatformException(sign_in_failed)`: Check client ID configuration
- `Invalid client ID`: Verify client ID matches platform
- `redirect_uri_mismatch`: Update authorized redirect URIs in Google Cloud Console

## Security Notes

1. **Never commit `local.env`** - It's in `.gitignore` for a reason
2. **Use different client IDs** for development and production
3. **Server Client ID** should match what your backend expects
4. **Rotate credentials** if they're ever exposed
5. For production, consider using Firebase Remote Config or secure environment management

## Additional Resources

- [google_sign_in package documentation](https://pub.dev/packages/google_sign_in)
- [Google Sign-In for iOS](https://developers.google.com/identity/sign-in/ios)
- [Google Sign-In for Android](https://developers.google.com/identity/sign-in/android)
- [Google Sign-In for Web](https://developers.google.com/identity/gsi/web)
