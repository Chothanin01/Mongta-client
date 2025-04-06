import 'package:flutter/material.dart';
import 'package:client/core/theme/theme.dart';
import 'package:client/pages/chat/user/chat_search.dart';


class ChatEmptyView extends StatelessWidget {
  const ChatEmptyView({super.key});
  
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
                    _buildRoundedBox(context, 'กฟ'),
                    SizedBox(width: 20),
                    _buildBlueBox(context, 'คุณแก้วตา ฟ้าประทานพร'),
                  ],
                ),
                SizedBox(height: 20),
                _buildWhiteBox(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoundedBox(BuildContext context, String text) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * 0.2,
      padding: EdgeInsets.all(screenWidth * 0.05),
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
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
            color: MainTheme.chatBlue,
            fontFamily: 'BaiJamjuree',
          ),
        ),
      ),
    );
  }

  Widget _buildBlueBox(BuildContext context, String text) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * 0.6,
      padding: EdgeInsets.all(screenWidth * 0.055),
      decoration: BoxDecoration(
        color: MainTheme.chatBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: screenWidth * 0.045,
            color: MainTheme.white,
          ),
        ),
      ),
    );
  }
}

Widget _buildWhiteBox(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;

  return Container(
    width: screenWidth * 0.85,
    height: screenHeight * 0.5,
    decoration: BoxDecoration(
      color: MainTheme.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: MainTheme.black.withOpacity(0.2),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Center(
      child: SingleChildScrollView(  
        child: Column(
          mainAxisSize: MainAxisSize.min, 
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: screenWidth * 0.5,
              height: screenWidth * 0.5,
              child: Image.asset('assets/images/chat.png'),
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              "ยังไม่เคยมีประวัติแชท",
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                color: MainTheme.black,
                fontFamily: 'BaiJamjuree',
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.center, 
              children: [
                Text(
                  "ค้นหาจักษุแพทย์ ",
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: MainTheme.black,
                    fontFamily: 'BaiJamjuree',
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChatSearch()),
                    );
                    // Or using GoRouter:
                    // context.push(Path.chatSearchPage);
                  },
                  child: Text(
                    "กดตรงนี้เลย",
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                      color: MainTheme.chatBlue,
                      fontFamily: 'BaiJamjuree',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}