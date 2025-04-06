import 'package:client/core/theme/theme.dart';
import 'package:client/pages/chat/user/chat_user_history.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatAppBarUser extends StatefulWidget implements PreferredSizeWidget {
  const ChatAppBarUser({super.key});

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

  @override
  void initState() {
    super.initState();
    fetchChatDetails();
  }

  void fetchChatDetails() async {
    final url = Uri.parse('http://localhost:5000/api/chat/186265273/4');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final profile = data['profile'][0]['User_Conversation_ophthalmologist_idToUser'];

      setState(() {
        firstName = profile['first_name'];
        lastName = profile['last_name'];
        profilePicture = profile['profile_picture'];
        ophthalmologistId = profile['id'].toString();
      });
    } else {
      print('Failed to load chat details: ${response.statusCode}');
    }
  }

  void _showMedicalPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          content: Container(
            height: 87,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("เลขที่ใบอนุญาติ (ใบ ว.)", style: TextStyle(fontSize: 14)),
                Divider(),
                Text("เลขที่ : $ophthalmologistId", style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    Text("$firstName $lastName", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text("จักษุแพทย์ - โรงพยาบาล IMH", style: TextStyle(fontSize: 12, color: MainTheme.chatGrey)),
                    Row(
                      children: [
                        Container(width: 10, height: 10, decoration: BoxDecoration(color: MainTheme.chatGreen, shape: BoxShape.circle)),
                        SizedBox(width: 5),
                        Text("ออนไลน์", style: TextStyle(fontSize: 10, color: MainTheme.chatGrey)),
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
