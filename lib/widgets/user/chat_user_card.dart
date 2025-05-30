import 'package:client/widgets/user/chat_card_item.dart';
import 'package:flutter/material.dart';
import 'package:client/services/chat_service.dart';
import 'package:go_router/go_router.dart';
import 'package:client/core/theme/theme.dart';

class ChatUserCard extends StatefulWidget {
  final VoidCallback? onRefresh;
  
  const ChatUserCard({super.key, this.onRefresh});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  final ChatService _chatService = ChatService();
  List<dynamic> _chatHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchChatHistory();
  }

  @override
  void didUpdateWidget(ChatUserCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    fetchChatHistory();
  }

  Future<void> fetchChatHistory() async {
    try {
      setState(() => _isLoading = true);
      final chatData = await _chatService.getChatHistory();
      
      if (mounted) {
        setState(() {
          _chatHistory = chatData['latest_chat'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching chat history: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_chatHistory.isEmpty) {
      return Center(
        child: Text(
          'ยังไม่มีประวัติการแชท',
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'BaiJamjuree',
            color: MainTheme.placeholderText,
          ),
        ),
      );
    }

    final uniqueConversations = <int, dynamic>{};
    for (var chat in _chatHistory) {
      final convoId = chat["conversation_id"];
      if (convoId != null && !uniqueConversations.containsKey(convoId)) {
        uniqueConversations[convoId] = chat;
      }
    }

    return RefreshIndicator(
      onRefresh: () async {
        await fetchChatHistory();
        if (widget.onRefresh != null) {
          widget.onRefresh!();
        }
      },
      child: ListView(
        children: uniqueConversations.entries.map((entry) {
          final chat = entry.value;
          
          // Get the message content - backend uses 'chat' key
          final String message = chat['chat'] ?? '';
          final conversationId = chat['conversation_id'];
          final notReadCount = chat['notread'] ?? 0;
          final timestamp = chat['timestamp'] ?? '';
          
          // Get profile info - backend provides this as a nested object
          final profile = chat['profile'] ?? {};
          final profilePicture = profile['profile_picture'] ?? '';
          
          return GestureDetector(
            onTap: () {
              context.push('/chat-user-screen/$conversationId').then((_) {
                fetchChatHistory();
                if (widget.onRefresh != null) {
                  widget.onRefresh!();
                }
              });
            },
            child: ChatCardItem(
              chatData: {
                'conversation_id': conversationId,
                'chat': message,  // Changed from 'message' to 'chat'
                'profile': profile, // Use the profile object directly from backend
                'profile_picture': profilePicture, // Also include directly for backward compatibility
                'notread': notReadCount,
                'timestamp': timestamp,
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}