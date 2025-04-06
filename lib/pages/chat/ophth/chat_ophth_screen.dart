import 'package:flutter/material.dart';
import 'package:client/widgets/chat_input.dart';
import 'package:client/widgets/message_card.dart';
import 'package:client/pages/chat/ophth/chat_ophth_history.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: _appBar(),
      ),
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

  Future<Map<String, dynamic>> fetchProfileData() async {
  final url = Uri.parse('http://localhost:5000/api/chat/186265273/1960006314');
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // เก็บข้อมูลของ profile และ id
      return data['profile'][0]['User_Conversation_user_idToUser'];
    } else {
      throw Exception('Failed to load profile');
    }
  } catch (e) {
    print('Error fetching profile data: $e');
    throw e;
  }
}

}