import 'package:client/widgets/ophth/chat_ophth_card.dart';
import 'package:flutter/material.dart';
import 'package:client/services/chat_service.dart';
import 'package:client/pages/chat/ophth/chat_ophth_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:client/core/router/path.dart';

class ChatOphthHistory extends StatefulWidget {
  const ChatOphthHistory({super.key});

  @override
  _ChatOphthHistoryState createState() => _ChatOphthHistoryState();
}

class _ChatOphthHistoryState extends State<ChatOphthHistory> {
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            context.go('/home-opht');
          },
        ),
        title: Text(
          "แชท",
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'BaiJamjuree',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
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
                  ? Center(child: Text('ไม่พบประวัติการแชท'))
                  : ListView.builder(
                      itemCount: chatHistory.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final chat = chatHistory[index];
                        return ChatOphthCard(
                          chatData: chat,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatOphthScreen(
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
        color: Colors.blue,
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