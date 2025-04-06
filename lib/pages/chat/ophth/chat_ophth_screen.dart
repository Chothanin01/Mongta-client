import 'package:client/core/theme/theme.dart';
import 'package:client/widgets/ophth/navbar_ophth.dart';
import 'package:flutter/material.dart';
import 'package:client/widgets/chat_input.dart';
import 'package:client/widgets/message_card.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChatOphthScreen(),
    );
  }
}

class ChatOphthScreen extends StatefulWidget {
  const ChatOphthScreen({super.key});

  @override
  State<ChatOphthScreen> createState() => _ChatOphthScreenState();
}

class _ChatOphthScreenState extends State<ChatOphthScreen> {
  final GlobalKey<MessageCardState> _messageCardKey = GlobalKey<MessageCardState>();

   @override
  void initState() {
    super.initState();
    fetchAndSaveConversationId();
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MainTheme.mainBackground,
      appBar: ChatAppBarOphth(),
      body: Column(
        children: [
          Expanded(child: MessageCard(key: _messageCardKey)), 
        ],
      ),
      bottomNavigationBar: ChatInput(
        onMessageSent: () {
          _messageCardKey.currentState?.refreshMessages();
        },
      ),
    );
  }

Future<void> fetchAndSaveConversationId() async {
  final url = Uri.parse('http://localhost:5000/api/chat/186265273/1960006314');

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // get conversation_id from chatlog
      final conversationId = data['chatlog'][0]['conversation_id'];

      // SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('conversation_id', conversationId);

      print("saved conversation_id: $conversationId");
    } else {
      throw Exception('โหลดข้อมูลไม่สำเร็จ: ${response.statusCode}');
    }
  } catch (e) {
    print('เกิดข้อผิดพลาด: $e');
  }
}

}