import 'package:client/core/theme/theme.dart';
import 'package:client/pages/chat/user/chat_user_history.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:client/services/chat_service.dart';
import 'package:client/services/user_service.dart';

class ChatAppBarUser extends StatefulWidget implements PreferredSizeWidget {
  final int conversationId;
  
  const ChatAppBarUser({
    super.key,
    required this.conversationId
  });

  @override
  _ChatAppBarUserState createState() => _ChatAppBarUserState();

  @override
  Size get preferredSize => Size.fromHeight(85);
}

class _ChatAppBarUserState extends State<ChatAppBarUser> {
  String firstName = '';
  String lastName = '';
  String profilePicture = '';
  String ophthalmologistId = '';
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
        final profile = chatData['profile'][0]['User_Conversation_ophthalmologist_idToUser'];
        
        setState(() {
          firstName = profile['first_name'] ?? '';
          lastName = profile['last_name'] ?? '';
          profilePicture = profile['profile_picture'] ?? '';
          ophthalmologistId = profile['id'].toString();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Failed to load chat details: $e');
      setState(() => _isLoading = false);
    }
  }

  void _showMedicalPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: MainTheme.chatWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          content: Container(
            height: 87,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "เลขที่ใบอนุญาติ (ใบ ว.)",
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'BaiJamjuree',
                  ),
                ),
                Divider(),
                Text(
                  "เลขที่ : $ophthalmologistId",
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'BaiJamjuree',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return AppBar(
        toolbarHeight: 85,
        backgroundColor: Colors.transparent,
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
      toolbarHeight: 85,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
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
            toolbarHeight: 85,
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: MainTheme.black),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => ChatUserHistory()),
                    );
                  },
                ),
                CircleAvatar(
                  radius: 25,
                  backgroundImage: profilePicture.isNotEmpty
                      ? NetworkImage(profilePicture)
                      : AssetImage('assets/images/doctor.png') as ImageProvider,
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$firstName $lastName",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'BaiJamjuree',
                      ),
                    ),
                    Text(
                      "จักษุแพทย์ - โรงพยาบาล IMH",
                      style: TextStyle(
                        fontSize: 12,
                        color: MainTheme.chatGrey,
                        fontFamily: 'BaiJamjuree',
                      ),
                    ),
                    Row(
                      children: [
                        Container(width: 10, height: 10, decoration: BoxDecoration(color: MainTheme.chatGreen, shape: BoxShape.circle)),
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
              ],
            ),
            actions: [
              GestureDetector(
                onTap: _showMedicalPopup,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: CircleAvatar(
                    backgroundColor: MainTheme.chatPink,
                    radius: 20,
                    child: Image.asset('assets/images/medical_assistance.png', width: 24, height: 24),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
