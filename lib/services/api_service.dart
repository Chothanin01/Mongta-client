// lib/services/api_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Base URL for API calls
  static final String baseUrl = kReleaseMode
      ? 'https://your-production-url.com'
      : 'http://10.0.2.2:5000'; // For Android emulator pointing to localhost

  // Request OTP via email
  static Future<Map<String, dynamic>> requestEmailOTP(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/otp/mail'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
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
      final response = await http.post(
        Uri.parse('$baseUrl/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
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
          'method': 'email',
        }),
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
      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
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
}