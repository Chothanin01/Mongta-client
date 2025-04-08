import 'package:flutter/material.dart';
import '/services/user_api_service.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ri.dart';
import 'package:client/services/user_service.dart'; 
import 'package:go_router/go_router.dart'; 

class OphtSettingsPage extends StatefulWidget {
  const OphtSettingsPage({super.key});

  @override
  _OphtSettingsPageState createState() => _OphtSettingsPageState();
}

class _OphtSettingsPageState extends State<OphtSettingsPage> {
  Future<Map<String, dynamic>>? _userData;
  bool? isOpthamologist;
  String? sex;
  String userFullName = 'กำลังโหลด...';
  final ApiService apiService = ApiService();
  String? profilePicture;
  bool _isLoading = true; 

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Update the _loadUserData method
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    try {
      // Get the current user ID from secure storage
      final userId = await UserService.getCurrentUserId();
      if (userId.isEmpty) {
        // Handle case where user is not logged in
        if (mounted) {
          context.go('/login'); // Redirect to login page
        }
        return;
      }

      // Immediately initialize the future
      _userData = apiService.getUser(userId);

      // Also fetch for immediate UI updates
      await fetchUserData(userId);
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // End loading regardless of result
        });
      }
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

  // Add logout functionality
  Future<void> _handleLogout() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(child: CircularProgressIndicator());
        },
      );
      
      final success = await UserService.logout(); // Call backend and clear tokens
      
      // Hide loading indicator
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      
      if (mounted) {
        if (success) {
          // Success case
          context.go('/login'); // Navigate to login screen
        } else {
          // Handle error case
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ออกจากระบบแล้ว แต่มีข้อผิดพลาดบางอย่าง')),
          );
          context.go('/login'); // Still navigate to login
        }
      }
    } catch (e) {
      // Hide loading indicator if showing
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      
      print('Error during logout: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาดในการออกจากระบบ')),
        );
        context.go('/login'); // Still navigate to login
      }
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

  String _getSexDisplay(String? sex) {
    if (sex == null) return 'ไม่ระบุ';
    switch (sex.toLowerCase()) {
      case 'male':
        return 'ชาย';
      case 'female':
        return 'หญิง';
      default:
        return 'ไม่ระบุ';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            context.go('/home-opht');
          },
        ),
        title: const Text(
          'การตั้งค่า',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            letterSpacing: -0.5,
            fontWeight: FontWeight.bold,
            fontFamily: 'BaiJamjuree',
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_userData == null
              ? const Center(child: Text('ไม่สามารถโหลดข้อมูลผู้ใช้ได้'))
              : FutureBuilder<Map<String, dynamic>>(
                  future: _userData,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                          child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
                    } else if (snapshot.hasData) {
                      final user = snapshot.data!;
                      final username = user['username'] ?? 'ไม่ระบุ';
                      final email =
                          user['email'] != null && user['email']['email'] != null
                              ? user['email']['email']
                              : 'ไม่ระบุ';

                      return SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'โปรไฟล์ส่วนตัว',
                                    style: TextStyle(
                                      color: Colors.black,
                                      letterSpacing: -0.5,
                                      fontSize: 12,
                                      fontFamily: 'BaiJamjuree',
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      context.push('/edit-profile');
                                    },
                                    child: const Text(
                                      'แก้ไขโปรไฟล์',
                                      style: TextStyle(
                                        color: Color(0xFF12358F),
                                        letterSpacing: -0.5,
                                        fontSize: 12,
                                        fontFamily: 'BaiJamjuree',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF12358F),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 70,
                                          height: 70,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: profilePicture != null &&
                                                    profilePicture!.isNotEmpty
                                                ? Image.network(
                                                    profilePicture!,
                                                    fit: BoxFit.cover,
                                                    width: 70,
                                                    height: 70,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      print(
                                                          'Failed to load profile picture: $error');
                                                      return Center(
                                                        child: Text(
                                                          user['first_name'] !=
                                                                      null &&
                                                                  user['last_name'] !=
                                                                      null
                                                              ? user['first_name']
                                                                      [0] +
                                                                  user['last_name']
                                                                      [0]
                                                              : 'กฟ',
                                                          style:
                                                              const TextStyle(
                                                            color: Color(
                                                                0xFF12358F),
                                                            fontSize: 24,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    loadingBuilder: (context,
                                                        child,
                                                        loadingProgress) {
                                                      if (loadingProgress ==
                                                          null) {
                                                        print(
                                                            'Profile picture loaded successfully: $profilePicture');
                                                        return child;
                                                      }
                                                      print(
                                                          'Loading profile picture: ${loadingProgress.cumulativeBytesLoaded}/${loadingProgress.expectedTotalBytes ?? 'unknown'}');
                                                      return Center(
                                                        child:
                                                            CircularProgressIndicator(),
                                                      );
                                                    },
                                                  )
                                                : Center(
                                                    child: Text(
                                                      user['first_name'] !=
                                                                  null &&
                                                              user['last_name'] !=
                                                                  null
                                                          ? user['first_name']
                                                                  [0] +
                                                              user['last_name']
                                                                  [0]
                                                          : 'กฟ',
                                                      style: const TextStyle(
                                                        color:
                                                            Color(0xFF12358F),
                                                        fontSize: 24,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                userFullName,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'อายุ: ${user['date_of_birth'] != null ? _calculateAge(user['date_of_birth']) : 'ไม่ระบุ'} ปี',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'เพศ: ${_getSexDisplay(sex)}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color: Color(0xFF749DF5),
                                          ),
                                          child: const Iconify(
                                            Ri.user_3_fill,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          username,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const Spacer(),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color: Color(0xFF749DF5),
                                          ),
                                          child: const Icon(
                                            Icons.email,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          email,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const Spacer(),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        // Navigate to change password page
                                        context.push('/change-password-mail');
                                      },
                                      child: Container(
                                        height: 170,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF5BBD1),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 70,
                                              height: 70,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: const Center(
                                                child: Icon(
                                                  Icons.lock,
                                                  color: Colors.black,
                                                  size: 50,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            const Text(
                                              'แก้ไขรหัสผ่าน',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16,
                                                letterSpacing: -0.5,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: 'BaiJamjuree',
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 4),
                                            const Text(
                                              'เริ่มเปลี่ยนกันเลย..',
                                              style: TextStyle(
                                                color: Colors.black,
                                                letterSpacing: -0.5,
                                                fontSize: 12,
                                                fontFamily: 'BaiJamjuree',
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Center(
                                child: Container(
                                  width: 130,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.red, width: 1.5),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: TextButton.icon(
                                    onPressed: _handleLogout,
                                    icon: const Icon(
                                      Icons.logout,
                                      color: Colors.red,
                                      size: 18,
                                    ),
                                    label: const Text(
                                      'ออกจากระบบ',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                        fontFamily: 'BaiJamjuree',
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return const Center(child: Text('ไม่มีข้อมูลผู้ใช้'));
                    }
                  },
                )),
    );
  }

  int _calculateAge(String dob) {
    DateTime birthDate = DateTime.parse(dob);
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}