import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatUserCard extends StatefulWidget {
  final Map<String, dynamic> chatData;
  final VoidCallback onTap;

  const ChatUserCard({
    super.key,
    required this.chatData,
    required this.onTap,
  });

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  @override
  Widget build(BuildContext context) {
    final conversation = widget.chatData['Conversation'] ?? {};
    final userData = conversation['User_Conversation_ophthalmologist_idToUser'] ?? {};

    String userName = "${userData["first_name"] ?? "Unknown"} ${userData["last_name"] ?? ""}";
    String profilePicture = userData["profile_picture"] ?? "";
    String lastMessage = widget.chatData["chat"] ?? "ไม่มีข้อความ";
    String timestamp = widget.chatData["timestamp"] ?? "";
    int notread = widget.chatData["notread"] ?? 0;

    String formattedTime = "";
    if (timestamp.isNotEmpty) {
      DateTime parsedTime = DateTime.parse(timestamp);
      formattedTime = DateFormat("HH:mm").format(parsedTime);
    }

    return Card(
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
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
        ),
      ),
    );
  }
}