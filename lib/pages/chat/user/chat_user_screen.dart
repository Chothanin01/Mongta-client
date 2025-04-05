import 'package:flutter/material.dart';
import 'package:client/pages/chat/user/chat_user_history.dart';
import 'package:client/widgets/chat_input.dart';
import 'package:client/widgets/message_card.dart';
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
      home: ChatUserScreen(),
    );
  }
}

class ChatUserScreen extends StatefulWidget {
  const ChatUserScreen({super.key});

  @override
  State<ChatUserScreen> createState() => _ChatUserScreenState();
}

class _ChatUserScreenState extends State<ChatUserScreen> {
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
  final url = Uri.parse('http://localhost:5000/api/chat/186265273/4');
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // เก็บข้อมูลของ profile และ id
      return data['profile'][0]['User_Conversation_ophthalmologist_idToUser'];
    } else {
      throw Exception('Failed to load profile');
    }
  } catch (e) {
    print('Error fetching profile data: $e');
    throw e;
  }
}

  Widget _appBar() {

    void _showMedicalPopup(String ophthalmologistId) {
      print("Popup is triggered with ID: $ophthalmologistId");

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            backgroundColor: Colors.white,
            content: Container(
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.height * 0.1,
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "เลขที่ใบอนุญาติ (ใบ ว.)",
                    style: TextStyle(fontSize: 14, fontFamily: 'BaiJamjuree', color: Colors.black),
                  ),
                  SizedBox(height: 1),

                  Divider(color: Colors.grey, thickness: 1),
                  
                  SizedBox(height: 1),
                  Text(
                    "เลขที่ : $ophthalmologistId",
                    style: TextStyle(fontSize: 14, fontFamily: 'BaiJamjuree', color: Colors.black),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

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
            final ophthalmologistId = profile['id']; 

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
                            MaterialPageRoute(builder: (context) => ChatUserHistory()),
                          );
                        },
                      ),
                      SizedBox(width: 8),
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: profilePicture.isNotEmpty
                        ? NetworkImage(profilePicture)
                        : AssetImage('images/male_doctor.png') as ImageProvider,
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "$firstName $lastName",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'BaiJamjuree'),
                          ),
                          Text(
                            "จักษุแพทย์ - โรงพยาบาล IMH",
                            style: TextStyle(fontSize: 12, color: Colors.grey, fontFamily: 'BaiJamjuree'),
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
                        print("Tapped!"); 
                        _showMedicalPopup(ophthalmologistId.toString());
                      },
                      child: Padding(
                        padding: EdgeInsets.only(right: 16),
                        child: CircleAvatar(
                          backgroundColor: Colors.pinkAccent,
                          radius: 20,
                          child: Image.asset(
                          'images/medical_assistance.png',
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