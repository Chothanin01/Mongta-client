import 'package:flutter/material.dart';
import 'package:client/components/Color/theme.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MainTheme.mainBackground,
      appBar: AppBar(
        toolbarHeight: 100,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: Padding(
          padding:
              const EdgeInsets.only(left: 16.0, top: 16.0), // ระยะห่างจากขอบจอ
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10), // ปรับขอบให้เหมาะสม
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 4), // ควบคุมพื้นที่รอบตัวอักษร
            child: Center(
              child: Text(
                'กฟ',
                style: TextStyle(
                  color: Color(0xFF12358F),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(
                right: 16.0, top: 8.0), // ระยะห่างจากขอบจอ
            child: Image.asset(
              'assets/images/SE_logo 3.png', // แทน path รูปจริง
              width: 60, // ขนาดโลโก้ยังคงเดิม
              height: 60,
              fit: BoxFit.contain, // รูปภาพไม่ถูกครอบตัด
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
                        color: Colors.black, // ตั้งสีข้อความเป็นสีดำ
                      ),
                  children: [
                    TextSpan(
                      text: 'สวัสดี,\n',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none, // ลบขีดใดๆ
                        backgroundColor: Colors.transparent, // ลบสีพื้นหลัง
                      ),
                    ),
                    TextSpan(
                      text: 'คุณแก้วตา ฟ้าประธานพร',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none, // ลบขีดใดๆ
                        backgroundColor: Colors.transparent, // ลบสีพื้นหลัง
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  // การ์ดสแกนตา
                  Expanded(
                    child: Container(
                      height: 170,
                      decoration: BoxDecoration(
                        color: Color(0xFF12358F),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0), // ระยะห่างภายใน
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start, // ชิดซ้าย
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.remove_red_eye,
                                  color: Color(0xFF12358F), size: 30),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'สแกนตา',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 16),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'อยู่ในสถานะ: ปกติ',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  // การ์ดค่าสายตา
                  Expanded(
                    child: Container(
                      height: 170,
                      decoration: BoxDecoration(
                        color: Color(0xFFF5BBD1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0), // ระยะห่างภายใน
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start, // ชิดซ้าย
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.visibility_off,
                                  color: Color(0xFFF5BBD1), size: 30),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'ค่าสายตา',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 16),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'อยู่ในสถานะ: มีความเสี่ยง',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 14),
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
                  color: Color(0xFF12358F),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0), // ระยะห่างภายใน
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start, // ชิดซ้าย
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'ประวัติการสแกนตา',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 16),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'สแกนไปแล้วทั้งหมด 1 ครั้ง',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.history,
                            color: Color(0xFF12358F), size: 30),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, // จัดให้อยู่หัวและท้าย
                children: [
                  Text(
                    'การแจ้งเตือน',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'ดูทั้งหมด',
                    style: TextStyle(
                        color: Color(0xFF12358F),
                        fontSize: 12,
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