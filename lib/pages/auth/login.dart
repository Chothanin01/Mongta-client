import 'package:flutter/material.dart';
import 'package:client/core/theme/theme.dart';
import 'package:flutter/gestures.dart';
import 'package:client/core/components/entryForm/circle_logo.dart';
import 'package:client/core/components/entryForm/entry_button.dart';
import 'package:client/core/components/entryForm/entry_textfield.dart';
import 'package:iconify_flutter/icons/bxs.dart';
import 'package:go_router/go_router.dart';
import 'package:client/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
      final result = await _authService.login(username, password);
      
      if (!context.mounted) return;
      
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("เข้าสู่ระบบสำเร็จ!")),
        );
        context.go('/home'); // Navigate on success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("เกิดข้อผิดพลาดในการเชื่อมต่อ")),
      );
    }
  }

  Future<void> socialSignIn(BuildContext context, String provider) async {
    try {
      final result = provider == 'google'
          ? await _authService.signInWithGoogle()
          : await _authService.signInWithFacebook();
      if (!context.mounted) return;

      if (result != null) {
        if (!result['isRegister']) {
          // Navigate to registration page if the user is not registered
          context.push('/ggfb_register', extra: {
            'userData': result['userData'],
            'idToken': result['idToken'],
            'provider': provider,
          });
        } else {
          // User is registered, navigate to home page
          context.go('/home');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Google/Facebook เข้าสู่ระบบล้มเหลว')));
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
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'ลืมรหัสผ่าน?',
                          style: TextStyle(
                            color: MainTheme.mainText,
                            fontSize: 16,
                            fontFamily: 'BaiJamjuree',
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.5,
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

                  // Sign-in buttons for Google & Facebook
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
