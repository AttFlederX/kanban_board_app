// WebSocket implementation for native platforms (IO)
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

WebSocketChannel createWebSocketChannel(Uri uri) {
  return IOWebSocketChannel.connect(uri);
}
