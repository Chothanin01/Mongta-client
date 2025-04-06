import 'dart:convert';
import 'package:client/widgets/ophth/chat_ophth_card.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChatOphthHistory(),
    );
  }
}

class ChatOphthHistory extends StatefulWidget {
  const ChatOphthHistory({super.key});

  @override
  _ChatOphthHistoryState createState() => _ChatOphthHistoryState();
}

class _ChatOphthHistoryState extends State<ChatOphthHistory> {
  String? profilePicture;
  String userName = '';
  List<dynamic> chatHistory = [];

  @override
  void initState() {
    super.initState();
    fetchChatData();
  }

  Future<void> fetchChatData() async {
    final response = await http.get(Uri.parse('http://localhost:5000/api/chathistory/1960006314'));
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
      backgroundColor: Colors.white,
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
              ChatOphthCard(),
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