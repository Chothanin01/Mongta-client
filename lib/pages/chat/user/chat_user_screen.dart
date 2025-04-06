import 'package:client/widgets/user/navbar_user.dart';
import 'package:flutter/material.dart';
import 'package:client/widgets/chat_input.dart';
import 'package:client/widgets/message_card.dart';
import 'package:client/core/theme/theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChatUserScreen(),
    );
  }
}

class ChatUserScreen extends StatefulWidget {
  const ChatUserScreen({super.key});

  @override
  State<ChatUserScreen> createState() => _ChatUserScreenState();
}

class _ChatUserScreenState extends State<ChatUserScreen> {
  final GlobalKey<MessageCardState> _messageCardKey = GlobalKey<MessageCardState>();

@override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: MainTheme.mainBackground,
      appBar: ChatAppBarUser(),
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
}