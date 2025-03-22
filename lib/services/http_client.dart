import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:client/services/user_service.dart';

class HttpClient {
  static final String baseUrl = kReleaseMode 
      ? 'https://your-production-url.com' 
      : 'http://10.0.2.2:5000';

  // GET request with authentication
  static Future<http.Response> get(String endpoint, {Map<String, String>? headers}) async {
    final token = await UserService.getToken();
    final requestHeaders = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      ...?headers,
    };
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: requestHeaders,
      );
      
      // Handle token issues
      if (response.statusCode == 401) {
        // Token expired or invalid - could trigger a logout or token refresh here
        await UserService.logout();
      }
      
      return response;
    } catch (e) {
      debugPrint('HTTP GET Error: $e');
      rethrow;
    }
  }

  // POST request with authentication
  static Future<http.Response> post(
    String endpoint, 
    dynamic body, 
    {Map<String, String>? headers}
  ) async {
    final token = await UserService.getToken();
    final requestHeaders = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      ...?headers,
    };
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: requestHeaders,
        body: body is String ? body : jsonEncode(body),
      );
      
      // Handle token issues
      if (response.statusCode == 401) {
        // Token expired or invalid
        await UserService.logout();
      }
      
      return response;
    } catch (e) {
      debugPrint('HTTP POST Error: $e');
      rethrow;
    }
  }

  // For multipart requests (file uploads)
  static Future<http.Response> multipartRequest(
    String endpoint,
    http.MultipartRequest request,
  ) async {
    final token = await UserService.getToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    
    try {
      final streamedResponse = await request.send();
      return await http.Response.fromStream(streamedResponse);
    } catch (e) {
      debugPrint('Multipart Request Error: $e');
      rethrow;
    }
  }
}