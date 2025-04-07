import 'package:flutter/material.dart';
import 'package:client/core/theme/theme.dart';
import 'package:client/pages/chat/user/chat_search.dart';
import 'package:go_router/go_router.dart';
import 'package:client/services/chat_service.dart';

class ChatEmptyView extends StatefulWidget {
  const ChatEmptyView({super.key});

  @override
  State<ChatEmptyView> createState() => _ChatEmptyViewState();
}

class _ChatEmptyViewState extends State<ChatEmptyView> {
  String? profilePicture;
  String userName = '';
  bool _isLoading = true;
  final ChatService _chatService = ChatService();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
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
      backgroundColor: MainTheme.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
          child: _isLoading 
            ? Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      profilePicture != null
                          ? _buildRoundedBox(context, profilePicture!)
                          : CircleAvatar(
                              radius: MediaQuery.of(context).size.width * 0.09,
                              backgroundColor: Colors.grey[300],
                              child: Icon(Icons.person, size: 40, color: Colors.grey[700]),
                            ),
                      SizedBox(width: 20),
                      _buildBlueBox(context, userName),
                    ],
                  ),
                  SizedBox(height: 40),
                  _buildWhiteBox(context),
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
            color: MainTheme.white,
            fontFamily: 'BaiJamjuree',
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
  
  Widget _buildWhiteBox(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth * 0.85,
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.7,
      ),
      decoration: BoxDecoration(
        color: MainTheme.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: MainTheme.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: screenWidth * 0.5,
              height: screenWidth * 0.5,
              child: Image.asset('assets/images/chat.png'),
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              "ยังไม่เคยมีประวัติแชท",
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                color: MainTheme.black,
                fontFamily: 'BaiJamjuree',
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.center, 
              children: [
                Text(
                  "ค้นหาจักษุแพทย์ ",
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: MainTheme.black,
                    fontFamily: 'BaiJamjuree',
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    context.push('/chat-search');
                  },
                  child: Text(
                    "กดตรงนี้เลย",
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                      color: MainTheme.chatBlue,
                      fontFamily: 'BaiJamjuree',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}