import 'package:client/widgets/user/chat_card_item.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatUserCard extends StatefulWidget {
  const ChatUserCard({super.key});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Future<Map<String, dynamic>> fetchChatData() async {
    final url = "http://localhost:5000/api/chathistory/4";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to load chat history");
      }
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