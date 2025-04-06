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
import 'package:client/services/user_service.dart';

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

  bool _showPhoneHelper = true;
  String? _phoneHelperText;
  Color? _phoneHelperColor;
  
  @override
  void initState() {
    super.initState();
    
    // Pre-fill first and last name from userData
    firstNameController.text = widget.userData['first_name'] ?? '';
    lastNameController.text = widget.userData['last_name'] ?? '';
    
    // Pre-fill with defaults if empty
    if (firstNameController.text.isEmpty && widget.userData['name'] != null) {
      final names = widget.userData['name'].split(' ');
      if (names.isNotEmpty) firstNameController.text = names[0];
      if (names.length > 1) lastNameController.text = names.skip(1).join(' ');
    }
    
    numberController.addListener(_validatePhoneNumber);
    
    // Set initial helper text
    _phoneHelperText = 'กรุณากรอกในรูปแบบ 06-XXXX-XXXX, 08-XXXX-XXXX หรือ 09-XXXX-XXXX';
    
    print('Initialized form with:');
    print('First name: ${firstNameController.text}');
    print('Last name: ${lastNameController.text}');
  }

  @override
  void dispose() {
    // Remove the listener when disposing
    numberController.removeListener(_validatePhoneNumber);
    super.dispose();
  }

  // Validate Thai phone number format - copied from register.dart
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

  Future<void> signUserIn(BuildContext context) async {
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

    if (_formKey.currentState!.validate()) {
      setState(() {
        showWarning = false;
      });

      try {
        // Show loading indicator
        final loadingOverlay = _showLoadingOverlay(context);
        
        // Parse date from controller text (YYYY-MM-DD) to DateTime
        DateTime? birthDate;
        if (dateController.text.isNotEmpty) {
          try {
            birthDate = DateTime.parse(dateController.text);
            print('Parsed birth date: $birthDate');
          } catch (e) {
            print('Error parsing date: $e');
          }
        }

        // Use the form input values
        final result = await _authService.completeGoogleRegistration(
          {
            'first_name': firstNameController.text.trim(),
            'last_name': firstNameController.text.trim(),
            'email': widget.userData['email'],
            'picture': widget.userData['picture'],
          },
          widget.idToken,
          numberController.text.trim(),
          genderController.text, // Use gender from controller directly
          birthDate, // Use parsed date
        );
        
        print('Registration response: ${result.toString()}');
        
        // Rest of the method stays the same...
        loadingOverlay.remove();
        
        if (!mounted) return;
        
        if (result['success'] == true) {
          // Registration successful - save JWT token
          final user = result['user'];
          if (user != null) {
            await UserService.saveUserId(user['id']?.toString() ?? '');
            // Note: token is not returned from backend on registration,
            // you may need to login separately or handle this differently
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ลงทะเบียนสำเร็จ!'),
              backgroundColor: MainTheme.blueText,
            ),
          );
          
          // Navigate to success page
          context.go('/complete-otp');
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'การลงทะเบียนล้มเหลว กรุณาลองใหม่อีกครั้ง'),
              backgroundColor: MainTheme.redWarning,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('เกิดข้อผิดพลาดในการลงทะเบียน: ${e.toString()}'),
              backgroundColor: MainTheme.redWarning,
            ),
          );
        }
      }
    }
  }

  OverlayEntry _showLoadingOverlay(BuildContext context) {
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: 0,
        right: 0,
        top: 0,
        bottom: 0,
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: Center(
            child: CircularProgressIndicator(
              color: MainTheme.blueText,
            ),
          ),
        ),
      ),
    );
    
    Overlay.of(context).insert(overlayEntry);
    return overlayEntry;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MainTheme.mainBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: MainTheme.mainText),
          onPressed: () {
            // Cancel Google registration and go back to login
            context.go('/login');
          },
        ),
        centerTitle: true,
      ),
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
                    const SizedBox(height: 16),

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
                      helperText: _phoneHelperText,
                      showHelper: _showPhoneHelper,
                      helperTextColor: _phoneHelperColor,
                    ),

                    const SizedBox(height: 15),

                    EntryGenderPicker(
                      controller: genderController,
                      label: 'เลือกเพศ',
                    ),

                    const SizedBox(height: 37),

                    // Terms and Conditions
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Transform.translate(
                            offset: const Offset(0, -2),
                            child: Checkbox(
                              value: isChecked,
                              onChanged: (bool? newValue) {
                                setState(() {
                                  isChecked = newValue ?? false;
                                  if (isChecked) showWarning = false;
                                });
                              },
                              activeColor: MainTheme.mainText,
                            ),
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

                    const SizedBox(height: 20),

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