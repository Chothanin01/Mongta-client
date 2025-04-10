import 'package:client/core/theme/theme.dart';
import 'package:client/widgets/ophth/navbar_ophth.dart';
import 'package:flutter/material.dart';
import 'package:client/widgets/chat_input.dart';
import 'package:client/widgets/message_card.dart';
import 'package:client/services/chat_service.dart';
import 'package:client/services/chat_polling_service.dart';

class ChatOphthScreen extends StatefulWidget {
  final int conversationId;

  const ChatOphthScreen({
    super.key,
    required this.conversationId,
  });

  @override
  State<ChatOphthScreen> createState() => _ChatOphthScreenState();
}

class _ChatOphthScreenState extends State<ChatOphthScreen> {
  final GlobalKey<MessageCardState> _messageCardKey = GlobalKey<MessageCardState>();
  final ChatService _chatService = ChatService();
  
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
    return WillPopScope(
      onWillPop: () async {
        // Trigger refresh when using hardware back button
        ChatPollingService.stopPolling();
        Navigator.of(context).pop(true); // Pass true to indicate refresh needed
        return false;
      },
      child: Scaffold(
        backgroundColor: MainTheme.mainBackground,
        appBar: ChatAppBarOphth(conversationId: widget.conversationId),
        body: Column(
          children: [
            Expanded(
              child: MessageCard(
                key: _messageCardKey,
                conversationId: widget.conversationId,
              ),
            ),
          ],
        ),
        bottomNavigationBar: ChatInput(
          onMessageSent: () {
            _messageCardKey.currentState?.refreshMessages();
          },
          conversationId: widget.conversationId,
        ),
      ),
    );
  }
}