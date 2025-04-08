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
import 'package:client/services/api_service.dart';
import 'package:client/pages/auth/otp/email/verify_email_otp.dart'; 

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

  bool _isLoading = false;
  String? _otpRef;
  String? _errorMessage;

  String? _phoneHelperText; // New variable for dynamic helper text
  Color? _phoneHelperColor; // Add a color variable

  @override
  void initState() {
    super.initState();
    
    numberController.addListener(_validatePhoneNumber);
    
    _phoneHelperText = 'กรุณากรอกในรูปแบบ 06-XXXX-XXXX, 08-XXXX-XXXX หรือ 09-XXXX-XXXX';
    
    _pageController.addListener(() {
      setState(() {
        currentPage = _pageController.page?.round() ?? 0;
      });
    });
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
        _phoneHelperColor = MainTheme.greenComplete; // Green for success
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

  void signUp(BuildContext context) async {
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
          backgroundColor: MainTheme.redWarning,
          content: Text("เบอร์โทรศัพท์ไม่ถูกต้อง โปรดกรอกเบอร์โทรศัพท์ที่ขึ้นต้นด้วย 06, 08 หรือ 09 และมี 10 หลัก"),
        ),
      );
      return;
    }
    
    // Input validation
    if (passwordController.text != passwordConfirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: MainTheme.redWarning,
          content: Text("รหัสผ่านไม่ตรงกัน โปรดตรวจสอบอีกครั้ง"),
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
          backgroundColor: MainTheme.redWarning,
          content: Text("โปรดยอมรับเงื่อนไขและข้อตกลงการใช้งานก่อนดำเนินการต่อ"),
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
          _errorMessage = otpResponse['message'] ?? 'ไม่สามารถส่ง OTP ได้ โปรดลองใหม่อีกครั้ง';
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: MainTheme.redWarning,
            content: Text(_errorMessage ?? 'เกิดข้อผิดพลาดในการส่ง OTP โปรดลองใหม่อีกครั้ง'),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'เกิดข้อผิดพลาด: $e';
      });
      
      String errorMsg = 'เกิดข้อผิดพลาดในการลงทะเบียน โปรดลองใหม่อีกครั้ง';
      
      if (e.toString().contains('email already exists')) {
        errorMsg = 'อีเมลนี้ถูกใช้งานแล้ว โปรดใช้อีเมลอื่น';
      } else if (e.toString().contains('username already exists')) {
        errorMsg = 'ชื่อผู้ใช้นี้ถูกใช้งานแล้ว โปรดใช้ชื่อผู้ใช้อื่น';
      } else if (e.toString().contains('connection')) {
        errorMsg = 'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้ โปรดตรวจสอบการเชื่อมต่ออินเทอร์เน็ต';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: MainTheme.redWarning,
          content: Text(errorMsg),
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
    context.go('/login'); // Navigate to HomePage
  }

  // Function to show Terms of Service popup with checkbox
  void _showTermsOfService(BuildContext context, Function(bool) onAgreed) {
    bool isAgreed = false; // Track checkbox state
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder( // Use StatefulBuilder to update checkbox state within dialog
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Text(
                            'เงื่อนไขการใช้บริการ',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'BaiJamjuree',
                            ),
                          ),
                          Spacer(),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          _termsOfServiceText,
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'BaiJamjuree',
                          ),
                        ),
                      ),
                    ),
                    // Add checkbox for agreement
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Checkbox(
                            value: isAgreed,
                            onChanged: (value) {
                              setState(() {
                                isAgreed = value!;
                              });
                            },
                            activeColor: MainTheme.buttonBackground,
                          ),
                          Expanded(
                            child: Text(
                              'ฉันได้อ่านและยอมรับเงื่อนไขการใช้บริการ',
                              style: TextStyle(
                                fontFamily: 'BaiJamjuree',
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MainTheme.buttonBackground,
                            foregroundColor: MainTheme.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            onAgreed(isAgreed);
                            Navigator.pop(context);
                          },
                          child: Text(
                            'ตกลง', // Changed from "ปิด" to "ตกลง"
                            style: TextStyle(
                              fontFamily: 'BaiJamjuree',
                              fontWeight: FontWeight.bold,
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
        );
      },
    );
  }

  // Mock Terms of Service text for MongTa eye scanning app
  final String _termsOfServiceText = '''
เงื่อนไขการใช้บริการแอปพลิเคชัน MongTa (มองตา)

1. บทนำ
   แอปพลิเคชัน MongTa ("แอปพลิเคชัน") เป็นแพลตฟอร์มที่ให้บริการสแกนและวิเคราะห์ดวงตาเบื้องต้น ดำเนินการโดย [ชื่อบริษัท] ("เรา", "ของเรา") เงื่อนไขการใช้บริการนี้กำหนดกฎและข้อบังคับสำหรับการใช้แอปพลิเคชัน MongTa

2. การยอมรับเงื่อนไข
   โดยการเข้าถึงหรือใช้แอปพลิเคชัน MongTa คุณยืนยันว่าคุณเข้าใจ ยอมรับ และตกลงที่จะปฏิบัติตามเงื่อนไขการใช้บริการทั้งหมดที่ระบุไว้ในเอกสารนี้ หากคุณไม่ยอมรับเงื่อนไขเหล่านี้ คุณไม่ควรใช้แอปพลิเคชันของเรา

3. ข้อจำกัดอายุ
   แอปพลิเคชัน MongTa มีไว้สำหรับผู้ใช้ที่มีอายุ 18 ปีขึ้นไป หากคุณมีอายุต่ำกว่า 18 ปี คุณจำเป็นต้องได้รับความยินยอมจากผู้ปกครองหรือผู้ดูแลตามกฎหมายก่อนใช้แอปพลิเคชัน

4. คำเตือนทางการแพทย์
   4.1 แอปพลิเคชัน MongTa ไม่ได้มีวัตถุประสงค์เพื่อทดแทนการปรึกษาหรือการรักษาทางการแพทย์โดยผู้เชี่ยวชาญ
   4.2 ผลการสแกนและการวิเคราะห์ที่ให้โดยแอปพลิเคชันเป็นเพียงข้อมูลเบื้องต้นเท่านั้น ไม่ถือเป็นการวินิจฉัยทางการแพทย์อย่างเป็นทางการ
   4.3 หากคุณมีอาการทางสายตาหรือดวงตา โปรดปรึกษาจักษุแพทย์หรือผู้เชี่ยวชาญทางการแพทย์โดยเร็วที่สุด

5. การเก็บรวบรวมข้อมูลและความเป็นส่วนตัว
   5.1 เราเก็บรวบรวมข้อมูลส่วนบุคคลและข้อมูลทางการแพทย์ตามที่ระบุไว้ในนโยบายความเป็นส่วนตัวของเรา
   5.2 ข้อมูลที่เก็บรวบรวมจะถูกใช้เพื่อการให้บริการ การวิเคราะห์ และการปรับปรุงแอปพลิเคชัน
   5.3 เราใช้มาตรการรักษาความปลอดภัยที่เหมาะสมเพื่อปกป้องข้อมูลของคุณ แต่ไม่สามารถรับประกันความปลอดภัยอย่างสมบูรณ์ได้

6. ความรับผิดชอบของผู้ใช้
   6.1 คุณต้องให้ข้อมูลที่ถูกต้องและเป็นปัจจุบันเมื่อใช้แอปพลิเคชัน
   6.2 คุณต้องไม่ใช้แอปพลิเคชันในทางที่ผิดกฎหมายหรือสร้างความเสียหาย
   6.3 คุณไม่สามารถพยายามเข้าถึงส่วนใดของแอปพลิเคชันที่ไม่ได้รับอนุญาต
   6.4 คุณไม่ควรแชร์บัญชีหรือรหัสผ่านกับผู้อื่น

7. การเชื่อมต่อกับจักษุแพทย์
   7.1 แอปพลิเคชัน MongTa อาจเสนอการเชื่อมต่อกับจักษุแพทย์ผ่านระบบแชท
   7.2 การให้คำแนะนำของจักษุแพทย์ผ่านแอปพลิเคชันไม่ถือเป็นการรักษาที่สมบูรณ์ และอาจต้องมีการนัดพบแพทย์ในสถานพยาบาลตามความเหมาะสม

8. ข้อจำกัดความรับผิด
   8.1 แอปพลิเคชัน MongTa จัดเตรียมให้ตาม "สภาพที่เป็นอยู่" และ "ตามที่มีให้บริการ" โดยไม่มีการรับประกันใด ๆ
   8.2 เราจะไม่รับผิดต่อความเสียหายทางตรง ทางอ้อม อุบัติเหตุ หรือเป็นผลสืบเนื่องที่เกิดจากการใช้แอปพลิเคชัน
   8.3 การตัดสินใจทางการแพทย์ใด ๆ ที่คุณทำตามข้อมูลจากแอปพลิเคชันเป็นความรับผิดชอบของคุณเองทั้งสิ้น

9. ทรัพย์สินทางปัญญา
   แอปพลิเคชัน MongTa รวมถึงเนื้อหา กราฟิก โลโก้ และซอฟต์แวร์ทั้งหมดเป็นทรัพย์สินของเราและได้รับการคุ้มครองโดยกฎหมายทรัพย์สินทางปัญญา

10. การยกเลิกการใช้บริการ
    เราขอสงวนสิทธิ์ในการระงับหรือยกเลิกการเข้าถึงแอปพลิเคชันของคุณได้ทุกเมื่อ โดยมีหรือไม่มีการแจ้งให้ทราบล่วงหน้า หากคุณละเมิดเงื่อนไขการใช้บริการ

11. การเปลี่ยนแปลงเงื่อนไข
    เราอาจปรับปรุงเงื่อนไขการใช้บริการเป็นครั้งคราว การเปลี่ยนแปลงจะมีผลทันทีเมื่อประกาศบนแอปพลิเคชัน การใช้แอปพลิเคชันอย่างต่อเนื่องหลังจากการเปลี่ยนแปลงถือเป็นการยอมรับเงื่อนไขใหม่

12. กฎหมายที่ใช้บังคับ
    เงื่อนไขการใช้บริการนี้อยู่ภายใต้และตีความตามกฎหมายของประเทศไทย

วันที่ปรับปรุงล่าสุด: 8 เมษายน 2025
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MainTheme.mainBackground,
      appBar: currentPage == 1
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: MainTheme.mainText),
                onPressed: () {
                  previousPage(context);
                },
              ),
              title: SmoothPageIndicator(
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
              centerTitle: true,
            )
          : null,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
          children: [
            // First page
            SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Only show page indicator on first page (since second page has it in AppBar)
                    if (currentPage == 0)
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
                      helperTextColor: _phoneHelperColor,
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

                    // Sign-in buttons for Google
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                                  GestureDetector(
                                    onTap: () => _showTermsOfService(context, (agreed) {
                                      setState(() {
                                        isChecked = agreed;
                                        if (isChecked) showWarning = false;
                                      });
                                    }),
                                    child: Text(
                                      'เงื่อนไขเเละข้อตกลงการให้บริการ Term of Service',
                                      style: TextStyle(
                                        color: MainTheme.mainText,
                                        fontSize: 12,
                                        fontFamily: 'BaiJamjuree',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  if (showWarning)
                                    Text(
                                      'กรุณายอมรับเงื่อนไขและข้อตกลง',
                                      style: TextStyle(
                                        color: MainTheme.redWarning,
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

                    // Sign-in buttons for Google
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
