import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:client/core/theme/theme.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key});

  @override
  State<MessageCard> createState() => MessageCardState();
}

class MessageCardState extends State<MessageCard> {
  List<dynamic> _chatLog = [];
  final int userId = 4; // User Id
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchChatData();
  }

  Future<void> fetchChatData() async {
    final url = Uri.parse('http://localhost:5000/api/chat/186265273/$userId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _chatLog = data['chatlog'];
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load chat');
      }
    } catch (e) {
      print('Error fetching chat data: $e');
    }
  }

  void refreshMessages() {
    fetchChatData();
  }

  String _formatDate(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      final thaiYear = date.year + 543;
      const thaiMonths = [
        'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
        'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'
      ];
      final day = date.day;
      final month = thaiMonths[date.month - 1];
      return 'วันที่ $day $month พ.ศ. $thaiYear';
    }
    catch (e) {
    return 'รูปแบบวันที่ไม่ถูกต้อง';
  }
}

  String _formatTime(String timestamp) {
    final date = DateTime.parse(timestamp);
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    List<dynamic> reversedChatLog = List.from(_chatLog.reversed);

   return ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: reversedChatLog.length,
    itemBuilder: (context, index) {
      final chat = reversedChatLog[index];
      final String text = chat['chat'];
      final String time = _formatTime(chat['timestamp']);
      final String date = _formatDate(chat['timestamp']);
      final int senderId = chat['sender_id'];

      // เช็กว่าข้อความก่อนหน้าเป็นวันไหน ถ้าคนละวันค่อยแสดงวันที่
      final bool showDate = index == 0 || _formatDate(reversedChatLog[index - 1]['timestamp']) != date;

      final Widget messageWidget = senderId == userId
          ? _pinkMessage(text, time, screenWidth)
          : _whiteMessage(text, time, screenWidth);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showDate) _dateMessage(date, screenWidth), // แสดงวันที่เมื่อ showDate เป็น true
          SizedBox(height: 10),
          messageWidget,
        ],
      );
    },
  );
  }
}

  // Date
  Widget _dateMessage(String dateMessage, double screenWidth) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 50),
    child: Container(
      width: screenWidth * 0.1,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: MainTheme.chatInfo,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        dateMessage,
        style: TextStyle(
          fontSize: 14,
          color: MainTheme.black,
          fontFamily: 'BaiJamjuree',
        ),
      ),
    ),
  );
}

  //sender message
  Widget _pinkMessage(String text, String time, double screenWidth) {
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: screenWidth * 0.75),
            margin: EdgeInsets.symmetric(vertical: 5),
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            color: MainTheme.chatPink,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: MainTheme.black,
              fontFamily: 'BaiJamjuree',
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 10),
          child: Text(
            time,
            style: TextStyle(
              fontSize: 14,
              color: MainTheme.chatGrey,
              fontFamily: 'BaiJamjuree',
            ),
          ),
        ),
      ],
    ),
  );
}
  
  // reciever message
  Widget _whiteMessage(String text, String time, double screenWidth) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: screenWidth * 0.75),
          margin: EdgeInsets.symmetric(vertical: 5),
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            color: MainTheme.chatWhite,
            border: Border.all(color: MainTheme.chatPink),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: MainTheme.black,
              fontFamily: 'BaiJamjuree',
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 10),
          child: Text(
            time,
            style: TextStyle(
              fontSize: 14,
              color: MainTheme.chatGrey,
              fontFamily: 'BaiJamjuree',
            ),
          ),
        ),
      ],
    ),
  );
}