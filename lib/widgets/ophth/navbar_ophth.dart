import 'package:client/core/theme/theme.dart';
import 'package:client/pages/chat/ophth/chat_ophth_history.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatAppBarOphth extends StatefulWidget implements PreferredSizeWidget {
  const ChatAppBarOphth({super.key});

  @override
  ChatAppBarOphthState createState() => ChatAppBarOphthState();

  @override
  Size get preferredSize => Size.fromHeight(85);
}

class ChatAppBarOphthState extends State<ChatAppBarOphth> {
  String firstName = '';
  String lastName = '';
  String profilePicture = '';

  @override
  void initState() {
    super.initState();
    fetchChatDetails();
  }

  void fetchChatDetails() async {
    final url = Uri.parse('http://localhost:5000/api/chat/186265273/1960006314');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final profile = data['profile'][0]['User_Conversation_user_idToUser'];

      setState(() {
        firstName = profile['first_name'];
        lastName = profile['last_name'];
        profilePicture = profile['profile_picture'];
      });
    } else {
      print('Failed to load chat details: ${response.statusCode}');
    }
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
                            MaterialPageRoute(builder: (context) => ChatOphthHistory()),
                          );
                        },
                ),
                CircleAvatar(
                  radius: 25,
                  backgroundImage: profilePicture.isNotEmpty
                      ? NetworkImage(profilePicture)
                      : AssetImage('assets/images/MongtaLogo.png') as ImageProvider,
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("$firstName $lastName", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: CircleAvatar(
                    backgroundColor: MainTheme.chatPink,
                    radius: 20,
                    child: IconButton(
                      icon: Icon(Icons.insert_chart_outlined, color: MainTheme.black, size: 24),
                      onPressed:  () {
                        Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => ChatOphthHistory()),
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
