import 'package:flutter/material.dart';
import 'package:client/core/theme/theme.dart';
import 'package:go_router/go_router.dart';



class ChatHistory extends StatelessWidget {
  const ChatHistory({super.key});
  
@override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: MainTheme.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildRoundedBox('กฟ'),
                  SizedBox(width: 20),
                  _buildBlueBox('คุณแก้วตา ฟ้าประทานพร'),
                ],
              ),
              SizedBox(height: 20),
              _buildSearchRow(),
              SizedBox(height: 20),
              _buildDoctorCard(
                context: context,
                name: 'นพ.คุณากร ส้มดี',
                message: 'หมอแนะนำให้ลองนอน...',
                time: '09.41',
                unreadCount: 1,
                isRead: false,
              ),
              SizedBox(height: 10),
              _buildDoctorCard(
                context: context,
                name: 'นพ.คุณากร ส้มดี',
                message: 'หมอแนะนำให้ลองนอน...',
                time: '09.41',
                unreadCount: 0,
                isRead: true,
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildRoundedBox(String text) {
    return Container(
      width: 78,
      height: 78,
      decoration: BoxDecoration(
        color: MainTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: MainTheme.chatGrey,
          width: 1,
        )
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: MainTheme.chatBlue,
            fontFamily: 'BaiJamjuree',
          ),
        ),
      ),
    );
  }

  Widget _buildBlueBox(String text) {
    return Container(
      width: 230,
      height: 78,
      decoration: BoxDecoration(
        color: MainTheme.chatBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: MainTheme.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          'ค้นหาจักษุแพทย์ ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: MainTheme.black,
            fontFamily: 'BaiJamjuree'),
        ),
        GestureDetector(
          onTap: () {
            print("ค้นหาจักษุแพทย์");
          },
          child: Text(
            'กดตรงนี้เลย',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'BaiJamjuree',
              color: MainTheme.chatBlue),
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorCard({
  required BuildContext context,
  required String name,
  required String message,
  required String time,
  required int unreadCount,
  required bool isRead,
}) {
  return GestureDetector(
    onTap: () {
      context.go('/chat');
    },
    child: Container(
      width: 314,
      height: 62,
      decoration: BoxDecoration(
        color: isRead ? MainTheme.chatInfo : MainTheme.nearchartSoftPink,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 23,
                backgroundImage: AssetImage('assets/images/doctor.png'),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: isRead ? MainTheme.chatDivider : MainTheme.chatGreen,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'BaiJamjuree',
                    color: MainTheme.black,
                  ),
                ),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'BaiJamjuree',
                    color: isRead ? MainTheme.chatDivider : MainTheme.black,
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
                time,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'BaiJamjuree',
                  color: MainTheme.black,
                ),
              ),
              if (unreadCount > 0)
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: MainTheme.chatBlue,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$unreadCount',
                    style: TextStyle(
                      fontSize: 14,
                      color: MainTheme.white,
                      fontFamily: 'BaiJamjuree',
                    ),
                  ),
                ),
              if (isRead)
                Icon(
                  Icons.check,
                  size: 14,
                  color: MainTheme.black,
                ),
            ],
          ),
        ],
      ),
    ),
  );
}
}