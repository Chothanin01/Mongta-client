import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '/services/user_api_service.dart'; // นำเข้า ApiService

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile Edit',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'BaiJamjuree',
      ),
      home: const ProfileEditPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class UserProfile {
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? profilePicture;

  UserProfile({
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.profilePicture,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    String emailValue = json['email'] is Map<String, dynamic>
        ? json['email']['email'] ?? 'ไม่ระบุ'
        : json['email'] ?? 'ไม่ระบุ';

    return UserProfile(
      username: json['username'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: emailValue,
      profilePicture: json['profile_picture'],
    );
  }
}

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  late TextEditingController _usernameController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  String? _profilePicture;
  File? _newProfilePicture;
  bool _isLoading = true;
  final String _userId = "8"; // เปลี่ยนเป็น String เพื่อให้สอดคล้องกับโค้ดที่สอง
  late Future<Map<String, dynamic>> _userData;
  final ApiService apiService = ApiService(); // สร้าง instance ของ ApiService

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _userData = apiService.getUser(_userId);
    fetchUserData(); // เรียก fetch user data
  }

  Future<void> fetchUserData() async {
    try {
      final userData = await apiService.getUser(_userId);
      final user = UserProfile.fromJson(userData);
      setState(() {
        _usernameController.text = user.username;
        _firstNameController.text = user.firstName;
        _lastNameController.text = user.lastName;
        _emailController.text = user.email;
        _profilePicture = user.profilePicture;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        _usernameController.text = 'ไม่พบข้อมูล';
        _firstNameController.text = '';
        _lastNameController.text = '';
        _emailController.text = 'ไม่ระ eluted';
        _profilePicture = null;
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _newProfilePicture = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {},
        ),
        title: const Text(
          'แก้ไขโปรไฟล์',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            letterSpacing: -0.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color(0xFF1A3E9E), width: 1),
                          ),
                          child: _newProfilePicture != null
                              ? ClipOval(
                                  child: Image.file(
                                    _newProfilePicture!,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : _profilePicture != null
                                  ? ClipOval(
                                      child: Image.network(
                                        _profilePicture!,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                _buildInitials(),
                                      ),
                                    )
                                  : _buildInitials(),
                        ),
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: const Color(0xFF1A3E9E), width: 1),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 18,
                              color: Color(0xFF1A3E9E),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${_firstNameController.text} ${_lastNameController.text}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 24),
                    _buildInputField(
                      label: 'ชื่อบัญชี',
                      controller: _usernameController,
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      label: 'ชื่อจริง',
                      controller: _firstNameController,
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      label: 'นามสกุล',
                      controller: _lastNameController,
                      icon: Icons.badge_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      label: 'อีเมล',
                      controller: _emailController,
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 50),
                    ElevatedButton(
                      onPressed: () {
                        // Add your save profile logic here
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A3E9E),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'ยืนยันการแก้ไข',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInitials() {
    final initials = (_firstNameController.text.isNotEmpty
            ? _firstNameController.text[0]
            : '') +
        (_lastNameController.text.isNotEmpty
            ? _lastNameController.text[0]
            : '');
    return Center(
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 32,
          color: Color(0xFF1A3E9E),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: label,
                border: InputBorder.none,
                labelStyle: TextStyle(
                  color: Colors.black,
                  letterSpacing: -0.5,
                  fontSize: 14,
                ),
              ),
              keyboardType: keyboardType,
            ),
          ),
        ],
      ),
    );
  }
}
