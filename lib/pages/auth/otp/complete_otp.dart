import 'package:flutter/material.dart';
import 'package:client/core/theme/theme.dart';
import 'package:client/core/components/entryForm/entry_button.dart';
import 'package:go_router/go_router.dart';

class CompleteOtpPage extends StatelessWidget {
  const CompleteOtpPage({super.key});

  // Changed: Navigate to login page instead of home
  void goToLogin(BuildContext context) {
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MainTheme.mainBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Main content in SingleChildScrollView
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 80),
                        
                        // Success image (keeping your original image)
                        Image.asset(
                          'assets/images/complete_verify.png', 
                          height: 150,
                          fit: BoxFit.contain,
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Success title
                        const Text(
                          'สร้างบัญชี สำเร็จ!',
                          style: TextStyle(
                            color: MainTheme.black,
                            fontSize: 20,
                            fontFamily: 'BaiJamjuree',
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Success message
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(
                            'ตอนนี้บัญชีของคุณทำการสมัครเสร็จสิ้นเเล้ว\nสามารถเข้าสู่ระบบเพื่อทำการใช้งาน',
                            style: TextStyle(
                              color: MainTheme.mainText,
                              fontSize: 14,
                              fontFamily: 'BaiJamjuree',
                              fontWeight: FontWeight.w400,
                              letterSpacing: -0.5,
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
            
            Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 36.0),
              child: EntryButton(
                onTap: () => goToLogin(context),
                buttonText: "เสร็จสิ้น", 
              ),
            ),

            const SizedBox(height: 64),
          ],
        ),
      ),
    );
  }
}