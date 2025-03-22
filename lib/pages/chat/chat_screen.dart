import 'package:flutter/material.dart';
import 'package:client/core/theme/theme.dart';
import 'package:go_router/go_router.dart';



class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});


@override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void _showMedicalPopup() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        backgroundColor: MainTheme.white,
        content: Container(
          width: MediaQuery.of(context).size.width * 0.6,
          height: 87,
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "เลขที่ใบอนุญาติ (ใบ ว.)",
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'BaiJamjuree',
                  color: MainTheme.black,
                ),
              ),
              SizedBox(height: 5),
              Divider(color: MainTheme.chatDivider, thickness: 1),
              SizedBox(height: 5),
              Text(
                "เลขที่ : 1119600063149",
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'BaiJamjuree',
                  color: MainTheme.black,
                ),
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
              toolbarHeight: 85,
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: MainTheme.black),
                onPressed: () {
                  context.go('/chat-history');
                },
              ),
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('assets/images/doctor.png'),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "นพ.คุณากร ส้มดี",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'BaiJamjuree',
                        ),
                      ),
                      Text(
                        "จักษุแพทย์ - โรงพยาบาล IMH",
                        style: TextStyle(
                          fontSize: 12,
                          color: MainTheme.chatGrey,
                          fontFamily: 'BaiJamjuree',
                        ),
                      ),
                      SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 13,
                            height: 13,
                            decoration: BoxDecoration(
                              color: MainTheme.chatGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 5),
                          Text(
                            "ออนไลน์",
                            style: TextStyle(
                              fontSize: 10,
                              color: MainTheme.chatGrey,
                              fontFamily: 'BaiJamjuree',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              GestureDetector(
                onTap: _showMedicalPopup,
                child: Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: CircleAvatar(
                    backgroundColor: MainTheme.chatPink,
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
    body: Column(
      children: [
        SizedBox(height: 10),
        Container(
          width: screenWidth * 0.2,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: MainTheme.chatInfo,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            "วันนี้",
            style: TextStyle(
              fontSize: 14,
              color: MainTheme.black,
              fontFamily: 'BaiJamjuree',
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            children: [
              _chatBubble("สวัสดีค่ะคุณหมอ", "09.41", isMe: true, screenWidth: screenWidth),
              _chatBubble("สวัสดีครับอาการเป็นยังไงบ้าง", "09.41", isMe: false, screenWidth: screenWidth),
              _chatBubble("ตาแดงมา 2 วันค่ะ", "09.41", isMe: true, screenWidth: screenWidth),
              _chatBubble("หมอแนะนำให้ลองนอนพักผ่อนและอย่าขยี้ตานะครับ", "09.41", isMe: false, screenWidth: screenWidth),
              _chatBubble("ต้องไปพบแพทย์ไหมคะ?", "09.42", isMe: true, screenWidth: screenWidth),
              _chatBubble("ถ้าอาการไม่ดีขึ้น แนะนำให้มาตรวจกับหมอครับ", "09.42", isMe: false, screenWidth: screenWidth),
            ],
          ),
        ),
        _chatInput(),
      ],
    ),
  );
}


Widget _chatBubble(String text, String time, {required bool isMe, required double screenWidth}) {
  return Align(
    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
    child: Column(
      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: screenWidth * 0.75),
          margin: EdgeInsets.symmetric(vertical: 5),
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            color: isMe ? MainTheme.chatPink : MainTheme.chatWhite,
            border: isMe ? null : Border.all(color: MainTheme.chatPink),
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
        SizedBox(height: 3),
        Padding(
          padding: EdgeInsets.only(left: isMe ? 0 : 10, right: isMe ? 10 : 0),
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


Widget _chatInput() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    child: Container(
      height: 62,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xFFF0F2F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Color(0xFF12358F),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.image, color: Colors.white),
            ),
          ),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'ข้อความ.....',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Color(0xFF12358F),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    ),
  );
}
}