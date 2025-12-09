# WebSocket Live Updates Implementation

## Overview

This implementation adds real-time task updates to the Kanban Board app using WebSockets. Tasks are automatically synchronized across all connected clients when they are created, updated, or deleted.

**Note**: The backend WebSocket endpoint expects the JWT token as a query parameter: `ws://localhost:<PORT>/ws?userId=<USER_ID>&token=<JWT_TOKEN>`

## Architecture

### 1. WebSocket Message Model (`lib/models/websocket_message.dart`)

- Defines the structure for WebSocket messages
- Three message types: `create`, `update`, `delete`
- Includes task ID, user ID, and task data (null for delete operations)

### 2. WebSocket Service (`lib/services/websocket_service.dart`)

Key features:

- **Automatic Connection**: Connects to `ws://localhost:<PORT>/ws?userId=<USER_ID>&token=<JWT_TOKEN>`
- **Authentication**: Sends JWT token as a query parameter
- **Auto-Reconnect**: Automatically attempts to reconnect up to 5 times with 3-second delays
- **Message Stream**: Broadcasts incoming messages to subscribers
- **Platform Support**: Automatically converts HTTP URLs to WebSocket URLs (http → ws, https → wss)

### 3. AppState Integration (`lib/providers/app_state.dart`)

- WebSocket service is initialized as part of the app state
- Automatically connects when user signs in
- Automatically disconnects when user signs out
- Exposes `taskUpdates` stream for components to subscribe to

### 4. TaskboardScreen Updates (`lib/screens/taskboard_screen.dart`)

Real-time update handling:

- **Create**: Adds new tasks to the appropriate column
- **Update**: Moves tasks between columns when status changes, updates task details
- **Delete**: Removes tasks from all columns
- Only processes messages for the current user (filtered by userId)

## How It Works

### Connection Flow

1. User signs in via Google authentication
2. JWT token is obtained and stored
3. WebSocket connects to server with userId and JWT token
4. Server validates token and establishes connection
5. TaskboardScreen subscribes to message stream

### Message Processing

1. Server sends WebSocket message when any task changes
2. WebSocketService receives and parses JSON message
3. Message is broadcast to all stream subscribers
4. TaskboardScreen receives message and updates UI accordingly
5. UI updates happen automatically without manual refresh

### Reconnection

- If connection drops, service automatically attempts reconnection
- Maximum 5 attempts with 3-second delays
- Reconnection includes re-authentication with stored JWT token

## Usage

### No Code Changes Required

The implementation is automatic and transparent:

- Users sign in normally
- WebSocket connects automatically
- Tasks update in real-time
- No manual refresh needed

### Configuration

WebSocket URL is derived from API configuration in `lib/config/api_config.dart`:

- Development: `ws://localhost:3000/ws`
- Android: `ws://10.0.2.2:3000/ws`
- iOS/macOS: `ws://localhost:3000/ws`

## Dependencies Added

```yaml
web_socket_channel: ^3.0.1
```

## Files Modified

1. `pubspec.yaml` - Added web_socket_channel dependency
2. `lib/models/websocket_message.dart` - New file
3. `lib/services/websocket_service.dart` - New file
4. `lib/providers/app_state.dart` - Added WebSocket integration
5. `lib/screens/taskboard_screen.dart` - Added live update handling

## Testing

To test the implementation:

1. Open the app on multiple devices/windows
2. Create, update, or delete a task on one device
3. Observe automatic updates on all other connected devices
4. Test reconnection by temporarily stopping the backend server

## Error Handling

- Connection errors are logged to console
- Failed reconnection attempts are logged
- UI continues to work with manual refresh if WebSocket fails
- No crashes or blocking if WebSocket is unavailable

## Future Enhancements

- Add visual indicator for WebSocket connection status
- Show toast notifications when receiving updates from other sessions
- Add optimistic UI updates with rollback on error
- Support for task assignment notifications
- Typing indicators for collaborative editing
