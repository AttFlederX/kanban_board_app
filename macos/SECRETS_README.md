# macOS Secret Management

This project uses `.xcconfig` files to keep sensitive credentials out of source control.

## Setup

1. Copy the example file:

   ```bash
   cp macos/Runner/Configs/Secrets.xcconfig.example macos/Runner/Configs/Secrets.xcconfig
   ```

2. Fill in your Google OAuth credentials in `Secrets.xcconfig`:
   - `GID_CLIENT_ID` - Your macOS OAuth client ID
   - `GID_CLIENT_SECRET` - Your OAuth client secret
   - `GID_SERVER_CLIENT_ID` - Your server/backend client ID
   - `GID_REVERSED_CLIENT_ID` - Reversed client ID for URL scheme

## How It Works

- `Secrets.xcconfig` contains the actual credentials (gitignored)
- `Secrets.xcconfig.example` provides a template (committed to git)
- Build configurations (`Debug.xcconfig`, `Release.xcconfig`) include `Secrets.xcconfig`
- `Info.plist` references these values using `$(VARIABLE_NAME)` syntax

## Security Notes

- `Secrets.xcconfig` is in `.gitignore` and will never be committed
- Each developer needs their own copy with valid credentials
- For CI/CD, inject these values as environment variables or secure files
