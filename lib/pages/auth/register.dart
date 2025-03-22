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

// Add these imports
import 'package:client/services/api_service.dart';
import 'package:client/pages/auth/otp/email/verify_email_otp.dart'; // Create this file

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
  bool _showPhoneHelper = true;

  int currentPage = 0;

  // Add these variables
  bool _isLoading = false;
  String? _otpRef;
  String? _errorMessage;

  // Add these to your _RegisterPageState class
  String? _phoneHelperText; // New variable for dynamic helper text
  Color? _phoneHelperColor; // Add a color variable

  @override
  void initState() {
    super.initState();
    
    // Add phone number validation listener
    numberController.addListener(_validatePhoneNumber);
    
    // Set initial helper text
    _phoneHelperText = 'กรุณากรอกในรูปแบบ 06-XXXX-XXXX, 08-XXXX-XXXX หรือ 09-XXXX-XXXX';
  }

  @override
  void dispose() {
    // Remove the listener when disposing
    numberController.removeListener(_validatePhoneNumber);
    super.dispose();
  }

  // Validate Thai phone number format
  void _validatePhoneNumber() {
    final value = numberController.text;
    
    // Skip validation when empty
    if (value.isEmpty) {
      setState(() {
        _phoneHelperText = 'กรุณากรอกในรูปแบบ 06-XXXX-XXXX, 08-XXXX-XXXX หรือ 09-XXXX-XXXX';
        _showPhoneHelper = true;
        _phoneHelperColor = MainTheme.placeholderText; // Default color
      });
      return;
    }
    
    // Clean the phone number for validation
    final cleanNumber = value.replaceAll(RegExp(r'\D'), '');
    
    // Check if the number starts with a valid Thai prefix
    bool hasValidPrefix = cleanNumber.startsWith('06') || 
                          cleanNumber.startsWith('08') || 
                          cleanNumber.startsWith('09');
                         
    // Check if the number has correct length
    bool hasCorrectLength = cleanNumber.length == 10;
    
    setState(() {
      if (!hasValidPrefix && cleanNumber.length >= 2) {
        _phoneHelperText = 'เบอร์โทรศัพท์ต้องขึ้นต้นด้วย 06, 08 หรือ 09';
        _showPhoneHelper = true;
        _phoneHelperColor = MainTheme.redWarning; // Red for error
      } else if (!hasCorrectLength && cleanNumber.length > 0) {
        _phoneHelperText = 'เบอร์โทรศัพท์ต้องมี 10 หลัก (ปัจจุบัน ${cleanNumber.length} หลัก)';
        _showPhoneHelper = true;
        _phoneHelperColor = MainTheme.redWarning; // Red for error
      } else if (hasValidPrefix && hasCorrectLength) {
        _phoneHelperText = 'รูปแบบเบอร์โทรศัพท์ถูกต้อง';
        _showPhoneHelper = true;
        _phoneHelperColor = Colors.green; // Green for success
      } else {
        _phoneHelperText = 'กรุณากรอกในรูปแบบ 06-XXXX-XXXX, 08-XXXX-XXXX หรือ 09-XXXX-XXXX';
        _showPhoneHelper = true;
        _phoneHelperColor = MainTheme.placeholderText; // Default color
      }
    });
  }

  void nextPage(context) {
    _pageController.nextPage(
        duration: Duration(milliseconds: 300), curve: Curves.ease);
  }

  void previousPage(context) {
    _pageController.previousPage(
        duration: Duration(milliseconds: 300), curve: Curves.ease);
  }

  // Update the signUp method in your _RegisterPageState class

void signUp(BuildContext context) async {
  // Add phone validation at the top of the method
  final phoneNumber = numberController.text.replaceAll(RegExp(r'\D'), '');
  bool isValidPhone = false;
  
  if (phoneNumber.length == 10 && 
      (phoneNumber.startsWith('06') || 
       phoneNumber.startsWith('08') || 
       phoneNumber.startsWith('09'))) {
    isValidPhone = true;
  }
  
  if (!isValidPhone) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('เบอร์โทรศัพท์ไม่ถูกต้อง กรุณากรอกเบอร์โทรศัพท์ที่ขึ้นต้นด้วย 06, 08 หรือ 09 และมี 10 หลัก'),
        backgroundColor: MainTheme.redWarning,
      ),
    );
    return;
  }
  
  // Input validation
  if (passwordController.text != passwordConfirmController.text) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('รหัสผ่านไม่ตรงกัน กรุณาตรวจสอบอีกครั้ง'),
        backgroundColor: MainTheme.redWarning,
      ),
    );
    return;
  }

  if (!isChecked) {
    setState(() {
      showWarning = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('กรุณายอมรับเงื่อนไขและข้อตกลงการให้บริการก่อนดำเนินการต่อ'),
        backgroundColor: MainTheme.redWarning,
      ),
    );
    return;
  }

  // Show loading state
  setState(() {
    _isLoading = true;
    showWarning = false;
    _errorMessage = null;
  });

  try {
    // Step 1: Collect user data for registration
    final Map<String, String> userData = {
      'username': usernameController.text,
      'password': passwordController.text,
      'phonenumber': numberController.text,
      'email': emailController.text,
      'first_name': firstNameController.text,
      'last_name': lastNameController.text,
      'sex': genderController.text,
      'dob': dateController.text,
    };
    
    // Step 2: Request OTP
    final otpResponse = await ApiService.requestEmailOTP(emailController.text);
    
    setState(() {
      _isLoading = false;
    });
    
    if (otpResponse['success'] == true) {
      // Navigate to OTP verification using consistent GoRouter navigation
      if (context.mounted) {
        context.push('/verify_otp', extra: {
          'email': emailController.text,
          'ref': otpResponse['Ref'],
          'userData': userData,
        });
      }
    } else {
      setState(() {
        _errorMessage = otpResponse['message'] ?? 'ไม่สามารถส่ง OTP ได้';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage!),
          backgroundColor: MainTheme.redWarning,
        ),
      );
    }
  } catch (e) {
    setState(() {
      _isLoading = false;
      _errorMessage = 'เกิดข้อผิดพลาด: $e';
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('เกิดข้อผิดพลาด: $e'),
        backgroundColor: MainTheme.redWarning,
      ),
    );
  }
}

  void _showVerificationPrompt(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('สมัครสมาชิกสำเร็จ!'),
        content: const Text(
          'คุณต้องการยืนยันอีเมลของคุณเลยหรือไม่?\n'
          'คุณสามารถทำภายหลังได้จากหน้าโปรไฟล์',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/login'); // Navigate to login
            },
            child: const Text('ทำภายหลัง'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to OTP verification with email and reference
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => VerifyOtpPage(
                    params: {
                      'email': emailController.text,
                      'ref': _otpRef!,
                    },
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: MainTheme.blueText,
            ),
            child: const Text('ยืนยันเลย'),
          ),
        ],
      ),
    );
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
                    helperText: _phoneHelperText,
                    showHelper: _showPhoneHelper,
                    helperTextColor: _phoneHelperColor, // Add this line
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

                    ],
                  ),

                  const SizedBox(height: 15), // Spacer

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

                    ],
                  ),

                  const SizedBox(height: 22), // Spacer

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
