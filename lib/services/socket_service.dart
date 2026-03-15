import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class SocketService {
  static SocketService? _instance;

  final String url;
  late WebSocketChannel _channel;
  late StreamSubscription _subscription;
  bool _isConnected = false;
  final List<Function(Map<String, dynamic>)> _eventListeners = [];
  final Map<String, List<Function(Map<String, dynamic>)>> _broadcastListeners =
      {};

  SocketService._internal({this.url = 'ws://localhost:8080/socket'});

  /// Get singleton instance
  static SocketService getInstance({String? url}) {
    _instance ??= SocketService._internal(
      url: url ?? 'ws://localhost:8080/socket',
    );
    return _instance!;
  }

  /// Reset singleton (for testing)
  static void reset() {
    _instance = null;
  }

  bool get isConnected => _isConnected;

  Future<void> connect() async {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _isConnected = true;

      // Listen to incoming messages
      _subscription = _channel.stream.listen(
        _handleMessage,
        onError: (error) {
          _handleError(error);
        },
        onDone: () {
          _isConnected = false;
        },
      );
    } catch (e) {
      _isConnected = false;
      rethrow;
    }
  }

  void _handleMessage(dynamic message) {
    try {
      final decoded = jsonDecode(message as String);
      final messageType = decoded['type'] as String?;

      debugPrint('Received message: $decoded');

      // Notify all event listeners
      _notifyListeners(decoded);

      // Notify broadcast listeners for specific message types
      if (messageType != null) {
        _notifyBroadcastListeners(messageType, decoded);
      }
    } catch (e) {
      debugPrint('Error handling message: $e');
    }
  }

  void _handleError(dynamic error) {
    debugPrint('WebSocket error: $error');
  }

  /// Send a message (fire-and-forget)
  void request(String type, {Map<String, dynamic>? data}) {
    if (!_isConnected) {
      throw Exception('Socket not connected');
    }

    final message = {
      'type': type,
      if (data != null) ...data,
    };

    try {
      _channel.sink.add(jsonEncode(message));
      debugPrint('Sent message: $message');
    } catch (e) {
      debugPrint('Error sending message: $e');
      rethrow;
    }
  }

  Future<void> dispose() async {
    await _subscription.cancel();
    await _channel.sink.close();
    _isConnected = false;
  }

  /// Register a listener for all incoming socket events
  void onEvent(Function(Map<String, dynamic>) listener) {
    _eventListeners.add(listener);
  }

  /// Remove a listener
  void offEvent(Function(Map<String, dynamic>) listener) {
    _eventListeners.remove(listener);
  }

  /// Notify all listeners of an event
  void _notifyListeners(Map<String, dynamic> event) {
    for (final listener in _eventListeners) {
      try {
        listener(event);
      } catch (e) {
        debugPrint('Error in event listener: $e');
      }
    }
  }

  /// Register a listener for a specific broadcast message type
  void onBroadcast(
      String messageType, Function(Map<String, dynamic>) listener) {
    _broadcastListeners.putIfAbsent(messageType, () => []);
    _broadcastListeners[messageType]!.add(listener);
  }

  /// Remove a broadcast listener
  void offBroadcast(
      String messageType, Function(Map<String, dynamic>) listener) {
    _broadcastListeners[messageType]?.remove(listener);
    if (_broadcastListeners[messageType]?.isEmpty ?? false) {
      _broadcastListeners.remove(messageType);
    }
  }

  /// Notify broadcast listeners for a specific message type
  void _notifyBroadcastListeners(
      String messageType, Map<String, dynamic> message) {
    final listeners = _broadcastListeners[messageType];
    if (listeners != null) {
      for (final listener in listeners) {
        try {
          listener(message);
        } catch (e) {
          debugPrint('Error in broadcast listener for $messageType: $e');
        }
      }
    }
  }
}

void debugPrint(String message) {
  print(message);
}
