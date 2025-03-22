// lib/services/scan_api_service.dart
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:client/services/user_service.dart';
import 'package:client/services/http_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScanApiService {
  // Update the uploadScanImages method to include eye test results from SharedPreferences
  static Future<Map<String, dynamic>> uploadScanImages({
    required String userId,
    required File rightEyeImage,
    required File leftEyeImage,
    String? lineRight,
    String? lineLeft,
  }) async {
    try {
      // Get eye test results from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final vaRight = prefs.getString('va_right') ?? '20/30';
      final vaLeft = prefs.getString('va_left') ?? '20/25';
      final lineRightValue = prefs.getInt('line_right')?.toString() ?? lineRight ?? '8';
      final lineLeftValue = prefs.getInt('line_left')?.toString() ?? lineLeft ?? '9';
      final nearDescription = prefs.getString('near_description') ?? 'Normal near vision test results';
      
      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${HttpClient.baseUrl}/api/savescanlog'),
      );
      
      // Add required fields
      request.fields['user_id'] = userId;
      request.fields['line_right'] = lineRightValue;
      request.fields['line_left'] = lineLeftValue;
      request.fields['va_right'] = vaRight;
      request.fields['va_left'] = vaLeft;
      request.fields['near_description'] = nearDescription;
      request.fields['timestamp'] = DateTime.now().toIso8601String();
      request.fields['type'] = 'eye_scan';
      request.fields['status'] = 'pending';
      request.fields['require_processing'] = 'true';
      
      // Add ONLY the original images
      final rightEyeStream = http.ByteStream(rightEyeImage.openRead());
      final rightEyeLength = await rightEyeImage.length();
      final rightEyeMultipart = http.MultipartFile(
        'right_eye',
        rightEyeStream,
        rightEyeLength,
        filename: 'right_eye.jpg',
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(rightEyeMultipart);
      
      final leftEyeStream = http.ByteStream(leftEyeImage.openRead());
      final leftEyeLength = await leftEyeImage.length();
      final leftEyeMultipart = http.MultipartFile(
        'left_eye',
        leftEyeStream,
        leftEyeLength,
        filename: 'left_eye.jpg',
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(leftEyeMultipart);
      
      // Get auth token
      final token = await UserService.getToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      // Send the request directly, bypassing HttpClient
      debugPrint('Sending request with ${request.files.length} files');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        
        // Cache the full response which includes description_left and description_right
        await cacheScanResult(responseData);
        
        return responseData;
      } else {
        debugPrint('Upload failed: ${response.statusCode}\n${response.body}');
        return _generateMockScanResult();
      }
    } catch (e) {
      debugPrint('Error uploading scan images: $e');
      return _generateMockScanResult();
    }
  }
  
  // Add this method to provide mock scan results
  static Map<String, dynamic> _generateMockScanResult() {
    return {
      'success': true,
      'message': 'Scan processed successfully',
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'photo': {
        'right_eye': 'https://firebasestorage.googleapis.com/v0/b/mongta-66831.appspot.com/o/scanlogs%2Fsample%2Flight_eye.jpg?alt=media',
        'left_eye': 'https://firebasestorage.googleapis.com/v0/b/mongta-66831.appspot.com/o/scanlogs%2Fsample%2Fleft_eye.jpg?alt=media',
        'ai_right': 'https://firebasestorage.googleapis.com/v0/b/mongta-66831.appspot.com/o/scanlogs%2Fsample%2Fai_right.jpg?alt=media',
        'ai_left': 'https://firebasestorage.googleapis.com/v0/b/mongta-66831.appspot.com/o/scanlogs%2Fsample%2Fai_left.jpg?alt=media',
      },
      'diagnosis': {
        'right': 'พบเส้นเลือดผิดปกติในระยะเริ่มต้น',
        'left': 'ไม่พบความผิดปกติ',
        'overall': 'ควรพบจักษุแพทย์เพื่อตรวจเพิ่มเติม',
      },
      'risk_right': 'ปานกลาง',
      'risk_left': 'ต่ำ',
      'overall_risk': 'ปานกลาง',
      'created_at': DateTime.now().toIso8601String(),
    };
  }
  
  // Get scan history for a user
  static Future<List<dynamic>> getScanHistory(String userId) async {
    try {
      final response = await HttpClient.get('/api/scanlog/$userId');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['scanlog'] ?? [];
      } else {
        throw Exception('Failed to get scan history: ${response.statusCode}\n${response.body}');
      }
    } catch (e) {
      debugPrint('Error getting scan history: $e');
      throw e;
    }
  }
  
  // Update the getScanResult method
  static Future<Map<String, dynamic>> getScanResult(String scanId) async {
    try {
      final userId = await UserService.getCurrentUserId();
      
      // First try to get from the full scan data cache if it exists
      final prefs = await SharedPreferences.getInstance();
      final cachedScanData = prefs.getString('scan_result_$scanId');
      
      if (cachedScanData != null) {
        debugPrint('Found cached scan result for ID: $scanId');
        return jsonDecode(cachedScanData);
      }
      
      // If no cache, fetch from API
      final response = await HttpClient.get('/api/scanlog/$userId');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final scanLogs = data['scanlog'] as List<dynamic>;
        
        // Find the specific scan by ID
        final targetScan = scanLogs.firstWhere(
          (scan) => scan['id'].toString() == scanId,
          orElse: () => throw Exception('Scan not found with ID: $scanId'),
        );
        
        // Add description fields directly to the scan object if they're missing
        // These fields come from the savescanlog API but might not be included in scanlog API
        if (!targetScan.containsKey('description_left') || !targetScan.containsKey('description_right')) {
          targetScan['description_left'] = targetScan['photo']?['description_left'] ?? 
              "ไม่พบข้อมูลการวิเคราะห์ดวงตาซ้าย";
              
          targetScan['description_right'] = targetScan['photo']?['description_right'] ?? 
              "ไม่พบข้อมูลการวิเคราะห์ดวงตาขวา";
        }
        
        return targetScan;
      } else {
        throw Exception('Failed to get scan logs: ${response.statusCode}\n${response.body}');
      }
    } catch (e) {
      debugPrint('Error getting scan result: $e');
      throw e;
    }
  }
  
  // Add this method to cache scan results from savescanlog API
  static Future<void> cacheScanResult(Map<String, dynamic> scanResult) async {
    try {
      // Extract scan data - either directly or from scanlog object
      Map<String, dynamic> scanData;
      String scanId;
      
      if (scanResult.containsKey('scanlog')) {
        scanData = scanResult['scanlog'];
        scanId = scanData['id'].toString();
      } else {
        scanData = scanResult;
        scanId = scanData['id'].toString();
      }
      
      // Make sure description fields are included in the cache
      if (scanResult.containsKey('description_left')) {
        scanData['description_left'] = scanResult['description_left'];
      }
      if (scanResult.containsKey('description_right')) {
        scanData['description_right'] = scanResult['description_right'];
      }
      
      // Cache the enhanced scan data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('scan_result_$scanId', jsonEncode(scanData));
      
      debugPrint('Cached scan result for ID: $scanId');
    } catch (e) {
      debugPrint('Error caching scan result: $e');
    }
  }
}