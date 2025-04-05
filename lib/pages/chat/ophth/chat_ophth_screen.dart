import 'package:flutter/material.dart';
import 'package:client/widgets/chat_input.dart';
import 'package:client/widgets/message_card.dart';
import 'package:client/pages/chat/ophth/chat_ophth_history.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChatOphthScreen(),
    );
  }
}

class ChatOphthScreen extends StatefulWidget {
  const ChatOphthScreen({super.key});

  @override
  State<ChatOphthScreen> createState() => _ChatOphthScreenState();
}

class _ChatOphthScreenState extends State<ChatOphthScreen> {
  final GlobalKey<MessageCardState> _messageCardKey = GlobalKey<MessageCardState>();

@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: _appBar(),
      ),
      body: Column(
        children: [
          Expanded(child: MessageCard(key: _messageCardKey)), 
        ],
      ),
      bottomNavigationBar: ChatInput(
        onMessageSent: () {
          _messageCardKey.currentState?.refreshMessages();
        },
      ),
    );
  }

  Future<Map<String, dynamic>> fetchProfileData() async {
  final url = Uri.parse('http://localhost:5000/api/chat/186265273/1960006314');
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // เก็บข้อมูลของ profile และ id
      return data['profile'][0]['User_Conversation_user_idToUser'];
    } else {
      throw Exception('Failed to load profile');
    }
  } catch (e) {
    print('Error fetching profile data: $e');
    throw e;
  }
}

  Widget _appBar() {
    return FutureBuilder<Map<String, dynamic>>(
        future: fetchProfileData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data found'));
          } else {
            final profile = snapshot.data!;
            final firstName = profile['first_name'];
            final lastName = profile['last_name'];
            final profilePicture = profile['profile_picture'];

            return Scaffold(
              backgroundColor: Colors.white,
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(85),
                child: Container(
                   margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.blue,
                ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AppBar(
                  automaticallyImplyLeading: false,
                  toolbarHeight: 85,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => ChatOphthHistory()),
                          );
                        },
                      ),
                      SizedBox(width: 8),
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: profilePicture.isNotEmpty
                        ? NetworkImage(profilePicture)
                        : AssetImage('assets/images/doctor.png') as ImageProvider,
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "คุณ$firstName $lastName",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'BaiJamjuree'),
                          ),
                        
                          SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                width: 13,
                                height: 13,
                                decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                              ),
                              SizedBox(width: 5),
                              Text(
                                "ออนไลน์",
                                style: TextStyle(fontSize: 10, color: Colors.grey, fontFamily: 'BaiJamjuree'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  actions: [
                    GestureDetector(
                      onTap: () {
                      },
                      child: Padding(
                        padding: EdgeInsets.only(right: 16),
                        child: CircleAvatar(
                          backgroundColor: Colors.pinkAccent,
                          radius: 20,
                          child: Image.asset(
                          'assets/images/medical_report.png',
                          width: 24,
                          height: 24,
                          fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ),
              ),
            );
          }
        },
      );
    }

}