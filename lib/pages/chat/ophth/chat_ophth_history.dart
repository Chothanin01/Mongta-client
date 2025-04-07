import 'package:client/widgets/ophth/chat_ophth_card.dart';
import 'package:flutter/material.dart';
import 'package:client/services/chat_service.dart';
import 'package:client/core/theme/theme.dart';
import 'package:go_router/go_router.dart';

class ChatOphthHistory extends StatefulWidget {
  const ChatOphthHistory({super.key});

  @override
  _ChatOphthHistoryState createState() => _ChatOphthHistoryState();
}

class _ChatOphthHistoryState extends State<ChatOphthHistory> {
  String? profilePicture;
  String userName = '';
  final ChatService _chatService = ChatService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchChatData();
  }

  Future<void> fetchChatData() async {
    try {
      setState(() => _isLoading = true);
      final chatData = await _chatService.getChatHistory();
      
      if (chatData.containsKey('user')) {
        final user = chatData['user'];
        setState(() {
          profilePicture = user['profile_picture'];
          userName = '${user['first_name']} ${user['last_name']}';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('API Error: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            context.go('/home-opht');
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
          child: _isLoading 
            ? Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        profilePicture != null
                            ? _buildRoundedBox(context, profilePicture!)
                            : CircleAvatar(
                                radius: MediaQuery.of(context).size.width * 0.09,
                                backgroundColor: Colors.grey[300],
                                child: Icon(Icons.person, size: 40, color: Colors.grey[700]),
                              ),
                        const SizedBox(width: 20),
                        _buildBlueBox(context, userName),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Expanded(child: ChatOphthCard()),
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
        errorBuilder: (context, error, stackTrace) => Container(
          width: boxSize,
          height: boxSize,
          color: Colors.grey[300],
          child: Icon(Icons.person, size: boxSize * 0.6, color: Colors.grey[700]),
        ),
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
            fontFamily: 'BaiJamjuree',
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}