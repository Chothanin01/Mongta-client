import 'package:client/core/theme/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class ChatCardItem extends StatelessWidget {
  final dynamic chatData;
  const ChatCardItem({required this.chatData, super.key});

  @override
  Widget build(BuildContext context) {
  
  final profile = chatData["profile"] ?? {};
  final userName = "${profile["first_name"] ?? "Unknown"} ${profile["last_name"] ?? ""}";
  final profilePicture = profile["profile_picture"] ?? "";
  
  final rawMessage = (chatData["chat"] == null || chatData["chat"].toString().trim().isEmpty) 
    ? "ยังไม่มีข้อความ" 
    : chatData["chat"];

  final lastMessage = isImageUrl(rawMessage) ? "รูปภาพ" : rawMessage;

  final timestamp = chatData["timestamp"] ?? "";
  String formattedTime = "";
  if (timestamp.isNotEmpty) {
    final parsedTime = DateTime.tryParse(timestamp);
    if (parsedTime != null) {
      formattedTime = DateFormat("HH:mm").format(parsedTime);
    }
  }

  final notreadRaw = chatData["notread"];
  final notread = notreadRaw is int
      ? notreadRaw
      : int.tryParse(notreadRaw?.toString() ?? '') ?? 0;

  final conversationIdRaw = chatData["conversation_id"];
  final conversationId = conversationIdRaw is int
      ? conversationIdRaw
      : int.tryParse(conversationIdRaw?.toString() ?? '') ?? 0;

  return GestureDetector(
    onTap: () {
      if (conversationId != 0) {
        context.push('/chat-user-screen/$conversationId');
      } else {
        debugPrint("Invalid conversation_id: $conversationIdRaw");
      }
    },
    child: Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: 62,
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: notread >= 1 ? MainTheme.chatPink : MainTheme.chatInfo,
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
                    color: notread >= 1 ? MainTheme.chatDivider : MainTheme.black,
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
                  decoration: BoxDecoration(color: MainTheme.chatBlue, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text(
                    "$notread",
                    style: TextStyle(
                      color: MainTheme.white,
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
  
  // Helper method to detect if a message is an image URL
  bool isImageUrl(String message) {
    return message.startsWith('https://') && 
           (message.contains('firebasestorage.googleapis.com') || 
            message.contains('.jpg') || 
            message.contains('.jpeg') || 
            message.contains('.png') || 
            message.contains('.gif'));
  }
}