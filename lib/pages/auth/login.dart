import 'package:flutter/material.dart';
import 'package:client/core/theme/theme.dart';
import 'package:flutter/gestures.dart';
import 'package:client/core/components/entryForm/circle_logo.dart';
import 'package:client/core/components/entryForm/entry_button.dart';
import 'package:client/core/components/entryForm/entry_textfield.dart';
import 'package:iconify_flutter/icons/bxs.dart';
import 'package:go_router/go_router.dart';
import 'package:client/services/auth_service.dart';
import 'package:client/services/user_service.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  String? warningMessage;

  /// Method to handle user login logic
  void signUserIn(
      BuildContext context,
      TextEditingController usernameController,
      TextEditingController passwordController) async {
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("โปรดกรอกชื่อบัญชีและรหัสผ่าน")),
      );
      return;
    }

    try {
      print('Attempting login with username: $username');
      
      final result = await _authService.login(username, password);
      
      print('Login response: ${result.toString()}');
      
      if (!context.mounted) return;
      
      if (result['success'] == true) {
        print('Login successful, extracting user data...');
        print('Full response: $result');
        
        // Check if user object exists and has an ID
        final user = result['user'] ?? {};
        final userId = user['id']?.toString() ?? ''; // Convert ID to string
        
        print('Extracted user ID: $userId');
        
        // Save user data properly
        await UserService.saveUserId(userId);
        await UserService.saveToken(result['token'] ?? '');
        
        // Navigate based on role
        await _authService.navigateAfterLogin(context, userId);
      } else {
        print('Login failed with message: ${result['message']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
      }
    } catch (e) {
      print('Login error details: ${e.toString()}');
      
      // Show Thai error messages based on error type
      String errorMessage = "เกิดข้อผิดพลาดในการเข้าสู่ระบบ โปรดลองอีกครั้ง";
      
      if (e is http.ClientException) {
        errorMessage = "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้ โปรดตรวจสอบการเชื่อมต่ออินเทอร์เน็ต";
      } else if (e.toString().contains('SocketException')) {
        errorMessage = "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้ โปรดตรวจสอบการเชื่อมต่ออินเทอร์เน็ต";
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = "การเชื่อมต่อใช้เวลานานเกินไป โปรดลองใหม่อีกครั้ง";
      } else if (e.toString().contains('FormatException')) {
        errorMessage = "เกิดข้อผิดพลาดในการประมวลผลข้อมูล โปรดติดต่อผู้ดูแลระบบ";
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  Future<void> socialSignIn(BuildContext context, String provider) async {
    try {
      print('Starting $provider sign-in process');
      
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(
              color: MainTheme.blueText,
            ),
          );
        },
      );
      
      print('Calling _authService.signInWithGoogle()');
      final result = await _authService.signInWithGoogle();
      print('Google sign-in result: ${result?.toString() ?? "null"}');
      
      // Hide loading indicator
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      
      if (!context.mounted || result == null) {
        print('Context not mounted or result is null');
        return;
      }

      if (result['isRegister'] == true) {
        // User exists, token already saved in authService
        print('User exists, navigating to appropriate home page');
        final userId = result['user']['id'].toString();
        await UserService.saveUserId(userId);
        
        // Use the role-based navigation method
        await _authService.navigateAfterLogin(context, userId);
      } else {
        // User is not registered, navigate to registration page
        print('User not registered, navigating to registration page');
        context.push('/ggfb_register', extra: {
          'userData': result['userData'],
          'idToken': result['idToken'],
          'provider': 'google', // Only Google is supported now
        });
      }
    } catch (e) {
      print('Google sign-in error: ${e.toString()}');
      
      if (context.mounted) {
        // Hide loading indicator if still showing
        Navigator.of(context, rootNavigator: true).pop();
        
        // Show appropriate Thai error message
        String errorMessage = "เข้าสู่ระบบด้วย Google ไม่สำเร็จ โปรดลองอีกครั้ง";
        
        if (e.toString().contains('network_error')) {
          errorMessage = "ไม่สามารถเชื่อมต่อกับ Google ได้ โปรดตรวจสอบการเชื่อมต่ออินเทอร์เน็ต";
        } else if (e.toString().contains('popup_closed')) {
          errorMessage = "หน้าต่างเข้าสู่ระบบถูกปิดก่อนเสร็จสิ้น โปรดลองใหม่อีกครั้ง";
        } else if (e.toString().contains('popup_blocked')) {
          errorMessage = "หน้าต่าง Google Sign In ถูกบล็อค โปรดอนุญาตป๊อปอัปจากแอปนี้";
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }
  }

  void goToRegister() {
    context.go('/register');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MainTheme.mainBackground, // background color
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 120), // Spacer

                  // Username input field
                  EntryTextField(
                    controller: usernameController,
                    label: 'ชื่อบัญชี',
                    hintText: 'ชื่อบัญชี',
                    obscureText: false,
                    icon: Bxs.user,
                  ),

                  const SizedBox(height: 20), // Spacer

                  // Password input field
                  EntryTextField(
                    controller: passwordController,
                    label: 'รหัสผ่าน',
                    hintText: 'รหัสผ่าน',
                    obscureText: true,
                    icon: Bxs.lock,
                  ),

                  const SizedBox(height: 19), // Spacer

                  // Link for "ลืมรหัสผ่าน?"
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () => context.push('/forgot-password-mail'),
                          child: const Text(
                            'ลืมรหัสผ่าน?',
                            style: TextStyle(
                              color: MainTheme.mainText,
                              fontSize: 16,
                              fontFamily: 'BaiJamjuree',
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 37), // Spacer

                  // Sign-in button
                  EntryButton(
                    onTap: () => signUserIn(context, usernameController, passwordController),
                    buttonText: "เข้าสู่ระบบ",
                  ),

                  const SizedBox(height: 13), // Spacer

                  // Divider for "หรือ เข้าสู่ระบบผ่าน"
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Divider(
                            thickness: 0.5,
                            color: Colors.transparent,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(
                            'หรือ เข้าสู่ระบบผ่าน',
                            style: TextStyle(
                              color: MainTheme.mainText,
                              fontSize: 12,
                              fontFamily: 'BaiJamjuree',
                              fontWeight: FontWeight.w400,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            thickness: 0.5,
                            color: Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 17), // Spacer

                  // Sign-in buttons for Google
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => socialSignIn(context, 'google'),
                        child: const SquareTile(
                            imagePath: 'assets/icon/Google.png'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 150), // Spacer

                  // div "หากยังไม่มีบัญชี" และ "สมัครสมาชิก" to merge in
                  RichText(
                    text: TextSpan(
                      text: 'หากยังไม่มีบัญชี, ',
                      style: const TextStyle(
                        color: MainTheme.mainText,
                        fontSize: 16,
                        fontFamily: 'BaiJamjuree',
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.5,
                      ),
                      children: [
                        TextSpan(
                          text: 'สมัครสมาชิก',
                          style: const TextStyle(
                            color: MainTheme.hyperlinkedText,
                            fontSize: 16,
                            fontFamily: 'BaiJamjuree',
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.5,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = goToRegister,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
