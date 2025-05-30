// lib/pages/auth/otp/verify_otp.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:client/core/theme/theme.dart';
import 'package:client/services/api_service.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart'; 

class ForgotPasswordOTPPage extends StatefulWidget {
  final Map<String, dynamic> params;
  
  const ForgotPasswordOTPPage({
    Key? key,
    required this.params,
  }) : super(key: key);

  @override
  State<ForgotPasswordOTPPage> createState() => _ForgotPasswordOTPPageState();
}

class _ForgotPasswordOTPPageState extends State<ForgotPasswordOTPPage> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  int _timeLeft = 300; // 5 minutes
  Timer? _timer;
  late String _email;
  late String _ref;

  @override
  void initState() {
    super.initState();
    _email = widget.params['email'] as String;
    _ref = widget.params['ref'] as String;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _otpController.dispose();
    super.dispose();
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

  Future<void> _requestNewOtp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.requestPasswordResetOTP(_email);
      
      if (!mounted) return;
      
      if (response['success'] == true) {
        setState(() {
          _ref = response['Ref'];
          _timeLeft = 300;
          _otpController.clear();
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

  Future<void> _verifyOtp() async {
    final String otpValue = _otpController.text.trim();
    
    if (otpValue.isEmpty || otpValue.length < 6) {
      setState(() {
        _errorMessage = 'กรุณากรอกรหัส OTP 6 หลัก';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Capture all values before async operations
      final String emailCopy = _email;
      final String otpCopy = otpValue;
      final String refCopy = _ref;
      
      final response = await ApiService.verifyPasswordResetOTP(
        emailCopy, 
        otpCopy, 
        refCopy
      );
      
      if (!mounted) return;
      
      if (response['success'] == true) {
        // OTP is valid, navigate to set new password
        _timer?.cancel();
        
        Future.microtask(() {
          if (mounted) {
            context.push('/forgot-password', extra: {'email': emailCopy});
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MainTheme.mainBackground,
      appBar: AppBar(
        title: const Text('ยืนยันอีเมล'),
        backgroundColor: MainTheme.mainBackground,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            const Text(
              'ยืนยันรหัส OTP',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                fontFamily: 'BaiJamjuree',
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'รหัสยืนยันถูกส่งไปที่อีเมล\n$_email',
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'BaiJamjuree',
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Ref: $_ref',
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'BaiJamjuree',
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'หมดอายุใน: ${_formatTime()}',
                  style: TextStyle(
                    fontSize: 14,
                    color: _timeLeft < 60 ? MainTheme.redWarning : MainTheme.mainText,
                    fontFamily: 'BaiJamjuree',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 40),
            
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
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
            
            PinCodeTextField(
              appContext: context,
              length: 6,
              controller: _otpController,
              obscureText: false,
              animationType: AnimationType.fade,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(8),
                fieldHeight: 50,
                fieldWidth: 40,
                activeFillColor: Colors.white,
                inactiveFillColor: Colors.white,
                selectedFillColor: Colors.white,
                activeColor: MainTheme.blueText,
                inactiveColor: MainTheme.textfieldBorder,
                selectedColor: MainTheme.blueText,
              ),
              animationDuration: const Duration(milliseconds: 300),
              enableActiveFill: true,
              keyboardType: TextInputType.number,
              onCompleted: (_) {},
              onChanged: (_) {},
            ),
            
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading || _timeLeft == 0 ? null : _verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: MainTheme.blueText,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'ยืนยัน',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'BaiJamjuree',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            _timeLeft <= 0 
              ? TextButton(
                  onPressed: _isLoading ? null : _requestNewOtp,
                  child: const Text(
                    'ส่งรหัส OTP อีกครั้ง',
                    style: TextStyle(
                      color: MainTheme.blueText,
                      fontSize: 16,
                      fontFamily: 'BaiJamjuree',
                    ),
                  ),
                )
              : const Text(
                  'ไม่ได้รับรหัส? โปรดรอจนกว่าจะหมดเวลา',
                  style: TextStyle(
                    color: MainTheme.placeholderText,
                    fontSize: 14,
                    fontFamily: 'BaiJamjuree',
                  ),
                  textAlign: TextAlign.center,
                ),
          ],
        ),
      ),
    );
  }
}