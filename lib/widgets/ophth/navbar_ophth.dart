import 'package:client/core/theme/theme.dart';
import 'package:client/pages/chat/ophth/chat_ophth_history.dart';
import 'package:client/pages/scanlogopht/scanlogopht.dart';
import 'package:flutter/material.dart';
import 'package:client/services/chat_service.dart';
import 'package:client/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

class ChatAppBarOphth extends StatefulWidget implements PreferredSizeWidget {
  final int conversationId;
  
  const ChatAppBarOphth({
    super.key,
    required this.conversationId
  });

  @override
  ChatAppBarOphthState createState() => ChatAppBarOphthState();

  @override
  Size get preferredSize {
    return Size.fromHeight(kToolbarHeight * 1.5);
  }
}

class ChatAppBarOphthState extends State<ChatAppBarOphth> {
  String firstName = '';
  String lastName = '';
  String profilePicture = '';
  bool _isLoading = true;
  final ChatService _chatService = ChatService();

  @override
  void initState() {
    super.initState();
    fetchChatDetails();
  }

  void fetchChatDetails() async {
    try {
      final userId = await UserService.getCurrentUserId();
      final chatData = await _chatService.getChatMessages(widget.conversationId);
      
      if (chatData.containsKey('profile') && chatData['profile'].isNotEmpty) {
        final profile = chatData['profile'][0]['User_Conversation_user_idToUser'];
        
        if (mounted) {
          setState(() {
            firstName = profile['first_name'] ?? '';
            lastName = profile['last_name'] ?? '';
            profilePicture = profile['profile_picture'] ?? '';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Failed to load chat details: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveConversationId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('conversation_id', widget.conversationId);
    } catch (e) {
      print('Error saving conversation ID: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final responsiveHeight = screenHeight * 0.10;
    final toolbarHeight = responsiveHeight.clamp(45.0, 65.0); 

    if (_isLoading) {
      return AppBar(
        toolbarHeight: toolbarHeight,
        backgroundColor: MainTheme.transparent,
        elevation: 0,
        flexibleSpace: Container(
          margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
          decoration: BoxDecoration(
            color: MainTheme.chatInfo,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return AppBar(
      toolbarHeight: toolbarHeight,
      automaticallyImplyLeading: false,
      backgroundColor: MainTheme.transparent,
      elevation: 0,
      flexibleSpace: Container(
        margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
        decoration: BoxDecoration(
          color: MainTheme.chatInfo,
          borderRadius: BorderRadius.circular(20),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: AppBar(
            automaticallyImplyLeading: false,
            toolbarHeight: toolbarHeight,
            backgroundColor: MainTheme.transparent,
            elevation: 0,
            title: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: MainTheme.black),
                  onPressed: () {
                    // Use go_router instead of Navigator.pop() for consistent navigation
                    context.go('/chat');
                  },
                ),
                CircleAvatar(
                  radius: 25,
                  backgroundImage: profilePicture.isNotEmpty
                      ? NetworkImage(profilePicture)
                      : AssetImage('assets/images/MongtaLogo.png') as ImageProvider,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$firstName $lastName",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'BaiJamjuree',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Container(
                            width: 10, 
                            height: 10, 
                            decoration: BoxDecoration(
                              color: MainTheme.chatGreen, 
                              shape: BoxShape.circle
                            )
                          ),
                          SizedBox(width: 5),
                          Text(
                            "ออนไลน์",
                            style: TextStyle(
                              fontSize: 10,
                              color: MainTheme.chatGrey,
                              fontFamily: 'BaiJamjuree',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              GestureDetector(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: CircleAvatar(
                    backgroundColor: MainTheme.chatPink,
                    radius: 20,
                    child: IconButton(
                      icon: Icon(Icons.insert_chart, color: MainTheme.black, size: 24),
                      onPressed: () async {
                        await _saveConversationId();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ScanHistoryScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
