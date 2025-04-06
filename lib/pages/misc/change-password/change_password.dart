import 'package:flutter/material.dart';
import 'package:client/core/theme/theme.dart';
import 'package:client/core/components/entryForm/entry_button.dart';
import 'package:client/core/components/entryForm/entry_textfield.dart';
import 'package:go_router/go_router.dart';
import 'package:iconify_flutter/icons/bxs.dart';
import 'package:client/services/api_service.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> changePassword(BuildContext context) async {
    // Get password values
    final oldPassword = _oldPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    
    // Validation
    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = 'กรุณากรอกรหัสผ่านให้ครบถ้วน';
      });
      return;
    }
    
    if (newPassword.length < 6) {
      setState(() {
        _errorMessage = 'รหัสผ่านใหม่ต้องมีอย่างน้อย 6 ตัวอักษร';
      });
      return;
    }
    
    if (newPassword != confirmPassword) {
      setState(() {
        _errorMessage = 'รหัสผ่านใหม่ไม่ตรงกัน กรุณาตรวจสอบอีกครั้ง';
      });
      return;
    }
    
    if (oldPassword == newPassword) {
      setState(() {
        _errorMessage = 'รหัสผ่านใหม่ต้องไม่ซ้ำกับรหัสผ่านเดิม';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.changePassword(oldPassword, newPassword);
      
      if (!mounted) return;
      
      if (response['success'] == true) {
        // Navigate to success page
        context.go('/complete-change-password');
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'ไม่สามารถเปลี่ยนรหัสผ่านได้';
        });
      }
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _errorMessage = 'เกิดข้อผิดพลาด: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void goBack(BuildContext context) {
    context.pop(); // Go back to previous page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MainTheme.mainBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Back button row at the top
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 8.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: MainTheme.mainText,
                    size: 22,
                  ),
                  onPressed: () => goBack(context),
                ),
              ),
            ),
            
            // Main content in SingleChildScrollView
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        
                        // Title text
                        const Text(
                          'รหัสผ่านใหม่',
                          style: TextStyle(
                            color: MainTheme.mainText,
                            fontSize: 24,
                            fontFamily: 'BaiJamjuree',
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Description text
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(
                            'รหัสผ่านใหม่ของคุณต้องไม่เหมือน \nกับรหัสผ่านเก่าของคุณ',
                            style: TextStyle(
                              color: MainTheme.mainText,
                              fontSize: 18,
                              fontFamily: 'BaiJamjuree',
                              fontWeight: FontWeight.w400,
                              letterSpacing: -0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        
                        const SizedBox(height: 50),

                        // Old password input field
                        EntryTextField(
                          controller: _oldPasswordController,
                          hintText: "รหัสผ่านเก่า",
                          label: "รหัสผ่านเก่า",
                          obscureText: true,
                          icon: Bxs.lock, 
                        ),

                        const SizedBox(height: 15),
                        
                        // New password input field
                        EntryTextField(
                          controller: _newPasswordController,
                          hintText: "รหัสผ่านใหม่",
                          label: "รหัสผ่านใหม่",
                          obscureText: true,
                          icon: Bxs.lock, 
                        ),

                        const SizedBox(height: 15),

                        // Confirm password input field
                        EntryTextField(
                          controller: _confirmPasswordController,
                          hintText: "ยืนยันรหัสผ่าน",
                          label: "ยืนยันรหัสผ่าน",
                          obscureText: true,
                          icon: Bxs.lock, 
                        ),
                        
                        const SizedBox(height: 15),

                        // Error message display
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: MainTheme.redWarning,
                                fontSize: 14,
                                fontFamily: 'BaiJamjuree',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        
                        const SizedBox(height: 80),
                        
                        // Next button
                        EntryButton(
                          onTap: _isLoading ? null : () => changePassword(context),
                          buttonText: "เปลี่ยนรหัสผ่าน",
                        ),
                        
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}