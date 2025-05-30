import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:client/services/http_client.dart';
import 'package:client/services/status_service.dart';

class UserService {
  static final _storage = FlutterSecureStorage();
  static const _userIdKey = 'user_id';
  static const _tokenKey = 'token';
  
  // Get current user ID
  static Future<String> getCurrentUserId() async {
    try {
      final userId = await _storage.read(key: _userIdKey);
      return userId ?? '';
    } catch (e) {  
      print('Error getting user ID: $e');
      return '';
    }
  }
  
  // Save user ID
  static Future<void> saveUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
  }
  
  // Save token
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }
  
  // Get token
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Logout with backend call
  static Future<bool> logout() async {
    try {
      // Get token for authorization - do this first before clearing anything
      final token = await getToken();
      
      // Clear user data immediately to prevent repeated calls
      await _clearUserData();
      
      // Skip API call if no token
      if (token == null || token.isEmpty) {
        return true;
      }
      
      // Call backend signout API as a final step
      print('Calling backend signout API...');
      final response = await http.post(
        Uri.parse('${HttpClient.baseUrl}/api/signout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );
      
      print('Signout response status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('Error during logout: $e');
      return false;
    }
  }

  // Helper method to clear all user data
  static Future<void> _clearUserData() async {
    try {
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _userIdKey);
      // Clear any other stored user data
    } catch (e) {
      print('Error clearing user data: $e');
    }
  }

  static Future<void> clearUserDataOnly() async {
    await _clearUserData();
  }
}