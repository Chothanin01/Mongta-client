import 'package:flutter/material.dart';
import 'package:client/core/theme/theme.dart';
import 'package:flutter/gestures.dart';
import 'package:client/core/components/entryForm/circle_logo.dart';
import 'package:client/core/components/entryForm/entry_button.dart';
import 'package:client/core/components/entryForm/entry_textfield.dart';
import 'package:client/core/components/entryForm/entry_datepicker.dart';
import 'package:client/core/components/entryForm/entry_genderpicker.dart';
import 'package:iconify_flutter/icons/bxs.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// for auth api
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final PageController _pageController = PageController();

  // Controllers for handling user input
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmController = TextEditingController();
  final numberController = TextEditingController();
  final emailController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final dateController = TextEditingController();
  final genderController = TextEditingController();

  bool isChecked = false;
  bool showWarning = false;

  int currentPage = 0;

  void nextPage(context) {
    _pageController.nextPage(
        duration: Duration(milliseconds: 300), curve: Curves.ease);
  }

  void previousPage(context) {
    _pageController.previousPage(
        duration: Duration(milliseconds: 300), curve: Curves.ease);
  }

  void signUp(BuildContext context) async {

    // Check if passwords match
  if (passwordController.text != passwordConfirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'รหัสผ่านไม่ตรงกัน กรุณาตรวจสอบอีกครั้ง',
            style: TextStyle(
              fontFamily: 'BaiJamjuree',
              fontSize: 14,
            ),
          ),
          backgroundColor: MainTheme.redWarning,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    if (!isChecked) {
      setState(() {
        showWarning = true;
      });

      // Show snackbar with warning
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'กรุณายอมรับเงื่อนไขและข้อตกลงการให้บริการก่อนดำเนินการต่อ',
            style: TextStyle(
              fontFamily: 'BaiJamjuree',
              fontSize: 14,
            ),
          ),
          backgroundColor: MainTheme.redWarning,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
  
  if (!isChecked) {
    setState(() {
      showWarning = true;
    });

    // Show snackbar with warning
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'กรุณายอมรับเงื่อนไขและข้อตกลงการให้บริการก่อนดำเนินการต่อ',
          style: TextStyle(
            fontFamily: 'BaiJamjuree',
            fontSize: 14,
          ),
        ),
        backgroundColor: MainTheme.redWarning,
        duration: Duration(seconds: 3),
      ),
    );
    return;
  }

  setState(() {
    showWarning = false;
  });

  // API URL
  const String apiUrl = "http://10.0.2.2:5000/api/register";

  // Request body
  Map<String, dynamic> requestBody = {
    "username": usernameController.text,
    "password": passwordController.text,
    "confirm_password": passwordConfirmController.text,
    "phonenumber": numberController.text,
    "email": emailController.text,
    "first_name": firstNameController.text,
    "last_name": lastNameController.text,
    "dob": dateController.text,
    "sex": genderController.text
  };

  try {
    var response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 201) {
      // Success: Navigate to home page
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("สมัครสมาชิกสำเร็จ!"),
          backgroundColor: MainTheme.greenComplete,
        ),
      );
      context.go('/home');
    } else {
      // Error: Show error message
      Map<String, dynamic> responseData = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(responseData["message"] ?? "สมัครสมาชิกไม่สำเร็จ"),
          backgroundColor: MainTheme.redWarning,
        ),
      );
    }
  } catch (error) {
    // Handle network errors
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("เกิดข้อผิดพลาด กรุณาลองอีกครั้ง"),
        backgroundColor: MainTheme.redWarning,
      ),
    );
  }
}

  void backToLogin(BuildContext context) {
    // Placeholder for sign-in logic
    // TODO: Add authentication implementation
    context.go('/login'); // Navigate to HomePage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MainTheme.mainBackground, // Change as needed
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
        children: [
          // First page
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: 2,
                    effect: CustomizableEffect(
                      activeDotDecoration: DotDecoration(
                        width: 90,
                        height: 10,
                        color: MainTheme.activeDot,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      dotDecoration: DotDecoration(
                        width: 30,
                        height: 10,
                        color: MainTheme.inactiveDot,
                        borderRadius: BorderRadius.circular(24),
                        verticalOffset: 0,
                      ),
                      spacing: 6.0,
                    ),
                  ),

                  const SizedBox(height: 15), // Spacer

                  EntryTextField(
                    controller: usernameController,
                    label: 'ชื่อบัญชี',
                    hintText: 'ชื่อบัญชี',
                    obscureText: false,
                    icon: Bxs.user,
                  ),

                  const SizedBox(height: 15), // Spacer

                  // Password input field
                  EntryTextField(
                    controller: passwordController,
                    label: 'รหัสผ่าน',
                    hintText: 'รหัสผ่าน',
                    obscureText: true,
                    icon: Bxs.lock,
                  ),

                  const SizedBox(height: 15), // Spacer

                  // Password input field
                  EntryTextField(
                    controller: passwordConfirmController,
                    label: 'ยืนยันรหัสผ่าน',
                    hintText: 'ยืนยันรหัสผ่าน',
                    obscureText: true,
                    icon: Bxs.lock,
                  ),

                  const SizedBox(height: 15), // Spacer

                  // Password input field
                  EntryTextField(
                    controller: numberController,
                    label: 'เบอร์โทรศัพท์',
                    hintText: 'เบอร์โทรศัพท์',
                    obscureText: false,
                    icon: Bxs.phone,
                  ),

                  const SizedBox(height: 15), // Spacer

                  // Password input field
                  EntryTextField(
                    controller: emailController,
                    label: 'อีเมล',
                    hintText: 'อีเมล',
                    obscureText: false,
                    icon: Bxs.envelope,
                  ),

                  const SizedBox(height: 37), // Spacer

                  EntryButton(
                    onTap: () => nextPage(context),
                    buttonText: "ต่อไป",
                  ),

                  const SizedBox(height: 13),

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
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Google sign-in button
                      SquareTile(imagePath: 'assets/icon/Google.png'),

                      SizedBox(width: 18), // Spacer

                      // Facebook sign-in button
                      SquareTile(imagePath: 'assets/icon/Facebook.png'),
                    ],
                  ),

                  const SizedBox(height: 30), // Spacer

                  // แยก "หากยังไม่มีบัญชี" และ "สมัครสมาชิก" เพื่อมารวมกัน
                  RichText(
                    text: TextSpan(
                      text: 'หากมีบัญชี, ',
                      style: const TextStyle(
                        color: MainTheme.mainText,
                        fontSize: 16,
                        fontFamily: 'BaiJamjuree',
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.5,
                      ),
                      children: [
                        TextSpan(
                          text: 'เข้าสู่ระบบ',
                          style: const TextStyle(
                            color: MainTheme.hyperlinkedText,
                            fontSize: 16,
                            fontFamily: 'BaiJamjuree',
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.5,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              backToLogin(
                                  context); // Calls the method to navigate to login
                            },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
            // Second page
            SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      // Back button on the left
                      Positioned(
                        left:
                            16.0, // Adjust this value to control left padding of back arrow
                        child: IconButton(
                          color: MainTheme.black,
                          icon: Icon(Icons.arrow_back_ios_new),
                          iconSize: 10,
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          onPressed: () {
                            previousPage(context);
                          },
                        ),
                      ),
                      // Centered indicator
                      Align(
                        alignment: Alignment.center,
                        child: SmoothPageIndicator(
                          controller: _pageController,
                          count: 2,
                          effect: CustomizableEffect(
                            activeDotDecoration: DotDecoration(
                              width: 90,
                              height: 10,
                              color: MainTheme.activeDot,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            dotDecoration: DotDecoration(
                              width: 30,
                              height: 10,
                              color: MainTheme.inactiveDot,
                              borderRadius: BorderRadius.circular(24),
                              verticalOffset: 0,
                            ),
                            spacing: 6.0,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20), // Spacer

                  EntryTextField(
                    controller: firstNameController,
                    label: 'ชื่อจริง',
                    hintText: 'ชื่อจริง',
                    obscureText: false,
                    icon: Bxs.user_circle,
                  ),

                  const SizedBox(height: 15), // Spacer

                  // Password input field
                  EntryTextField(
                    controller: lastNameController,
                    label: 'นามสกุล',
                    hintText: 'นามสกุล',
                    obscureText: false,
                    icon: Bxs.id_card,
                  ),

                  const SizedBox(height: 15), // Spacer

                  // Password input field
                  EntryDatePicker(
                    controller: dateController,
                    label: 'วันเดือนปีเกิด',
                    hintText: 'วันเดือนปีเกิด',
                    icon: Bxs.cake,
                  ),

                  const SizedBox(height: 15), // Spacer

                  // Password input field
                  EntryGenderPicker(
                    controller: genderController,
                    label: 'เลือกเพศ',
                  ),

                  const SizedBox(height: 37), // Spacer

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Divider(
                            thickness: 0.5,
                            color: MainTheme.transparent,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: isChecked,
                                    onChanged: (bool? newValue) {
                                      setState(() {
                                        isChecked = newValue ?? false;
                                        if (isChecked) {
                                          showWarning = false;
                                        }
                                      });
                                    },
                                    activeColor: MainTheme.mainText,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isChecked = !isChecked;
                                        if (isChecked) {
                                          showWarning = false;
                                        }
                                      });
                                    },
                                    child: Text(
                                      'เงื่อนไขเเละข้อตกลงการให้บริการ Term of Service',
                                      style: TextStyle(
                                        color: MainTheme.mainText,
                                        fontSize: 12,
                                        fontFamily: 'BaiJamjuree',
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (showWarning)
                                Padding(
                                  padding: const EdgeInsets.only(left: 35.0),
                                  child: Text(
                                    'กรุณายอมรับเงื่อนไขและข้อตกลง',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                      fontFamily: 'BaiJamjuree',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            thickness: 0.5,
                            color: MainTheme.transparent,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 13),

                  // Modified signup button with opacity
                  Opacity(
                    opacity: isChecked ? 1.0 : 0.5,
                    child: EntryButton(
                      onTap: () => signUp(context),
                      buttonText: "สมัครสมาชิก",
                    ),
                  ),

                  const SizedBox(height: 13),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Divider(
                            thickness: 0.5,
                            color: MainTheme.transparent,
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
                            color: MainTheme.transparent,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 17), // Spacer

                  // Sign-in buttons for Google & Facebook
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Google sign-in button
                      SquareTile(imagePath: 'assets/icon/Google.png'),

                      SizedBox(width: 18), // Spacer

                      // Facebook sign-in button
                      SquareTile(imagePath: 'assets/icon/Facebook.png'),
                    ],
                  ),

                  const SizedBox(height: 30), // Spacer

                  // แยก "หากยังไม่มีบัญชี" และ "สมัครสมาชิก" เพื่อมารวมกัน
                  RichText(
                    text: TextSpan(
                      text: 'หากมีบัญชี, ',
                      style: const TextStyle(
                        color: MainTheme.mainText,
                        fontSize: 16,
                        fontFamily: 'BaiJamjuree',
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.5,
                      ),
                      children: [
                        TextSpan(
                          text: 'เข้าสู่ระบบ',
                          style: const TextStyle(
                            color: MainTheme.hyperlinkedText,
                            fontSize: 16,
                            fontFamily: 'BaiJamjuree',
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.5,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              backToLogin(
                                  context); // Calls the method to navigate to login
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
