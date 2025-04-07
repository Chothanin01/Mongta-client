import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:client/pages/chat/user/chat_user_screen.dart';

class ChatCardItem extends StatelessWidget {
  final dynamic chatData;
  const ChatCardItem({required this.chatData, super.key});

  @override
  Widget build(BuildContext context) {
    final userData = chatData["Conversation"]["User_Conversation_ophthalmologist_idToUser"] ?? {};
    final userName = "${userData["first_name"] ?? "Unknown"} ${userData["last_name"] ?? ""}";
    final profilePicture = userData["profile_picture"] ?? "";
    final lastMessage = chatData["chat"] ?? "ไม่มีข้อความ";
    final timestamp = chatData["timestamp"] ?? "";

    final notreadRaw = chatData["notread"];
    final notread = notreadRaw is int
        ? notreadRaw
        : int.tryParse(notreadRaw?.toString() ?? '') ?? 0;

    String formattedTime = "";
    if (timestamp.isNotEmpty) {
      final parsedTime = DateTime.tryParse(timestamp);
      if (parsedTime != null) {
        formattedTime = DateFormat("HH:mm").format(parsedTime);
      }
    }

    final conversationIdRaw = chatData["conversation_id"];
    final conversationId = conversationIdRaw is int
        ? conversationIdRaw
        : int.tryParse(conversationIdRaw?.toString() ?? '') ?? 0;

    return GestureDetector(
      onTap: () {
        if (conversationId != 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatUserScreen(conversationId: conversationId),
            ),
          );
        } else {
          debugPrint("Invalid conversation_id: $conversationIdRaw");
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 62,
        margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
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
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'BaiJamjuree',
                    ),
                  ),
                  Text(
                    lastMessage,
                    style: TextStyle(
                      fontSize: 12,
                      color: notread >= 1 ? Colors.white : Colors.black,
                      fontFamily: 'BaiJamjuree',
                    ),
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
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'BaiJamjuree',
                  ),
                ),
                if (notread >= 1)
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: Text(
                      "$notread",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontFamily: 'BaiJamjuree',
                      ),
                    ),
                  )
                else
                  Icon(Icons.check, size: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }
}