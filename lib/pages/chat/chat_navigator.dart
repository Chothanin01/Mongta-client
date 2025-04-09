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
  final _apiService = ApiService();
  bool _isLoading = true;
  bool _hasHistory = false;
  bool _isOphthalmologist = false;

  @override
  void initState() {
    super.initState();
    _checkUserAndHistory();
  }

  // Make this public so it can be called from outside
  Future<void> _checkUserAndHistory() async {
    try {
      setState(() => _isLoading = true);
      
      // Check if user is an ophthalmologist
      final userId = await UserService.getCurrentUserId();
      final userData = await _apiService.getUser(userId);
      _isOphthalmologist = userData['is_opthamologist'] ?? false;
      
      // Get chat history
      final chatData = await _chatService.getChatHistory();
      final chatHistory = chatData['latest_chat'] ?? [];
      
      if (mounted) {
        setState(() {
          _hasHistory = chatHistory.isNotEmpty;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error checking chat history: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    try {
      // If ophthalmologist, always show their chat history screen
      if (_isOphthalmologist) {
        return const ChatOphthHistory();
      }
      
      // For regular users, check if they have chat history
      // Pass the refresh function to ChatUserHistory
      return _hasHistory 
          ? ChatUserHistory(onRefresh: _checkUserAndHistory)
          : const ChatEmptyView();
    } catch (e) {
      // Safety fallback if something fails
      debugPrint('Error in ChatNavigator: $e');
      return Scaffold(
        body: Center(
          child: Text('เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง',
            style: TextStyle(fontFamily: 'BaiJamjuree')
          ),
        ),
      );
    }
  }
}