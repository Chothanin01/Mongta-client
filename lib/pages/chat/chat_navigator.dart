import 'package:flutter/material.dart';
import 'package:client/services/chat_service.dart';
import 'package:client/pages/chat/user/chat_empty_view.dart';
import 'package:client/pages/chat/user/chat_user_history.dart';
import 'package:client/pages/chat/ophth/chat_ophth_history.dart';
import 'package:client/services/user_service.dart';
import 'package:client/services/user_api_service.dart'; 

class ChatNavigator extends StatefulWidget {
  const ChatNavigator({super.key});

  @override
  State<ChatNavigator> createState() => _ChatNavigatorState();
}

class _ChatNavigatorState extends State<ChatNavigator> {
  final _chatService = ChatService();
  final _apiService = ApiService(); // Create instance
  bool _isLoading = true;
  bool _hasHistory = false;
  bool _isOphthalmologist = false;

  @override
  void initState() {
    super.initState();
    _checkUserAndHistory();
  }

  Future<void> _checkUserAndHistory() async {
    try {
      setState(() => _isLoading = true);
      
      // Check if user is an ophthalmologist
      final userId = await UserService.getCurrentUserId();
      final userData = await _apiService.getUser(userId); // Now use the instance
      _isOphthalmologist = userData['is_opthamologist'] ?? false;
      
      // Get chat history
      final chatData = await _chatService.getChatHistory();
      final chatHistory = chatData['latest_chat'] ?? [];
      
      setState(() {
        _hasHistory = chatHistory.isNotEmpty;
        _isLoading = false;
      });
    } catch (e) {
      print('Error checking chat history: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    // If ophthalmologist, always show their chat history screen
    if (_isOphthalmologist) {
      return const ChatOphthHistory();
    }
    
    // For regular users, check if they have chat history
    return _hasHistory 
        ? const ChatUserHistory() 
        : const ChatEmptyView();
  }
}