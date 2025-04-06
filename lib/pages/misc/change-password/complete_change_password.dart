import 'package:flutter/material.dart';
import 'package:client/core/theme/theme.dart';
import 'package:client/core/components/entryForm/entry_button.dart';
import 'package:go_router/go_router.dart';

class CompleteChangePasswordPage extends StatelessWidget {
  const CompleteChangePasswordPage({super.key});

  void goToSettings(BuildContext context) {
    context.go('/settings');
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
                          'เปลี่ยนรหัสผ่าน สำเร็จ!',  // Changed the title to match the action
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
                            'ตอนนี้บัญชีของคุณทำการเปลี่ยนรหัสผ่านเสร็จสิ้นเเล้ว\nสามารถกลับไปยังการตั้งค่าได้ทันที',
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
                onTap: () => goToSettings(context),
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