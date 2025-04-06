import 'package:flutter/material.dart';
import 'package:client/core/theme/theme.dart';
import 'package:client/core/components/entryForm/entry_button.dart';
import 'package:client/core/components/entryForm/entry_textfield.dart';
import 'package:go_router/go_router.dart';
import 'package:iconify_flutter/icons/bxs.dart';
import 'package:client/services/api_service.dart';


class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String _email = ''; 

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // This is the right place to access context-dependent values
    try {
      // Get the route parameters from GoRouter
      final Map<String, dynamic>? params = GoRouterState.of(context).extra as Map<String, dynamic>?;
      
      // Only update if the email is different to avoid unnecessary setState calls
      final String newEmail = params?['email'] ?? '';
      if (newEmail != _email) {
        setState(() {
          _email = newEmail;
        });
        
        // Log for debugging
        debugPrint('Email from route parameters: $_email');
      }
    } catch (e) {
      debugPrint('Error accessing route parameters: $e');
    }
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> resetPassword(BuildContext context) async {
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    
    // Validation
    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = 'กรุณากรอกรหัสผ่านให้ครบถ้วน';
      });
      return;
    }
    
    if (newPassword.length < 6) {
      setState(() {
        _errorMessage = 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
      });
      return;
    }
    
    if (newPassword != confirmPassword) {
      setState(() {
        _errorMessage = 'รหัสผ่านไม่ตรงกัน กรุณาตรวจสอบอีกครั้ง';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Log the data being sent for debugging
      debugPrint('Resetting password for email: $_email with new password (length: ${newPassword.length})');
      
      final response = await ApiService.resetPassword(_email, newPassword);
      
      // Log the response for debugging
      debugPrint('Password reset response: $response');
      
      if (!mounted) return;
      
      if (response['success'] == true) {
        // Password reset successful
        context.go('/complete-forgot-password');
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'ไม่สามารถเปลี่ยนรหัสผ่านได้';
        });
      }
    } catch (e) {
      debugPrint('Password reset error: $e');
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
    context.pop();
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
                            'เปลี่ยนรหัสผ่านใหม่ของคุณ \nเพื่อเข้าสู่ระบบได้ตามปกติ',
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
                        
                        const SizedBox(height: 8),
                        
                        // Error message display
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
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
                          onTap: _isLoading ? null : () => resetPassword(context),
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