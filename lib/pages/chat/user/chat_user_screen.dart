import 'package:client/widgets/user/navbar_user.dart';
import 'package:flutter/material.dart';
import 'package:client/widgets/chat_input.dart';
import 'package:client/widgets/message_card.dart';
import 'package:client/core/theme/theme.dart';
import 'package:client/services/chat_polling_service.dart';

class ChatUserScreen extends StatefulWidget {
  final int conversationId;

  const ChatUserScreen({
    super.key, 
    required this.conversationId
  });

  @override
  State<ChatUserScreen> createState() => _ChatUserScreenState();
}

class _ChatUserScreenState extends State<ChatUserScreen> {
  final GlobalKey<MessageCardState> _messageCardKey = GlobalKey<MessageCardState>();
  
  @override
  void initState() {
    super.initState();
    ChatPollingService.startPollingForChat(widget.conversationId);
  }

  @override
  void dispose() {
    // Stop polling when screen is closed
    ChatPollingService.stopPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MainTheme.mainBackground,
      appBar: ChatAppBarUser(conversationId: widget.conversationId),
      body: Column(
        children: [
          Expanded(
            child: MessageCard(
              key: _messageCardKey,
              conversationId: widget.conversationId,
            )
          ), 
        ],
      ),
      bottomNavigationBar: ChatInput(
        onMessageSent: () {
          _messageCardKey.currentState?.refreshMessages();
        },
        conversationId: widget.conversationId,
      ),
    );
  }
}