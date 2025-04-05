import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ChatUserCard extends StatefulWidget {
  const ChatUserCard({super.key});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
  }

  class _ChatUserCardState extends State<ChatUserCard> {
    
    // API get
    Future<Map<String, dynamic>> fetchChatData() async {
    final url = "http://localhost:5000/api/chathistory/1960006314";

    try {
      final response = await http.get(Uri.parse(url));

      debugPrint("Request: GET $url");
      debugPrint("Response (${response.statusCode}): ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load chat history");
    }
  } catch (e) {
    debugPrint("Error: $e");
    throw Exception("Error fetching data");
  }
}

    @override
    Widget build(BuildContext context) {
      return Card(
        child: InkWell(
          onTap: () {},
          child: FutureBuilder<Map<String, dynamic>>(
            future: fetchChatData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
              return ListTile(
                leading: CircleAvatar(child: Icon(CupertinoIcons.person)),
                title: Text("กำลังโหลด..."),
                subtitle: Text("โปรดรอสักครู่"),
                trailing: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return ListTile(
                leading: CircleAvatar(child: Icon(CupertinoIcons.person)),
                title: Text("เกิดข้อผิดพลาด"),
                subtitle: Text(snapshot.error.toString()),
              );
            }
            
            // API get
            var data = snapshot.data!;
            var latestChatList = data['latest_chat'] as List<dynamic>? ?? [];

            if (latestChatList.isEmpty) {
              return ListTile(
                leading: CircleAvatar(child: Icon(CupertinoIcons.person)),
                title: Text("ไม่มีข้อมูลผู้ใช้"),
                subtitle: Text("ไม่มีข้อความล่าสุด"),
                trailing: Text(""),
              );
            }

            var latestChat = latestChatList[0];
            
            // get from User_Conversation_ophthalmologist_idToUser
            var userData = latestChat["Conversation"]["User_Conversation_user_idToUser"] ?? {};

            String userName = "${userData["first_name"] ?? "Unknown"} ${userData["last_name"] ?? ""}";
            String profilePicture = userData["profile_picture"] ?? "";
            String lastMessage = latestChat["chat"] ?? "ไม่มีข้อความ";
            String timestamp = latestChat["timestamp"] ?? "";
            int notread = latestChat["notread"] ?? 0;
            
            // convert timestamp to HH:mm
            String formattedTime = "";
            if (timestamp.isNotEmpty) {
              DateTime parsedTime = DateTime.parse(timestamp);
              formattedTime = DateFormat("HH:mm").format(parsedTime);
            }

           return Container(
                  width: 314,
                  height: 62,
                  decoration: BoxDecoration(
                    color: notread >= 1 ? Colors.pink : Colors.grey,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 23,
                        backgroundImage: profilePicture.isNotEmpty
                            ? NetworkImage(profilePicture)
                            : null,
                        child: profilePicture.isEmpty ? Icon(CupertinoIcons.person) : null,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                            Text(
                              lastMessage,
                              style: TextStyle(fontSize: 12, color: notread >= 1 ? Colors.white : Colors.black),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            formattedTime,
                            style: TextStyle(fontSize: 14, color: Colors.black),
                          ),
                          if (notread >= 1)
                            Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                              alignment: Alignment.center,
                              child: Text(
                                notread.toString(),
                                style: TextStyle(fontSize: 14, color: Colors.white),
                              ),
                            ),
                          if (notread == 0)
                            Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.black,
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      } 
    }