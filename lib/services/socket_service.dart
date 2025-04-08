import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';
import 'package:client/services/user_service.dart';
import 'package:client/services/http_client.dart';

class SocketService {
  static IO.Socket? _socket;
  static bool _initialized = false;
  static bool _connecting = false;
  
  // Stream controllers for chat events
  static final StreamController<Map<String, dynamic>> _newMessageController = 
      StreamController<Map<String, dynamic>>.broadcast();
  static Stream<Map<String, dynamic>> get onNewMessage => _newMessageController.stream;

  // Initialize socket connection
  static Future<void> initSocket() async {
    if (_initialized || _connecting) return;

    _connecting = true;
    debugPrint('Initializing socket...');

    try {
      // Clear existing socket if any
      if (_socket != null) {
        _socket!.dispose();
        _socket = null;
      }

      final userId = await UserService.getCurrentUserId();
      if (userId.isEmpty) {
        debugPrint('Cannot initialize socket: empty user ID');
        _connecting = false;
        return;
      }

      final socketUrl = HttpClient.socketUrl;
      debugPrint('Connecting to socket server at: $socketUrl');

      _socket = IO.io(
        socketUrl,
        IO.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .disableAutoConnect()
          .setExtraHeaders({'userId': userId})
          .enableForceNew()
          .setReconnectionAttempts(5)     // Try to reconnect 5 times
          .setReconnectionDelay(3000)     // Wait 3 seconds between attempts
          .build()
      );

      _socket!.onConnect((_) {
        debugPrint('Socket connected successfully');
        _initialized = true;
        _connecting = false;
        setStatus('online');
      });

      // Add listeners for chat events
      _socket!.on('newMessage', (data) {
        debugPrint('Received new message: $data');
        _newMessageController.add(data);
      });

      _socket!.on('joinRoom', (data) {
        debugPrint('Room joined notification: $data');
        // Handle room joining if needed
      });

      _socket!.on('newChat', (data) {
        debugPrint('New chat created: $data');
        // Handle new chat creation if needed
      });

      _socket!.onConnectError((error) {
        debugPrint('Socket connection error: $error');
        _connecting = false;
        _initialized = false;
      });

      _socket!.onDisconnect((_) {
        debugPrint('Socket disconnected');
        _initialized = false;
        _connecting = false;
      });

      _socket!.connect();
    } catch (e) {
      debugPrint('Socket initialization exception: $e');
      _connecting = false;
      _initialized = false;
    }
  }

  // Add a method to reconnect without changing state variables
  static Future<void> reconnect() async {
    if (_socket != null && !_socket!.connected) {
      debugPrint('Attempting to reconnect socket');
      _socket!.connect();
    }
  }

  // Join a conversation room
  static void joinRoom(String conversationId, String userId) {
    if (_socket != null && _socket!.connected) {
      debugPrint('Joining room: $conversationId as user: $userId');
      _socket!.emit('join', {
        'conversationId': conversationId,
        'userId': userId
      });
    } else {
      debugPrint('Cannot join room: socket not connected');
    }
  }

  // Set user status
  static void setStatus(String status) {
    debugPrint('Setting status to: $status');
    if (_socket != null && _socket!.connected) {
      _socket!.emit('status_change', {'status': status});
    }
  }

  // Disconnect socket
  static void disconnect() {
    if (_socket != null) {
      debugPrint('Disconnecting socket');
      try {
        if (_socket!.connected) {
          _socket!.emit('status_change', {'status': 'offline'});
        }
        _socket!.disconnect();
      } catch (e) {
        debugPrint('Error during socket disconnect: $e');
      } finally {
        _initialized = false;
      }
    }
  }

  // Check if socket is connected
  static bool get isConnected {
    return _socket != null && _socket!.connected;
  }
  
  // Clean up resources
  static void dispose() {
    _newMessageController.close();
    disconnect();
  }
}