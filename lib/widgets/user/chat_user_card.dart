import 'package:client/widgets/user/chat_card_item.dart';
import 'package:flutter/material.dart';
import 'package:client/services/chat_service.dart';

class ChatUserCard extends StatefulWidget {
  const ChatUserCard({super.key});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  final ChatService _chatService = ChatService();

  Future<Map<String, dynamic>> fetchChatData() async {
    try {
      return await _chatService.getChatHistory();
    } catch (e) {
      debugPrint("Error: $e");
      throw Exception("Error fetching data");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: fetchChatData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("เกิดข้อผิดพลาด: ${snapshot.error}"));
        }

        final data = snapshot.data!;
        final latestChatList = data['latest_chat'] as List<dynamic>? ?? [];
        
        final uniqueConversations = <int, dynamic>{};
        for (var chat in latestChatList) {
          final convoId = chat["conversation_id"];
          if (convoId != null && !uniqueConversations.containsKey(convoId)) {
            uniqueConversations[convoId] = chat;
          }
        }

        return Column(
          children: uniqueConversations.entries.map((entry) {
            final chat = entry.value;
            return ChatCardItem(chatData: chat);
          }).toList(),
        );
      },
    );
  }
}