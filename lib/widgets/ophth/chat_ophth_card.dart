import 'package:client/widgets/ophth/chat_ophth_item.dart';
import 'package:flutter/material.dart';
import 'package:client/services/chat_service.dart';
import 'package:client/services/user_service.dart';

class ChatOphthCard extends StatefulWidget {
  const ChatOphthCard({super.key});

  @override
  State<ChatOphthCard> createState() => _ChatOphthCardState();
}

class _ChatOphthCardState extends State<ChatOphthCard> {
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

      return ListView(
        children: uniqueConversations.entries.map((entry) {
          final chat = entry.value;

          final message = chat['chat'] ?? '';
          final timestamp = chat['timestamp'];
          final profile = chat['profile'] ?? {};
          final name =
              '${profile['first_name'] ?? ''} ${profile['last_name'] ?? ''}';
          final image = profile['profile_picture'] ?? '';

          return ChatOphthItem(
            chatData: {
              'conversation_id': chat['conversation_id'],
              'message': message,
              'timestamp': timestamp,
              'name': name,
              'profile_picture': image,
              'notread': chat['notread'] ?? 0,
            },
          );
        }).toList(),
      );
    },
  );
}
}