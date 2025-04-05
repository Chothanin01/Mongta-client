// import 'package:flutter/material.dart';
// import 'package:client/core/theme/theme.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class ChatWait extends StatefulWidget {
//   final Map<String, dynamic> chatSession;

//   const ChatWait({Key? key, required this.chatSession}) : super(key: key);

//   @override
//   _ChatWaitState createState() => _ChatWaitState();
// }

// class _ChatWaitState extends State<ChatWait> {
//   String firstName = '';
//   String lastName = '';
//   String profilePicture = '';

//   @override
//   void initState() {
//     super.initState();
//     print("Received ChatSession in ChatWait: ${widget.chatSession}");
//     fetchChatDetails();
//   }

//   void fetchChatDetails() async {
//     try {
//       final conversationId = widget.chatSession['id'];
//       final userId = widget.chatSession['user_id'];

//       // สร้าง URL สำหรับการร้องขอ
//       final url = Uri.parse('http://localhost:5000/api/chat/$conversationId/$userId');
      
//       // ส่งคำขอ GET
//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         // ถ้าคำขอสำเร็จ
//         final data = jsonDecode(response.body);

//         // ดึงค่าจาก response ที่ได้
//         final profile = data['profile'][0]['User_Conversation_ophthalmologist_idToUser'];
        
//         setState(() {
//           firstName = profile['first_name'];
//           lastName = profile['last_name'];
//           profilePicture = profile['profile_picture'];
//         });

//         print("First Name: $firstName, Last Name: $lastName, Profile Picture: $profilePicture");
//       } else {
//         // ถ้าเกิดข้อผิดพลาดในการดึงข้อมูล
//         print('Failed to load chat details: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error fetching chat details: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Chat Wait")),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             firstName.isNotEmpty && lastName.isNotEmpty
//                 ? Text(' $firstName $lastName')
//                 : CircularProgressIndicator(),
//             SizedBox(height: 10),
//             profilePicture.isNotEmpty
//                 ? Image.network(profilePicture)
//                 : SizedBox.shrink(),
//           ],
//         ),
//       ),
//     );
//   }
// }