import 'package:flutter/material.dart';
import 'package:client/core/theme/theme.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import '/services/user_api_service.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import '/services/user_service.dart'; 
import 'package:go_router/go_router.dart'; 

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int chatCount = 0;
  List<Map<String, String>> notifications =
      [];
  int scanCount = 0;
  String? eyeStatus;
  String? vaStatus;
  bool isLoading = true;
  String? userFullName;
  bool? isOpthamologist;
  String? sex;
  final ApiService apiService = ApiService();
  bool showAll = false;
  String? profilePicture;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Get current user ID
      final currentUserId = await UserService.getCurrentUserId();

      await Future.wait([
        fetchUserNotification(),
        fetchUserData(currentUserId),
      ]);

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      // Format date in Thai Buddhist calendar (BE = CE + 543)
      final thaiYear = date.year + 543;
      const thaiMonths = [
        'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
        'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'
      ];
      final day = date.day;
      final month = thaiMonths[date.month - 1];
      final hour = date.hour.toString().padLeft(2, '0'); // ทำให้เป็น 2 หลัก
      final minute = date.minute.toString().padLeft(2, '0'); // ทำให้เป็น 2 หลัก

      return 'วันที่ $day $month พ.ศ. $thaiYear เวลา $hour:$minute น.';
    } catch (e) {
      return dateString;
    }
  }

  Future<void> fetchUserNotification() async {
    try {
      final data = await apiService.getUserNotifications();

      setState(() {
        chatCount = data['chat_count'];
        scanCount = data['scan_count'];

        // Process chat notifications
        List<Map<String, String>> chatNotifications =
            (data['chat_noti'] as List)
                .map((item) => {
                      'type': 'chat',
                      'content': item['User']['first_name'] as String,
                    })
                .toList();

        // Process scan notifications with formatted date
        List<Map<String, String>> scanNotifications = [];
        if (data['scan'] != null) {
          eyeStatus = data['scan']['eye'] as String?;
          vaStatus = data['scan']['va'] as String?;
          
          // Format the date using _formatDate
          final String rawDate = data['scan']['date'] as String;
          final String formattedDate = _formatDate(rawDate);
          
          scanNotifications.add({
            'type': 'scan',
            'content': formattedDate,
            'rawDate': rawDate, // Store original date if needed for sorting
          });
        } else {
          eyeStatus = 'ไม่พบข้อมูล';
          vaStatus = 'ไม่พบข้อมูล';
        }

        // Combine notifications
        notifications = [...chatNotifications, ...scanNotifications];
      });
    } catch (e) {
      print('Error fetching notification: $e');
      setState(() {
        eyeStatus = 'ไม่พบข้อมูล';
        vaStatus = 'ไม่พบข้อมูล';
      });
    }
  }

  Future<void> fetchUserData(String userId) async {
    try {
      final userData = await apiService.getUser(userId);
      setState(() {
        isOpthamologist = userData['is_opthamologist'] as bool?;
        sex = userData['sex'] as String?;
        profilePicture = userData['profile_picture'] as String?;
        userFullName = _getFullNameWithPrefix(
          userData['first_name'] as String,
          userData['last_name'] as String,
          isOpthamologist,
          sex,
        );
      });
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        userFullName = 'ไม่พบข้อมูลผู้ใช้';
        profilePicture = null;
      });
    }
  }

  String _getFullNameWithPrefix(
      String firstName, String lastName, bool? isOphth, String? sex) {
    String prefix = 'คุณ ';

    if (isOphth == true) {
      if (sex?.toLowerCase() == 'male') {
        prefix = 'นพ. ';
      } else if (sex?.toLowerCase() == 'female') {
        prefix = 'พญ. ';
      }
    }

    return '$prefix$firstName $lastName';
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    
    return Scaffold(
      backgroundColor: MainTheme.mainBackground,
      appBar: AppBar(
        toolbarHeight: screenHeight * 0.075, 
        elevation: 0,
        backgroundColor: MainTheme.mainBackground,
        leading: Padding(
          padding: EdgeInsets.only(
            left: screenWidth * 0.04,  
            top: screenHeight * 0.025  
          ),
          child: Container(
            width: screenWidth * 0.1,  
            height: screenWidth * 0.1,  
            decoration: BoxDecoration(
              color: MainTheme.mainBackground,
              borderRadius: BorderRadius.circular(screenWidth * 0.04), 
              border: Border.all(
                color: MainTheme.black,
                width: 0.5, // Kept as is, very small value
              ),
              boxShadow: [
                BoxShadow(
                  color: MainTheme.black.withOpacity(0.2),
                  blurRadius: 1,
                  offset: const Offset(1, 1),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(screenWidth * 0.04), 
              child: profilePicture != null && profilePicture!.isNotEmpty
                  ? Image.network(
                      profilePicture!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.person,
                        size: screenWidth * 0.06, 
                        color: Colors.grey,
                      ),
                    )
                  : Icon(
                      Icons.person,
                      size: screenWidth * 0.06, 
                      color: Colors.grey,
                    ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(
              right: screenWidth * 0.04,  
              top: screenHeight * 0.01    
            ),
            child: Image.asset(
              'assets/images/SE_logo 3.png',
              width: screenWidth * 0.15,  
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
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
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                        fontFamily: 'BaiJamjuree',
                        decoration: TextDecoration.none,
                        backgroundColor: MainTheme.transparent,
                        letterSpacing: -0.5,
                      ),
                    ),
                    TextSpan(
                      text: isLoading
                          ? 'กำลังโหลด...'
                          : (userFullName ?? 'นพ.คุณากร เจริญธรรมกิจ'),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'BaiJamjuree',
                        decoration: TextDecoration.none,
                        backgroundColor: MainTheme.transparent,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 46),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 170,
                      decoration: BoxDecoration(
                        color: MainTheme.blueBox,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 16.0,
                          top: 27.0,
                          right: 16.0,
                          bottom: 16.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: MainTheme.white,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Iconify(
                                      Mdi.eye_check,
                                      color: Colors.black,
                                      size: 43,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'สแกนตา',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'BaiJamjuree',
                                  color: MainTheme.white,
                                  letterSpacing: -0.5,
                                  fontSize: 12),
                            ),
                            SizedBox(height: 3),
                            Text(
                              isLoading
                                  ? 'กำลังโหลด...'
                                  : 'อยู่ในเกณฑ์ : ${eyeStatus ?? 'ปกติ'}',
                              style: TextStyle(
                                  color: MainTheme.white,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'BaiJamjuree',
                                  letterSpacing: -0.5,
                                  fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      height: 170,
                      decoration: BoxDecoration(
                        color: MainTheme.pinkBox,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 16.0,
                          top: 27.0,
                          right: 16.0,
                          bottom: 16.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: MainTheme.white,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Iconify(
                                      Mdi.comment_eye,
                                      color: Colors.black,
                                      size: 43,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'ค่าสายตา',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'BaiJamjuree',
                                  color: MainTheme.black,
                                  letterSpacing: -0.5,
                                  fontSize: 12),
                            ),
                            SizedBox(height: 3),
                            Text(
                              isLoading
                                  ? 'กำลังโหลด...'
                                  : 'อยู่ในเกณฑ์ : ${vaStatus ?? 'ปกติ'}',
                              style: TextStyle(
                                  color: MainTheme.black,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'BaiJamjuree',
                                  letterSpacing: -0.5,
                                  fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  // Navigate to scan log page
                  context.go('/scanlog');
                },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: MainTheme.blueBox,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ประวัติการสแกนตา',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'BaiJamjuree',
                                  fontSize: 16,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                isLoading
                                    ? 'กำลังโหลด...'
                                    : 'สแกนไปแล้วทั้งหมด $scanCount ครั้ง',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'BaiJamjuree',
                                  fontSize: 14,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16),
                        Container(
                          child: Center(
                            child: Image.asset(
                              'assets/images/Result2.png',
                              width: 60,
                              height: 60,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'การแจ้งเตือน',
                    style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'BaiJamjuree',
                        letterSpacing: -0.5,
                        fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        showAll = true;
                      });
                    },
                    child: Text(
                      'ดูทั้งหมด',
                      style: TextStyle(
                          color: MainTheme.blueText,
                          fontSize: 12,
                          fontFamily: 'BaiJamjuree',
                          letterSpacing: -0.5,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : notifications.isEmpty
                      ? Center(
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/images/Result.png',
                                width: 120,
                                height: 120,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'ยังไม่มีการเเจ้งเตือน',
                                style: TextStyle(
                                    fontFamily: 'BaiJamjuree',
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    letterSpacing: -0.5),
                              ),
                            ],
                          ),
                        )
                      : SizedBox(
                          height: showAll ? 6 * 80.0 : 3 * 80.0,
                          child: SingleChildScrollView(
                            child: Column(
                              children: notifications
                                  .take(showAll ? 6 : 3)
                                  .map((notification) {
                                final type = notification['type'];
                                final content = notification['content'] ?? '';
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 11.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      // Navigate based on notification type
                                      if (type == 'chat') {
                                        context.go('/chat-history');
                                      } else if (type == 'scan') {
                                        context.go('/scanlog');
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: MainTheme.white,
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.25),
                                            blurRadius: 2,
                                            offset: const Offset(0, 0),
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0, vertical: 10.0),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                color: type == 'chat'
                                                    ? Color(0xFFFFC0CB)
                                                    : MainTheme.blueBox,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Center(
                                                child: Iconify(
                                                  type == 'chat'
                                                      ? MaterialSymbols.chat
                                                      : MaterialSymbols.docs,
                                                  color: MainTheme.white,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    type == 'chat'
                                                        ? 'แชท'
                                                        : 'ประวัติการสแกน',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                      fontFamily: 'BaiJamjuree',
                                                      fontSize: 14,
                                                      letterSpacing: -0.5,
                                                    ),
                                                  ),
                                                  Text(
                                                    type == 'chat'
                                                        ? '$content ส่งข้อความเข้ามา'
                                                        : content,
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontFamily: 'BaiJamjuree',
                                                      fontSize: 10,
                                                      letterSpacing: -0.5,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }
}