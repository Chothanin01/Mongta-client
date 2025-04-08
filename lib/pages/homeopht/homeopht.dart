import 'package:flutter/material.dart';
import 'package:client/core/theme/theme.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import '/services/user_api_service.dart';
import '/services/user_service.dart'; 
import 'package:go_router/go_router.dart'; 


class OphtHomePage extends StatefulWidget {
  const OphtHomePage({super.key});

  @override
  _OphtHomePageState createState() => _OphtHomePageState();
}

class _OphtHomePageState extends State<OphtHomePage> {
  int chatCount = 0;
  List<String> chatNoti = [];
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
        fetchOphthNotification(),
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

  Future<void> fetchOphthNotification() async {
    try {
      final data = await apiService.getOphtNotifications();

      setState(() {
        chatCount = data['chat_count'];
        chatNoti = (data['chat_noti'] as List)
            .map((item) => item['User']['first_name'] as String)
            .toList();
      });
    } catch (e) {
      print('Error fetching notification: $e');
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
    String prefix = 'คุณ';

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
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: MainTheme.black,
                width: 0.5,
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
              borderRadius: BorderRadius.circular(16),
              child: profilePicture != null && profilePicture!.isNotEmpty
                  ? Image.network(
                      profilePicture!,
                      fit: BoxFit.cover,
                      width: 40,
                      height: 40,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Text(
                            'กฟ', // fallback ถ้ารูปโหลดไม่ได้
                            style: TextStyle(
                              color: MainTheme.blueText,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        'กฟ', // default ถ้าไม่มี profile picture
                        style: TextStyle(
                          color: MainTheme.blueText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 8.0),
            child: Image.asset(
              'assets/images/SE_logo 3.png',
              width: 60,
              height: 60,
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
                    child: GestureDetector(
                      onTap: () {
                        // Navigate to the ophthalmologist settings page
                        context.go('/settings-opht');
                      },
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
                                      color: MainTheme.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Iconify(
                                        MaterialSymbols.settings,
                                        color: MainTheme.black,
                                        size: 43,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'การตั้งค่า',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'BaiJamjuree',
                                    color: MainTheme.white,
                                    letterSpacing: -0.5,
                                    fontSize: 12),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'แก้ไขโปรไฟล์ รหัสผ่าน',
                                style: TextStyle(
                                    color: MainTheme.white,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'BaiJamjuree',
                                    letterSpacing: -0.5,
                                    fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        context.go('/chat-ophth-history');
                      },
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
                                      color: MainTheme.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Iconify(
                                        MaterialSymbols.chat,
                                        color: MainTheme.black,
                                        size: 43,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'แชท',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'BaiJamjuree',
                                    color: MainTheme.black,
                                    letterSpacing: -0.5,
                                    fontSize: 12),
                              ),
                              SizedBox(height: 4),
                              isLoading
                                  ? Text(
                                      'กำลังโหลด...',
                                      style: TextStyle(
                                          color: MainTheme.black,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'BaiJamjuree',
                                          letterSpacing: -0.5,
                                          fontSize: 14),
                                    )
                                  : Text(
                                      'ทั้งหมด: $chatCount คน',
                                      style: TextStyle(
                                          color: MainTheme.black,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'BaiJamjuree',
                                          letterSpacing: -0.5,
                                          fontSize: 14),
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
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
                        showAll = true; // เปลี่ยนสถานะเมื่อกด "ดูทั้งหมด"
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
                  : chatNoti.isEmpty
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
                                    color: MainTheme.logGrey2,
                                    letterSpacing: -0.5),
                              ),
                            ],
                          ),
                        )
                      : SizedBox(
                          height: showAll
                              ? 6 * 80.0
                              : 3 * 80.0, // กำหนดความสูงตามจำนวนรายการ (ประมาณการต่อ item)
                          child: SingleChildScrollView(
                            child: Column(
                              children: chatNoti
                                  .take(showAll ? 6 : 3) // เปลี่ยนจำนวนตามสถานะ
                                  .map((firstName) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 11.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: MainTheme.white,
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: MainTheme.black.withOpacity(0.25),
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
                                              color: Color(0xFFFFC0CB),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Center(
                                              child: Iconify(
                                                MaterialSymbols.chat,
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
                                                  'แชท',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontFamily: 'BaiJamjuree',
                                                    fontSize: 14,
                                                    letterSpacing: -0.5,
                                                  ),
                                                ),
                                                Text(
                                                  '$firstName ส่งข้อความเข้ามา',
                                                  style: TextStyle(
                                                    color: MainTheme.logGrey2,
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
