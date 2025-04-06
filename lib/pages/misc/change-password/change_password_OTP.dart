import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:client/core/theme/theme.dart';
import 'package:client/core/components/entryForm/entry_button.dart';
import 'package:go_router/go_router.dart';
import 'package:client/services/api_service.dart';
import 'dart:async';

class ChangePasswordOTPPage extends StatefulWidget {
  final Map<String, dynamic> params;
  
  const ChangePasswordOTPPage({
    Key? key,
    required this.params,
  }) : super(key: key);

  @override
  State<ChangePasswordOTPPage> createState() => _ChangePasswordOTPPageState();
}

class _ChangePasswordOTPPageState extends State<ChangePasswordOTPPage> {
  // Controllers for the 6 OTP input fields
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  
  // Focus nodes for each field to manage focus
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  // Timer for resend countdown
  Timer? _timer;
  int _countdownSeconds = 0;
  bool _canResend = true;

  // New variables
  bool _isLoading = false;
  String? _errorMessage;
  int _timeLeft = 300; // 5 minutes
  late String _ref;
  
  @override
  void initState() {
    super.initState();
    // Get ref from widget params instead of route
    _ref = widget.params['ref'] as String;
    _startTimer();

    for (int i = 0; i < 6; i++) {
      _focusNodes[i].addListener(() {
        setState(() {}); // Rebuild to update focus state visuals
      });
    }
  }

  @override
  void dispose() {
    // Clean up controllers and focus nodes
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.removeListener(() {});
      node.dispose();
    }
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  // Collect the OTP from all fields
  String get _otpValue {
    return _otpControllers.map((controller) => controller.text).join();
  }

  // Verify the entered OTP
  Future<void> verifyOtp(BuildContext context) async {
    final otp = _otpValue;
    
    if (otp.length != 6) {
      setState(() {
        _errorMessage = 'กรุณากรอกรหัส OTP ให้ครบ 6 หลัก';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final String otpCopy = otp;
      final String refCopy = _ref;
      
      final response = await ApiService.verifyChangePasswordOTP(otpCopy, refCopy);
      
      if (!mounted) return;
      
      if (response['success'] == true) {
        _timer?.cancel();
        
        // Navigate to password change page
        Future.microtask(() {
          if (mounted) {
            context.push('/change-password');
          }
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = response['message'] ?? 'รหัส OTP ไม่ถูกต้อง';
        });
      }
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
        _errorMessage = 'เกิดข้อผิดพลาด: $e';
      });
    }
  }

  void goBack(BuildContext context) {
    context.pop(); // Go back to previous page
  }

  // Start the resend countdown timer
  void _startResendTimer() {
    setState(() {
      _canResend = false;
      _countdownSeconds = 30; // 30 second countdown
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdownSeconds > 0) {
          _countdownSeconds--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  String _formatTime() {
    int minutes = _timeLeft ~/ 60;
    int seconds = _timeLeft % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  // Resend OTP function
  Future<void> resendOtp() async {
    if (_timeLeft > 0) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.requestChangePasswordOTP();
      
      if (!mounted) return;
      
      if (response['success'] == true) {
        setState(() {
          _ref = response['Ref'];
          _timeLeft = 300;
        });
        _startTimer();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('รหัส OTP ใหม่ได้ถูกส่งไปที่อีเมลของคุณแล้ว'),
            backgroundColor: MainTheme.blueText,
          ),
        );
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'ไม่สามารถส่ง OTP ใหม่ได้';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'เกิดข้อผิดพลาด: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
                          'ยืนยันรหัส OTP',
                          style: TextStyle(
                            color: MainTheme.mainText,
                            fontSize: 20,
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
                            'กรุณาตรวจสอบรหัส OTP จากข้อความในอีเมล\nที่ทางเราได้ส่งเข้าไปยังอีเมลของคุณ',
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
                        
                        const SizedBox(height: 40),
                        
                        // OTP input row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            6,
                            (index) => _buildOtpDigitField(context, index),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Resend OTP text
                        GestureDetector(
                          onTap: _timeLeft <= 0 ? resendOtp : null,
                          child: Text(
                            _timeLeft <= 0 
                                ? 'ส่งรหัส OTP อีกครั้ง'
                                : 'ส่งรหัสใหม่ใน ${_formatTime()}',
                            style: TextStyle(
                              color: _timeLeft <= 0 ? MainTheme.blueText : MainTheme.placeholderText,
                              fontSize: 14,
                              fontFamily: 'BaiJamjuree',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 60),
                        
                        // Verify button
                        EntryButton(
                          onTap: _isLoading ? null : () => verifyOtp(context),
                          buttonText: "ยืนยัน OTP",
                        ),
                        
                        // Error message display
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
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
                        
                        const SizedBox(height: 30),
                      ],
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
  
  // Helper method to build each OTP digit input field
  Widget _buildOtpDigitField(BuildContext context, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: 40,
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(
          color: _focusNodes[index].hasFocus 
              ? MainTheme.blueText
              : MainTheme.textfieldBorder,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(8),
        color: MainTheme.mainBackground,
      ),
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'BaiJamjuree',
          color: MainTheme.mainText,
        ),
        decoration: const InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) {
          if (value.isNotEmpty) {
            // Move to next field if available
            if (index < 5) {
              _focusNodes[index + 1].requestFocus();
            } else {
              // Hide keyboard when the last digit is entered
              _focusNodes[index].unfocus();
            }
          } else if (index > 0) {
            // Move to previous field on backspace
            _focusNodes[index - 1].requestFocus();
          }
          setState(() {}); // Rebuild to update button state
        },
      ),
    );
  }
}