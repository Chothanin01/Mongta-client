import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api/getuser'; // ปรับ URL ตาม backend จริง

  // ฟังก์ชันดึงข้อมูลผู้ใช้จาก API getuser
  Future<Map<String, dynamic>> getUser(String userId) async {
    try {
      final Uri uri = Uri.parse('$baseUrl?userId=$userId');
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

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
  }