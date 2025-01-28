import 'package:flutter/material.dart';
import 'package:client/components/Color/theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MainTheme.mainBackground,
    
      appBar: AppBar(
        toolbarHeight: 60,
        elevation: 0,
        backgroundColor: MainTheme.mainBackground,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 20.0),
          child: Container(
            decoration: BoxDecoration(
              color: MainTheme.mainBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                // Border color
                color: MainTheme.black,
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  // Shadow color
                  color: MainTheme.black.withOpacity(0.2),
                  blurRadius: 1,
                  offset: const Offset(1, 1),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'กฟ',
                style: TextStyle(
                  color: MainTheme.blueText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(
                // Padding from the screen edge
                right: 16.0, top: 8.0), 
            child: Image.asset(
              'assets/images/SE_logo 3.png', // Replace with the actual path of the image
              width: 60, // Logo width
              height: 60, // Logo height
              fit: BoxFit.contain, // Ensure the image is not cropped
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style.copyWith(
                        color: MainTheme.black, 
                      ),
                  children: [
                    TextSpan(
                      text: 'สวัสดี,\n',
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'BaiJamjuree',
                        // Remove underline
                        decoration: TextDecoration.none, 
                        backgroundColor:
                            // Remove background color
                            MainTheme.transparent, 
                      ),
                    ),
                    TextSpan(
                      text: 'คุณแก้วตา ฟ้าประธานพร',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'BaiJamjuree',
                        // Remove underline
                        decoration: TextDecoration.none,
                        backgroundColor:
                            // Remove background color
                            MainTheme.transparent, 
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16),

              Row(
                children: [
                  // Eye Scan Card
                  Expanded(
                    child: Container(
                      height: 170,
                      decoration: BoxDecoration(
                        color: MainTheme.blueBox,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0), // Inner padding
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start, // Align left
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: MainTheme.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.remove_red_eye,
                                  color: MainTheme.blueBox, size: 30),
                            ),

                            SizedBox(height: 16),

                            Text(
                              'สแกนตา',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'BaiJamjuree',
                                  color: MainTheme.white,
                                  fontSize: 16),
                            ),
                            
                            SizedBox(height: 4),

                            Text(
                              'อยู่ในสถานะ: ปกติ',
                              style: TextStyle(
                                  color: MainTheme.white,
                                  fontFamily: 'BaiJamjuree',
                                  fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 16),

                  // Vision Status Card
                  Expanded(
                    child: Container(
                      height: 170,
                      decoration: BoxDecoration(
                        color: MainTheme.pinkBox,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0), // Inner padding
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start, // Align left
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: MainTheme.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.visibility_off,
                                  color: MainTheme.pinkBox, size: 30),
                            ),

                            SizedBox(height: 16),

                            Text(
                              'ค่าสายตา',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'BaiJamjuree',
                                  color: MainTheme.black,
                                  fontSize: 16),
                            ),

                            SizedBox(height: 4),

                            Text(
                              'อยู่ในสถานะ: มีความเสี่ยง',
                              style: TextStyle(
                                  color: MainTheme.black,
                                  fontFamily: 'BaiJamjuree',
                                  fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: MainTheme.blueBox,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0), // Inner padding
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start, // Align left
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'ประวัติการสแกนตา',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'BaiJamjuree',
                                  color: MainTheme.white,
                                  fontSize: 16),
                            ),

                            SizedBox(height: 4),

                            Text(
                              'สแกนไปแล้วทั้งหมด 1 ครั้ง',
                              style: TextStyle(
                                  color: MainTheme.white,
                                  fontFamily: 'BaiJamjuree',
                                  fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: MainTheme.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.history,
                            color: MainTheme.blueBox, size: 30),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, // Align to start and end
                children: [
                  Text(
                    'การแจ้งเตือน',
                    style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'BaiJamjuree',
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'ดูทั้งหมด',
                    style: TextStyle(
                        color: MainTheme.blueText,
                        fontSize: 12,
                        fontFamily: 'BaiJamjuree',
                        fontWeight: FontWeight.bold),
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
