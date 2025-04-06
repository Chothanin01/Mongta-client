import 'package:client/pages/chat/user/chat_search.dart';
import 'package:client/widgets/user/chat_user_card.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:client/core/theme/theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChatUserHistory(),
    );
  }
}

class ChatUserHistory extends StatefulWidget {
  const ChatUserHistory({super.key});

  @override
  _ChatUserHistoryState createState() => _ChatUserHistoryState();
}

class _ChatUserHistoryState extends State<ChatUserHistory> {
  String? profilePicture;
  String userName = '';
  List<dynamic> chatHistory = [];

  @override
  void initState() {
    super.initState();
    fetchChatData();
  }

  Future<void> fetchChatData() async {
    final response = await http.get(Uri.parse('http://localhost:5000/api/chathistory/4'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final user = data['user'];

      print('Profile: ${user['profile_picture']}');
      print('Name: ${user['first_name']} ${user['last_name']}');

      setState(() {
        profilePicture = user['profile_picture'];
        userName = '${user['first_name']} ${user['last_name']}';
      });
    } else {
      print('API Error: ${response.statusCode}');
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
              _buildSearchRow(),
              SizedBox(height: 20),
              ChatUserCard(),
            ]   
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
            color: MainTheme.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

   Widget _buildSearchRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          'ค้นหาจักษุแพทย์ ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: MainTheme.black,
            fontFamily: 'BaiJamjuree'),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ChatSearch()),
              );
          print("ค้นหาจักษุแพทย์");
          },
          child: Text(
            'กดตรงนี้เลย',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'BaiJamjuree',
              color: MainTheme.chatBlue),
          ),
        ),
      ],
    );
  }
}