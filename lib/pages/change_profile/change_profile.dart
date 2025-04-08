import 'dart:io';
import 'package:client/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '/services/user_api_service.dart';
import 'package:client/services/user_service.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/bxs.dart';

class UserProfile {
  final String username;
  final String firstName;
  final String lastName;
  final String? email; 
  final String? phone;
  final String? profilePicture;

  UserProfile({
    required this.username,
    required this.firstName,
    required this.lastName,
    this.email, 
    this.phone,
    this.profilePicture,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    String? emailValue = json['email'] is Map<String, dynamic>
        ? json['email']['email'] 
        : json['email'];

    return UserProfile(
      username: json['username'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: emailValue, // Still parse it if available
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
  String? _profilePicture;
  File? _newProfilePicture;
  bool _isLoading = true;
  bool _isSaving = false;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      // Get current user ID from secure storage
      final userId = await UserService.getCurrentUserId();
      if (userId.isEmpty) {
        // Handle case where user ID is missing
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final userData = await apiService.getUser(userId);
      final user = UserProfile.fromJson(userData);

      setState(() {
        _usernameController.text = user.username;
        _firstNameController.text = user.firstName;
        _lastNameController.text = user.lastName;
        _profilePicture = user.profilePicture;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        _usernameController.text = 'ไม่พบข้อมูล';
        _firstNameController.text = '';
        _lastNameController.text = '';
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

  Future<void> _saveProfile() async {
    // Validate input fields - include username check
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _usernameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'กรุณากรอกข้อมูลให้ครบทุกช่อง',
            style: TextStyle(fontFamily: 'BaiJamjuree'),
          ),
        ),
      );
      return;
    }

    // Profile picture handling remains the same
    File? profileImageFile = _newProfilePicture;
    
    if (profileImageFile == null && _profilePicture != null) {
      try {
        setState(() {
          _isSaving = true;
        });
        
        // Show loading dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'กำลังดาวน์โหลดรูปโปรไฟล์เพื่ออัปเดต...',
                  style: TextStyle(fontFamily: 'BaiJamjuree'),
                )
              ],
            ),
          ),
        );
        
        // Download existing profile image
        final response = await http.get(Uri.parse(_profilePicture!));
        final tempDir = await Directory.systemTemp.createTemp();
        final tempFile = File('${tempDir.path}/existing_profile.jpg');
        await tempFile.writeAsBytes(response.bodyBytes);
        
        // Close loading dialog
        if (mounted) Navigator.of(context, rootNavigator: true).pop();
        
        profileImageFile = tempFile;
        print('Existing profile picture downloaded for reupload');
      } catch (e) {
        // Close loading dialog if showing
        if (mounted) Navigator.of(context, rootNavigator: true).pop();
        
        print('Error downloading existing profile picture: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'กรุณาอัปโหลดรูปโปรไฟล์ใหม่',
              style: TextStyle(fontFamily: 'BaiJamjuree'),
            ),
          ),
        );
        setState(() {
          _isSaving = false;
        });
        return;
      }
    }
    
    // Alert user if no profile picture is available
    if (profileImageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'กรุณาเลือกรูปโปรไฟล์',
            style: TextStyle(fontFamily: 'BaiJamjuree'),
          ),
        ),
      );
      return;
    }

    try {
      setState(() {
        _isSaving = true;
      });

      // Update API call to include username
      final result = await apiService.updateUser(
        _firstNameController.text,
        _lastNameController.text,
        _usernameController.text,  // Add username
        "",                        // Empty string for email
        profileImageFile,
      );

      setState(() {
        _isSaving = false;
      });

      if (result['success'] == true) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'อัปเดตโปรไฟล์สำเร็จ',
              style: TextStyle(fontFamily: 'BaiJamjuree'),
            ),
          ),
        );

        // Return to previous screen
        if (mounted) {
          context.go('/home');
        }
      } else {
        // Show error message with the specific message from backend
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'เกิดข้อผิดพลาดในการอัปเดตโปรไฟล์',
              style: const TextStyle(fontFamily: 'BaiJamjuree'),
            ),
          ),
        );
      }
    } catch (e) {
      print('Error saving profile: $e');
      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'เกิดข้อผิดพลาดในการอัปเดตโปรไฟล์',
            style: TextStyle(fontFamily: 'BaiJamjuree'),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MainTheme.mainBackground,
      appBar: AppBar(
        backgroundColor: MainTheme.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: MainTheme.black),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
        title: const Text(
          'แก้ไขโปรไฟล์',
          style: TextStyle(
            color: MainTheme.black,
            fontSize: 16,
            letterSpacing: -0.5,
            fontWeight: FontWeight.w600,
            fontFamily: 'BaiJamjuree',
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
                                color: MainTheme.profileBlue, width: 1),
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
                              color: MainTheme.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: MainTheme.profileBlue, width: 1),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 18,
                              color: MainTheme.profileBlue,
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
                        fontFamily: 'BaiJamjuree',
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 24),
                    _buildInputField(
                      label: 'ชื่อบัญชี',
                      controller: _usernameController,
                      icon: Bxs.user, // Changed from Icons.person_outline
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      label: 'ชื่อจริง',
                      controller: _firstNameController,
                      icon: Bxs.user_circle, // Changed from Icons.person_outline
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      label: 'นามสกุล',
                      controller: _lastNameController,
                      icon: Bxs.id_card, // Changed from Icons.badge_outlined
                    ),
                    const SizedBox(height: 56),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MainTheme.profileBlue,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: MainTheme.white,
                                strokeWidth: 2.0,
                              ),
                            )
                          : const Text(
                              'ยืนยันการแก้ไข',
                              style: TextStyle(
                                color: MainTheme.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                letterSpacing: -0.5,
                                fontFamily: 'BaiJamjuree',
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
          color: MainTheme.profileBlue,
          fontWeight: FontWeight.w500,
          fontFamily: 'BaiJamjuree',
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required dynamic icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: MainTheme.profileGrey),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          // Updated icon handling
          icon is IconData 
              ? Icon(icon, color: MainTheme.profileIcon, size: 20)
              : Iconify(icon, color: MainTheme.profileIcon, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: label,
                border: InputBorder.none,
                labelStyle: TextStyle(
                  color: MainTheme.black,
                  letterSpacing: -0.5,
                  fontSize: 14,
                  fontFamily: 'BaiJamjuree',
                ),
              ),
              keyboardType: keyboardType,
              style: TextStyle(
                fontFamily: 'BaiJamjuree',
              ),
            ),
          ),
        ],
      ),
    );
  }
}