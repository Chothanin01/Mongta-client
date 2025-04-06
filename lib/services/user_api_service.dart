import 'dart:convert';
import 'dart:io';
import 'package:client/services/http_client.dart';
import 'package:client/services/user_service.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // ฟังก์ชันดึงข้อมูลผู้ใช้จาก API getuser
  Future<Map<String, dynamic>> getUser(String userId) async {
    try {
      // Replace direct http call with HttpClient.get
      final response = await HttpClient.get('/api/getuser?userId=$userId');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['user']; // ส่งคืนข้อมูล user
        } else {
          throw Exception('API returned success: false - ${data['message']}');
        }
      } else {
        throw Exception('Failed to load user: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user: $e');
      rethrow; // ส่ง error ต่อไปยัง caller
    }
  }

  // New method for user notifications
  Future<Map<String, dynamic>> getUserNotifications() async {
    try {
      final userId = await UserService.getCurrentUserId();
      final response = await HttpClient.get('/api/usernoti?user_id=$userId');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      rethrow;
    }
  }

  // New method for ophthalmologist notifications
  Future<Map<String, dynamic>> getOphtNotifications() async {
    try {
      final userId = await UserService.getCurrentUserId();
      final response = await HttpClient.get('/api/ophtnoti?user_id=$userId');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching ophthalmologist notifications: $e');
      rethrow;
    }
  }

  // Updated method for updating user profile
  Future<Map<String, dynamic>> updateUser(
      String firstName, 
      String lastName,
      String username,  // Add username parameter
      String email,     // Keep for compatibility
      File? profilePicture) async {
    try {
      print('Update profile request with:');
      print('- firstName: $firstName');
      print('- lastName: $lastName');
      print('- username: $username');    // Log username
      print('- profile picture provided: ${profilePicture != null}');
      
      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${HttpClient.baseUrl}/api/updateuser'),
      );
      
      // Add authorization header
      final token = await UserService.getToken();
      request.headers['Authorization'] = 'Bearer $token';
      
      // Add text fields - include username
      request.fields['first_name'] = firstName;
      request.fields['last_name'] = lastName;
      request.fields['username'] = username;  // Add username field
      
      // Profile picture handling
      if (profilePicture == null) {
        print('WARNING: No profile picture provided. Backend requires a file!');
        throw Exception('Profile picture is required for updates');
      } else {
        print('Adding profile picture to request: ${profilePicture.path}');
        final fileStream = http.ByteStream(profilePicture.openRead());
        final fileLength = await profilePicture.length();
        
        final multipartFile = http.MultipartFile(
          'file', 
          fileStream, 
          fileLength,
          filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        
        request.files.add(multipartFile);
      }
      
      // Rest of the method remains the same
      print('Sending update request to server...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print('Server response status: ${response.statusCode}');
      print('Server response body: ${response.body}');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update profile: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }
}
