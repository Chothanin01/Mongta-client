import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
  
  // Clear user data on logout
  static Future<void> logout() async {
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _tokenKey);
  }
}