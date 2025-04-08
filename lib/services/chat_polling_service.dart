import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:client/services/user_service.dart';
import 'package:client/services/chat_service.dart';


class ChatPollingService {
  static Timer? _pollingTimer;
  static final StreamController<Map<String, dynamic>> _messageController = 
      StreamController<Map<String, dynamic>>.broadcast();
  
  static Stream<Map<String, dynamic>> get onNewMessage => _messageController.stream;
  
  // Chat data cache to track what we've already seen
  static Map<int, DateTime> _lastMessageTimestamps = {};
  
  // Start polling for specific conversation
  static void startPollingForChat(int conversationId) {
    stopPolling(); // Stop any existing polling
    
    debugPrint('Starting polling for conversation: $conversationId');
    
    // Poll every 3 seconds
    _pollingTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      _pollForNewMessages(conversationId);
    });
  }
  
  static Future<void> _pollForNewMessages(int conversationId) async {
    try {
      // Get the current user ID
      final chatService = ChatService();
      final userId = await UserService.getCurrentUserId();
      
      // Fetch latest messages
      final chatData = await chatService.getChatMessages(conversationId);
      
      // Process new messages (those not in our cache)
      if (chatData.containsKey('chatlog')) {
        final chatLog = chatData['chatlog'] as List<dynamic>;
        
        if (chatLog.isNotEmpty) {
          final lastTimestamp = _lastMessageTimestamps[conversationId];
          
          // Find newest message
          DateTime newestMessageTime = DateTime.parse(chatLog.first['timestamp']);
          
          // Check for new messages
          for (var message in chatLog) {
            final messageTime = DateTime.parse(message['timestamp']);
            
            // If this is a new message we haven't seen
            if (lastTimestamp == null || messageTime.isAfter(lastTimestamp)) {
              _messageController.add({
                'sender_id': message['sender_id'],
                'message': message['chat'],
                'timestamp': message['timestamp'],
                'conversation_id': conversationId
              });
            }
            
            // Track newest message
            if (messageTime.isAfter(newestMessageTime)) {
              newestMessageTime = messageTime;
            }
          }
          
          // Update our timestamp cache
          _lastMessageTimestamps[conversationId] = newestMessageTime;
        }
      }
    } catch (e) {
      debugPrint('Error polling for messages: $e');
    }
  }
  
  // Manual refresh (for user-triggered refreshes)
  static Future<void> refreshMessages(int conversationId) async {
    await _pollForNewMessages(conversationId);
  }
  
  // Stop polling
  static void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }
  
  // Clean up resources
  static void dispose() {
    stopPolling();
    _messageController.close();
  }
}