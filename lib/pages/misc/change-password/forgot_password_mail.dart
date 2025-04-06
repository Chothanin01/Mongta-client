import 'package:flutter/material.dart';
import 'package:client/core/theme/theme.dart';
import 'package:client/core/components/entryForm/entry_button.dart';
import 'package:client/core/components/entryForm/entry_textfield.dart';
import 'package:go_router/go_router.dart';
import 'package:iconify_flutter/icons/bxs.dart';
import 'package:client/services/api_service.dart';

class ForgotPasswordMailPage extends StatefulWidget {
  const ForgotPasswordMailPage({super.key});

  @override
  State<ForgotPasswordMailPage> createState() => _ForgotPasswordMailPageState();
}

class _ForgotPasswordMailPageState extends State<ForgotPasswordMailPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> requestOTP(BuildContext context) async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'กรุณากรอกอีเมล';
      });
      return;
    }

    // Email validation
    final bool emailValid = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
    if (!emailValid) {
      setState(() {
        _errorMessage = 'รูปแบบอีเมลไม่ถูกต้อง';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.requestPasswordResetOTP(email);
      
      if (!mounted) return;
      
      if (response['success'] == true) {
        // Navigate to OTP verification page
        context.push('/forgot-password-otp', extra: {
          'email': email, 
          'ref': response['Ref'],
        });
      } else {
        setState(() {
          _errorMessage = response['message'];
        });
      }
    } catch (e) {
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
  void dispose() {
    // Clean up the controller when the widget is disposed
    _emailController.dispose();
    super.dispose();
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
                          'เปลี่ยนรหัสผ่าน',
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
                            'กรุณากรอกอีเมลที่เชื่อมโยงกับบัญชีของคุณ \nแล้วทางเราจะส่ง OTP เพื่อใช้ในการรีเซ็ตรหัสผ่าน',
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

                        // Email input field
                        EntryTextField(
                          controller: _emailController,
                          hintText: "อีเมล",
                          label: "อีเมล",
                          obscureText: false,
                          icon: Bxs.envelope, 
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
                          onTap: _isLoading ? null : () => requestOTP(context),
                          buttonText: "ยืนยันอีเมล",
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