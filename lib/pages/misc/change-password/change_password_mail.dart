import 'package:flutter/material.dart';
import 'package:client/core/theme/theme.dart';
import 'package:client/core/components/entryForm/entry_button.dart';
import 'package:go_router/go_router.dart';
import 'package:client/services/api_service.dart';

class ChangePasswordMailPage extends StatefulWidget {
  const ChangePasswordMailPage({super.key});

  @override
  State<ChangePasswordMailPage> createState() => _ChangePasswordMailPageState();
}

class _ChangePasswordMailPageState extends State<ChangePasswordMailPage> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> requestOTP(BuildContext context) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.requestChangePasswordOTP();
      
      if (!mounted) return;
      
      if (response['success'] == true) {
        // Navigate to OTP verification page
        context.push('/change-password-otp', extra: {
          'ref': response['Ref'],
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'ไม่สามารถส่ง OTP ได้';
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
    // Use Navigator.pop instead of context.go to return to the previous screen
    // This works regardless of whether the user came from /settings or /settings-opht
    Navigator.pop(context);
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
                            'เมื่อคุณกดปุ่มด้านล่าง ระบบจะส่งรหัส OTP\nไปยังอีเมลที่ลงทะเบียนไว้กับบัญชีของคุณ\nเพื่อใช้ในการยืนยันการเปลี่ยนรหัสผ่าน',
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
                        
                        // Error message display
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // Button moved outside the scrollview with adjusted padding
            Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 36.0),
              child: EntryButton(
                onTap: _isLoading ? null : () => requestOTP(context),
                buttonText: "ส่งรหัส OTP",
              ),
            ),

            const SizedBox(height: 64),
          ],
        ),
      ),
    );
  }
}