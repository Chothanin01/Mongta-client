import 'package:flutter/material.dart';
import 'package:client/core/theme/theme.dart';
import 'package:flutter/gestures.dart';
import 'package:client/core/components/entryForm/entry_button.dart';
import 'package:client/core/components/entryForm/entry_textfield.dart';
import 'package:client/core/components/entryForm/entry_datepicker.dart';
import 'package:client/core/components/entryForm/entry_genderpicker.dart';
import 'package:iconify_flutter/icons/bxs.dart';
import 'package:go_router/go_router.dart';
import 'package:client/services/auth_service.dart';

class GoogleFacebookRegisterPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String idToken;
  final String provider;

  const GoogleFacebookRegisterPage({
    super.key,
    required this.userData,
    required this.idToken,
    required this.provider,
  });

  @override
  State<GoogleFacebookRegisterPage> createState() => _GoogleFacebookRegisterPageState();
}

class _GoogleFacebookRegisterPageState extends State<GoogleFacebookRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  
  final numberController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final dateController = TextEditingController();
  final genderController = TextEditingController();

  DateTime? selectedDate;
  String? selectedGender;
  bool isChecked = false;
  bool showWarning = false;
  
  @override
  void initState() {
    super.initState();
    // Pre-fill name fields if available from social login
    if (widget.userData['name'] != null) {
      final names = widget.userData['name'].split(' ');
      if (names.isNotEmpty) firstNameController.text = names[0];
      if (names.length > 1) lastNameController.text = names[1];
    }
  }

  Future<void> signUserIn(BuildContext context) async {
    if (!isChecked) {
      setState(() {
        showWarning = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'กรุณายอมรับเงื่อนไขและข้อตกลงการให้บริการก่อนดำเนินการต่อ',
            style: TextStyle(
              fontFamily: 'BaiJamjuree',
              fontSize: 14,
            ),
          ),
          backgroundColor: MainTheme.redWarning,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() {
        showWarning = false;
      });

      try {
        final registrationData = {
          'id_token': widget.idToken,
          'phonenumber': numberController.text,
          'first_name': firstNameController.text,
          'last_name': lastNameController.text,
          'sex': selectedGender,
          'dob': selectedDate?.toIso8601String(),
        };

        final result = await _authService.completeRegistration(registrationData);
        if (result != null && mounted) {
          context.go('/home');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'เกิดข้อผิดพลาดในการลงทะเบียน กรุณาลองใหม่อีกครั้ง',
                style: TextStyle(
                  fontFamily: 'BaiJamjuree',
                  fontSize: 14,
                ),
              ),
              backgroundColor: MainTheme.redWarning,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MainTheme.mainBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 80),

                    EntryTextField(
                      controller: firstNameController,
                      label: 'ชื่อจริง',
                      hintText: 'ชื่อจริง',
                      obscureText: false,
                      icon: Bxs.user_circle,
                    ),

                    const SizedBox(height: 15),

                    EntryTextField(
                      controller: lastNameController,
                      label: 'นามสกุล',
                      hintText: 'นามสกุล',
                      obscureText: false,
                      icon: Bxs.id_card,
                    ),

                    const SizedBox(height: 15),

                    EntryDatePicker(
                      controller: dateController,
                      label: 'วันเดือนปีเกิด',
                      hintText: 'วันเดือนปีเกิด',
                      icon: Bxs.cake,
                    ),

                    const SizedBox(height: 15),

                    EntryTextField(
                      controller: numberController,
                      label: 'เบอร์โทรศัพท์',
                      hintText: 'เบอร์โทรศัพท์',
                      obscureText: false,
                      icon: Bxs.phone,
                    ),

                    const SizedBox(height: 15),

                    EntryGenderPicker(
                      controller: genderController,
                      label: 'เลือกเพศ',
                    ),

                    const SizedBox(height: 37),

                    // Terms and Conditions
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Row(
                        children: [
                          Checkbox(
                            value: isChecked,
                            onChanged: (bool? newValue) {
                              setState(() {
                                isChecked = newValue ?? false;
                                if (isChecked) showWarning = false;
                              });
                            },
                            activeColor: MainTheme.mainText,
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isChecked = !isChecked;
                                  if (isChecked) showWarning = false;
                                });
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'เงื่อนไขเเละข้อตกลงการให้บริการ Term of Service',
                                    style: TextStyle(
                                      color: MainTheme.mainText,
                                      fontSize: 12,
                                      fontFamily: 'BaiJamjuree',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (showWarning)
                                    Text(
                                      'กรุณายอมรับเงื่อนไขและข้อตกลง',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                        fontFamily: 'BaiJamjuree',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 19),

                    Opacity(
                      opacity: isChecked ? 1.0 : 0.5,
                      child: EntryButton(
                        onTap: () => signUserIn(context),
                        buttonText: "สมัครสมาชิก",
                      ),
                    ),

                    const SizedBox(height: 50),

                    RichText(
                      text: TextSpan(
                        text: 'หากมีบัญชี, ',
                        style: TextStyle(
                          color: MainTheme.mainText,
                          fontSize: 16,
                          fontFamily: 'BaiJamjuree',
                          fontWeight: FontWeight.w400,
                        ),
                        children: [
                          TextSpan(
                            text: 'เข้าสู่ระบบ',
                            style: TextStyle(
                              color: MainTheme.hyperlinkedText,
                              fontSize: 16,
                              fontFamily: 'BaiJamjuree',
                              fontWeight: FontWeight.w600,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => context.go('/login'),
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
      ),
    );
  }
}