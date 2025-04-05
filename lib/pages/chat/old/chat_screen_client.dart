import 'package:flutter/material.dart';
import 'package:client/core/theme/theme.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatScreenClient extends StatefulWidget {
  final Map<String, dynamic> chatSession;

  const ChatScreenClient({Key? key, required this.chatSession}) : super(key: key);

  @override
  _ChatScreenClientState createState() => _ChatScreenClientState();
}

class _ChatScreenClientState extends State<ChatScreenClient> {
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
    try {
      final conversationId = widget.chatSession['id'];
      final userId = widget.chatSession['user_id'];

      final url = Uri.parse('http://localhost:5000/api/chat/$conversationId/$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final profile = data['profile'][0]['User_Conversation_ophthalmologist_idToUser'];

        setState(() {
          firstName = profile['first_name'];
          lastName = profile['last_name'];
          profilePicture = profile['profile_picture'];
        });

        print("Data Loaded: $firstName $lastName, ID: $ophthalmologistId");
      } else {
        print('Failed to load chat details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching chat details: $e');
    }
  }

  void _showMedicalPopup() {
    String ophthalmologistId = widget.chatSession['ophthalmologist_id'].toString();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          backgroundColor: Colors.white,
          content: Container(
            width: MediaQuery.of(context).size.width * 0.6,
            height: 87,
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "เลขที่ใบอนุญาติ (ใบ ว.)",
                  style: TextStyle(fontSize: 14, fontFamily: 'BaiJamjuree', color: Colors.black),
                ),
                SizedBox(height: 5),
                Divider(color: Colors.grey, thickness: 1),
                SizedBox(height: 5),
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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: MainTheme.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(85),
        child: Container(
          margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: MainTheme.chatInfo,
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
                      Navigator.pushReplacementNamed(context, '/chatListView');
                    },
                  ),
                  // SizedBox(width: 8),
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
                        firstName.isNotEmpty ? "$firstName $lastName" : "กำลังโหลด...",
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
                            width: 15,
                            height: 15,
                            decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                          ),
                          SizedBox(width: 4),
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
                  onTap: _showMedicalPopup,
                  child: Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: CircleAvatar(
                      backgroundColor: Colors.pinkAccent,
                      radius: 20,
                      child: Image.asset(
                        'assets/images/medical-assistance.png',
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
}