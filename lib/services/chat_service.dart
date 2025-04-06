import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:client/services/http_client.dart';
import 'package:client/services/user_service.dart';

class ChatService {
  // Find available ophthalmologist
  Future<Map<String, dynamic>> findOphthalmologist(String gender) async {
    try {
      final userId = await UserService.getCurrentUserId();
      if (userId.isEmpty) {
        throw Exception('User not authenticated');
      }

      final response = await HttpClient.post(
        '/api/findophth',
        {
          'user_id': int.parse(userId),
          'sex': gender,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to find ophthalmologist: ${response.body}');
      }
    } catch (e) {
      print('Error finding ophthalmologist: $e');
      rethrow;
    }
  }

  // Get chat history
  Future<Map<String, dynamic>> getChatHistory() async {
    try {
      final userId = await UserService.getCurrentUserId();
      if (userId.isEmpty) {
        throw Exception('User not authenticated');
      }

      final response = await HttpClient.get('/api/chathistory/$userId');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load chat history: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting chat history: $e');
      rethrow;
    }
  }

  // Get chat messages for a specific conversation
  Future<Map<String, dynamic>> getChatMessages(int conversationId) async {
    try {
      final userId = await UserService.getCurrentUserId();
      if (userId.isEmpty) {
        throw Exception('User not authenticated');
      }

      final response = await HttpClient.get('/api/chat/$conversationId/$userId');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load chat messages: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting chat messages: $e');
      rethrow;
    }
  }

  // Send a text message
  Future<Map<String, dynamic>> sendTextMessage(int conversationId, String message) async {
    try {
      final userId = await UserService.getCurrentUserId();
      if (userId.isEmpty) {
        throw Exception('User not authenticated');
      }

      final data = {
        'conversation_id': conversationId,
        'sender_id': int.parse(userId),
        'message': message,
      };

      final response = await HttpClient.post('/api/sendchat', data);

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  // Send an image message
  Future<Map<String, dynamic>> sendImageMessage(int conversationId, XFile image) async {
    try {
      final userId = await UserService.getCurrentUserId();
      if (userId.isEmpty) {
        throw Exception('User not authenticated');
      }

      // Create a multipart request
      final uri = Uri.parse('${HttpClient.baseUrl}/api/sendchat');
      final request = http.MultipartRequest('POST', uri);
      
      // Add authorization token
      final token = await UserService.getToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      // Add required fields
      request.fields['conversation_id'] = conversationId.toString();
      request.fields['sender_id'] = userId;
      
      // Create file from the image path
      final file = File(image.path);
      final fileLength = await file.length();
      final fileStream = http.ByteStream(file.openRead());
      
      // Create multipart file with correct content type
      final filename = image.name.isNotEmpty ? image.name : 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final contentType = image.mimeType != null 
          ? MediaType.parse(image.mimeType!) 
          : MediaType('image', 'jpeg');
      
      final multipartFile = http.MultipartFile(
        'file', // Make sure this field name matches your server expectations
        fileStream,
        fileLength,
        filename: filename,
        contentType: contentType,
      );
      
      // Add the file to the request
      request.files.add(multipartFile);
      
      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print('Image upload response: ${response.statusCode} - ${response.body}');
      
      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to send image: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error sending image: $e');
      rethrow;
    }
  }
}