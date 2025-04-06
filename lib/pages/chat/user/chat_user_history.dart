import 'package:flutter/material.dart';
import 'package:client/widgets/user/chat_user_card.dart';
import 'package:client/core/theme/theme.dart';
import 'package:client/services/chat_service.dart';
import 'package:client/pages/chat/user/chat_user_screen.dart';

class ChatUserHistory extends StatefulWidget {
  const ChatUserHistory({super.key});

  @override
  _ChatUserHistoryState createState() => _ChatUserHistoryState();
}

class _ChatUserHistoryState extends State<ChatUserHistory> {
  String? profilePicture;
  String userName = '';  
  List<dynamic> chatHistory = [];
  bool isLoading = true;  
  final _chatService = ChatService();

  @override
  void initState() {
    super.initState();
    fetchChatData();
  }

  Future<void> fetchChatData() async {
    try {
      setState(() => isLoading = true);
      
      final data = await _chatService.getChatHistory();
      
      if (data['success'] == true) {
        final user = data['user'];
        
        setState(() {
          profilePicture = user['profile_picture'];
          userName = '${user['first_name']} ${user['last_name']}';
          chatHistory = data['latest_chat'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('API Error: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MainTheme.mainBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 40),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    profilePicture != null
                        ? _buildRoundedBox(context, profilePicture!)
                        : Center(child: CircularProgressIndicator()),

                    const SizedBox(width: 20),
                    _buildBlueBox(context, userName),
                  ],
                ),
              ),
              SizedBox(height: 20),

              Expanded(
                child: isLoading 
                ? Center(child: CircularProgressIndicator())
                : chatHistory.isEmpty
                  ? Center(child: Text('No chat history found'))
                  : ListView.builder(
                      itemCount: chatHistory.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final chat = chatHistory[index];
                        return ChatUserCard(
                          chatData: chat,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatUserScreen(
                                  conversationId: chat['conversation_id'],
                                ),
                              ),
                            );
                          },
                        );
                      }, 
                    )
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoundedBox(BuildContext context, String imageUrl) {
    double boxSize = MediaQuery.of(context).size.width * 0.18;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.network(
        imageUrl,
        width: boxSize,
        height: boxSize,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildBlueBox(BuildContext context, String text) {
    double boxWidth = MediaQuery.of(context).size.width * 0.55;
    double boxHeight = MediaQuery.of(context).size.width * 0.18;

    return Container(
      width: boxWidth,
      height: boxHeight,
      decoration: BoxDecoration(
        color: MainTheme.chatBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}