import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class SocketRequest {
  final String id;
  final Completer<dynamic> completer;
  final Duration timeout;

  SocketRequest({
    required this.id,
    required this.completer,
    this.timeout = const Duration(seconds: 10),
  });
}

class SocketService {
  static SocketService? _instance;

  final String url;
  late WebSocketChannel _channel;
  final Map<String, SocketRequest> _pendingRequests = {};
  late StreamSubscription _subscription;
  bool _isConnected = false;
  final List<Function(Map<String, dynamic>)> _eventListeners = [];

  SocketService._internal({this.url = 'ws://localhost:8080/socket'});

  /// Get singleton instance
  static SocketService getInstance({String? url}) {
    _instance ??= SocketService._internal(
      url: url ?? 'ws://localhost:8080/socket',
    );
    return _instance;
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
      final responseId = decoded['id'] as String?;

      debugPrint('Received message: $decoded'); // Debug log
      
      // Notify all event listeners
      _notifyListeners(decoded);
      
      if (responseId != null && _pendingRequests.containsKey(responseId)) {
        final request = _pendingRequests.remove(responseId);
        request!.completer.complete(decoded);
      }
    } catch (e) {
      debugPrint('Error handling message: $e');
    }
  }

  void _handleError(dynamic error) {
    debugPrint('WebSocket error: $error');
    // Reject all pending requests
    for (final request in _pendingRequests.values) {
      if (!request.completer.isCompleted) {
        request.completer.completeError(error);
      }
    }
    _pendingRequests.clear();
  }

  /// Send a message and wait for a response with the same ID
  Future<dynamic> request(String type, {Map<String, dynamic>? data}) async {
    if (!_isConnected) {
      throw Exception('Socket not connected');
    }

    final requestId = DateTime.now().millisecondsSinceEpoch.toString();
    final completer = Completer<dynamic>();
    final request = SocketRequest(id: requestId, completer: completer);

    _pendingRequests[requestId] = request;

    // Send message
    final message = {
      'id': requestId,
      'type': type,
      if (data != null) ...data,
    };

    try {
      _channel.sink.add(jsonEncode(message));

      debugPrint('Sent message: $message'); // Debug log

      // Await with timeout
      final response =
          await completer.future.timeout(const Duration(seconds: 10));

      debugPrint(
          'Received response for action "$type": $response'); // Debug log

      return response;
    } on TimeoutException {
      _pendingRequests.remove(requestId);
      throw TimeoutException(
        'No response for action: $type',
        const Duration(seconds: 10),
      );
    } catch (e) {
      _pendingRequests.remove(requestId);
      rethrow;
    }
  }

  /// Send a message without expecting a response
  void send(String action, {Map<String, dynamic>? data}) {
    if (!_isConnected) {
      throw Exception('Socket not connected');
    }

    final message = {
      'action': action,
      if (data != null) ...data,
    };

    _channel.sink.add(jsonEncode(message));
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
}

void debugPrint(String message) {
  print(message);
}
