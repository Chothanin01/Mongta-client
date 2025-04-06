// lib/services/api_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:client/services/http_client.dart';

class ApiService {
  // Request OTP via email
  static Future<Map<String, dynamic>> requestEmailOTP(String email) async {
    try {
      final response = await HttpClient.post(
        '/api/otp/mail',
        {'email': email},
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to request OTP: ${response.statusCode}\n${response.body}');
      }
    } catch (e) {
      debugPrint('Error requesting OTP: $e');
      throw e;
    }
  }

  // Register with OTP verification
  static Future<Map<String, dynamic>> registerWithOtp({
    required String username,
    required String password,
    required String phonenumber,
    required String email,
    required String first_name,
    required String last_name,
    required String sex,
    required String dob,
    required String otp,
    required String otp_ref,
  }) async {
    try {
      final response = await HttpClient.post(
        '/api/register',
        {
          'username': username,
          'password': password,
          'phonenumber': phonenumber,
          'email': email,
          'first_name': first_name,
          'last_name': last_name,
          'sex': sex,
          'dob': dob,
          'otp': otp,
          'otp_ref': otp_ref,
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('Error registering user: $e');
      throw e;
    }
  }

  // Login user
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await HttpClient.post(
        '/api/login',
        {
          'username': username,
          'password': password,
        },
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to login: ${response.statusCode}\n${response.body}');
      }
    } catch (e) {
      debugPrint('Error logging in: $e');
      throw e;
    }
  }
  
  // Request password reset OTP
  static Future<Map<String, dynamic>> requestPasswordResetOTP(String email) async {
    try {
      final response = await HttpClient.post(
        '/api/otp/mail',
        {
          'email': email,
          'type': 'forgot_password',
        },
      );
  
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'ไม่สามารถส่ง OTP ได้',
        };
      }
    } catch (e) {
      debugPrint('Error requesting password reset OTP: $e');
      return {
        'success': false,
        'message': 'เกิดข้อผิดพลาดในการเชื่อมต่อ',
      };
    }
  }
  
  // Verify OTP for password reset
  static Future<Map<String, dynamic>> verifyPasswordResetOTP(String email, String otp, String ref) async {
    try {
      // The backend expects otp_ref, not ref
      final response = await HttpClient.post(
        '/api/otp',
        {
          'email': email,
          'otp': otp,
          'otp_ref': ref,  // CHANGE THIS LINE FROM 'ref' to 'otp_ref'
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'รหัส OTP ไม่ถูกต้อง',
        };
      }
    } catch (e) {
      debugPrint('Error verifying OTP: $e');
      return {
        'success': false,
        'message': 'เกิดข้อผิดพลาดในการเชื่อมต่อ',
      };
    }
  }
  
  // Reset password
  static Future<Map<String, dynamic>> resetPassword(String email, String newPassword) async {
    try {
      final response = await HttpClient.post(
        '/api/forgetpassword',
        {
          'email': email,
          'new_password': newPassword,
        },
      );
  
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'ไม่สามารถเปลี่ยนรหัสผ่านได้',
        };
      }
    } catch (e) {
      debugPrint('Error resetting password: $e');
      return {
        'success': false,
        'message': 'เกิดข้อผิดพลาดในการเชื่อมต่อ',
      };
    }
  }

  // Request OTP for changing password
  static Future<Map<String, dynamic>> requestChangePasswordOTP() async {
    try {
      final userResponse = await HttpClient.get('/api/getuser');
      
      if (userResponse.statusCode != 200) {
        debugPrint('Failed to get user profile: ${userResponse.statusCode}');
        return {
          'success': false,
          'message': 'ไม่สามารถดึงข้อมูลผู้ใช้',
        };
      }
      
      final userData = json.decode(userResponse.body);
      // Extract email string correctly based on your user model structure
      final userEmail = userData['user']['email'];
      
      // Handle the case where email might be an object or a string
      String emailString;
      if (userEmail is String) {
        emailString = userEmail;
      } else if (userEmail is Map) {
        emailString = userEmail['email'] ?? '';
      } else {
        // Fallback
        debugPrint('Unexpected email format: $userEmail');
        return {
          'success': false,
          'message': 'รูปแบบอีเมลไม่ถูกต้อง',
        };
      }
      
      debugPrint('Sending OTP to email: $emailString');
      
      // Send just the email string value to match backend expectations
      final response = await HttpClient.post(
        '/api/otp/mail',
        {
          'email': emailString,
          'type': 'change_password'
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'ไม่สามารถส่ง OTP ได้',
        };
      }
    } catch (e) {
      debugPrint('Error requesting change password OTP: $e');
      return {
        'success': false,
        'message': 'เกิดข้อผิดพลาดในการเชื่อมต่อ',
      };
    }
  }

  // Verify OTP for changing password
  static Future<Map<String, dynamic>> verifyChangePasswordOTP(String otp, String ref) async {
    try {
      // First get user email to include in verification
      final userResponse = await HttpClient.get('/api/getuser');
      
      if (userResponse.statusCode != 200) {
        return {
          'success': false,
          'message': 'ไม่สามารถดึงข้อมูลผู้ใช้',
        };
      }
      
      final userData = json.decode(userResponse.body);
      final userEmail = userData['user']['email'];
      
      // Extract email string
      String emailString;
      if (userEmail is String) {
        emailString = userEmail;
      } else if (userEmail is Map) {
        emailString = userEmail['email'] ?? '';
      } else {
        return {
          'success': false,
          'message': 'รูปแบบอีเมลไม่ถูกต้อง',
        };
      }

      final response = await HttpClient.post(
        '/api/otp',
        {
          'email': emailString,
          'otp': otp,
          'otp_ref': ref
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'รหัส OTP ไม่ถูกต้อง',
        };
      }
    } catch (e) {
      debugPrint('Error verifying OTP: $e');
      return {
        'success': false,
        'message': 'เกิดข้อผิดพลาดในการเชื่อมต่อ',
      };
    }
  }

  // Change password
  static Future<Map<String, dynamic>> changePassword(String oldPassword, String newPassword) async {
    try {
      final response = await HttpClient.post(
        '/api/changepassword',
        {
          'old_password': oldPassword,
          'new_password': newPassword,
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'ไม่สามารถเปลี่ยนรหัสผ่านได้',
        };
      }
    } catch (e) {
      debugPrint('Error changing password: $e');
      return {
        'success': false,
        'message': 'เกิดข้อผิดพลาดในการเชื่อมต่อ',
      };
    }
  }
}