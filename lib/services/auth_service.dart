import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:client/services/user_service.dart';
import 'package:client/services/http_client.dart';
import 'package:client/services/user_api_service.dart'; 
import 'package:go_router/go_router.dart'; 
import 'package:client/services/status_service.dart';
import 'package:client/services/socket_service.dart';


class AuthService {
  // Update your GoogleSignIn initialization
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // Update the signInWithGoogle method with more error details
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      // Clear previous sign-in state
      try {
        await _googleSignIn.signOut();
        print('Successfully signed out from previous Google session');
      } catch (e) {
        print('Error signing out from Google: $e');
        // Continue anyway
      }
      
      print('Starting Google Sign In...');
      
      // Start the Google sign-in process with more detailed error handling
      GoogleSignInAccount? googleUser;
      try {
        googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          print('Sign in aborted by user');
          return null;
        }
      } catch (signInError) {
        print('Detailed Google Sign-In error: $signInError');
        
        // Check if it's a common error
        if (signInError.toString().contains('10:')) {
          print('Error 10 usually means the OAuth client ID or SHA-1 is misconfigured');
        }
        
        rethrow; // Let the UI handle the error
      }

      print('Signed in as: ${googleUser.email}');
      print('Display name: ${googleUser.displayName}');
      print('Photo URL: ${googleUser.photoUrl}');
      print('Server auth code: ${googleUser.serverAuthCode}');
      
      // Get authentication details from Google
      GoogleSignInAuthentication? googleAuth;
      try {
        googleAuth = await googleUser.authentication;
        print('Successfully obtained Google authentication tokens');
      } catch (authError) {
        print('Error getting Google authentication tokens: $authError');
        rethrow;
      }
      
      print('ID token length: ${googleAuth.idToken?.length ?? 0}');
      print('Access token length: ${googleAuth.accessToken?.length ?? 0}');
      
      if (googleAuth.idToken == null) {
        throw Exception("Google authentication token is null");
      }

      try {
        if (googleAuth.idToken != null) {
          final parts = googleAuth.idToken!.split('.');
          if (parts.length >= 2) {
            // Decode the payload (middle part)
            final normalizedPayload = base64Url.normalize(parts[1]);
            final payloadJson = utf8.decode(base64Url.decode(normalizedPayload));
            final payload = json.decode(payloadJson);
            print('Token payload: $payload');
            print('TOKEN AUDIENCE: ${payload['aud']}');
          }
        }
      } catch (e) {
        print('Error decoding token: $e');
      }
      
      // Send the Google token to your backend
      final response = await http.post(
        Uri.parse('${HttpClient.baseUrl}/api/googlelogin'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'idtoken': googleAuth.idToken,
        }),
      );
      
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        if (data['isRegister'] == true) {
          // User exists, save JWT token and return success
          await UserService.saveToken(data['token']);
          final userId = data['user']['id'].toString();
          await UserService.saveUserId(userId);
          
          // Set user status to online
          await StatusService.setOnline();
          
          // Initialize socket connection
          await SocketService.initSocket();
          
          return {
            'isRegister': true,
            'user': data['user'],
            'token': data['token'],
          };
        } else {
          // User not registered, return data for registration
          return {
            'isRegister': false,
            'userData': {
              'email': googleUser.email,
              'picture': googleUser.photoUrl,
              'first_name': googleUser.displayName?.split(' ').first ?? '',
              'last_name': googleUser.displayName?.split(' ').skip(1).join(' ') ?? '',
            },
            'idToken': googleAuth.idToken,
            'provider': 'google',
          };
        }
      } else {
        throw Exception('Backend error: ${response.body}');
      }
    } catch (e) {
      debugPrint("Error signing in with Google: $e");
      rethrow;
    }
  }

  // Complete Registration for Google Login
  Future<Map<String, dynamic>?> completeRegistration(Map<String, dynamic> registrationData) async {
    try {
      // Make sure we're sending all the data needed by your backend
      final completeData = {
        ...registrationData,
        'email': registrationData['userData']?['email'],
        'picture': registrationData['userData']?['picture'],
        'username': registrationData['userData']?['username'],
      };
      
      debugPrint('Sending registration data: ${json.encode(completeData)}');
      
      final response = await http.post(
        Uri.parse('${HttpClient.baseUrl}/api/googleregister'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(completeData),
      );

      final data = json.decode(response.body);
      debugPrint('Registration response: ${response.statusCode}, ${response.body}');
      
      if (response.statusCode == 201 && data['success'] == true) {
        await UserService.saveToken(data['token']);
        await UserService.saveUserId(data['user']['id']);
        
        return {
          'success': true,
          'message': 'Registration successful',
          'user': data['user'],
        };
      } else {
        throw Exception('Registration failed: ${data['message']}');
      }
    } catch (e) {
      debugPrint('Error completing registration: $e');
      return {
        'success': false,
        'message': 'Registration failed: $e',
      };
    }
  }

  // Complete Google Registration
  Future<Map<String, dynamic>> completeGoogleRegistration(
      Map<String, dynamic> userData, 
      String idToken, 
      String phoneNumber, 
      String gender, 
      DateTime? birthDate) async {
    try {
      final requestData = {
        'id_token': idToken,
        'phonenumber': phoneNumber,
        'first_name': userData['first_name'],
        'last_name': userData['last_name'],
        'sex': gender,
        'dob': birthDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
        'email': userData['email'],
        'profile_picture': userData['picture'],
      };
      
      print('Complete request data details:');
      print('- First name: ${userData['first_name']}');
      print('- Last name: ${userData['last_name']}');
      print('- Phone: $phoneNumber');
      print('- Gender: $gender');
      print('- DOB: ${birthDate?.toIso8601String() ?? "null"}');
      print('- Picture URL: ${userData['picture']}');
      
      debugPrint('Sending Google registration data: ${json.encode(requestData)}');
      
      final response = await http.post(
        Uri.parse('${HttpClient.baseUrl}/api/googleregister'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestData),
      );
      
      debugPrint('Registration response: ${response.statusCode}, ${response.body}');
      final data = json.decode(response.body);
      
      if (response.statusCode == 201) {
        // Save credentials
        await UserService.saveToken(data['token'] ?? '');
        await UserService.saveUserId(data['user']['id'].toString());
        
        // Set user as online after registration
        await StatusService.setOnline();
        
        // Initialize socket connection
        await SocketService.initSocket();
        
        return {
          'success': true,
          'message': data['message'] ?? 'Registration successful',
          'user': data['user']
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registration failed'
        };
      }
    } catch (e) {
      debugPrint('Google registration error: $e');
      return {
        'success': false,
        'message': 'Connection error: $e'
      };
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await UserService.logout();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await UserService.getToken();
    return token != null && token.isNotEmpty;
  }

  // Logout
  Future<void> logout() async {
    try {
      // First, disconnect socket
      SocketService.disconnect();
      
      // Then clear credentials and make HTTP call to update status
      await UserService.logout();
    } catch (e) {
      print('Error during logout: $e');
      // Use the public method instead
      await UserService.clearUserDataOnly();
    }
  }

  // Navigate after login
  Future<void> navigateAfterLogin(BuildContext context, String userId) async {
    try {
      if (userId.isEmpty) {
        print('Empty user ID in navigateAfterLogin, going to login page');
        if (context.mounted) context.go('/login');
        return;
      }
      
      // Create instance of ApiService
      final apiService = ApiService();
      final userData = await apiService.getUser(userId);
      final isOphthalmologist = userData['is_opthamologist'] ?? false;
      
      print('Role check - User is ophthalmologist: $isOphthalmologist');
      
      if (context.mounted) {
        if (isOphthalmologist) {
          context.go('/home-opht');
        } else {
          context.go('/home');
        }
      }
    } catch (e) {
      print('Error navigating after login: $e');
      if (context.mounted) {
        context.go('/home'); // Default to regular home on error
      }
    }
  }

  // Login
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      print('Auth service: Preparing login request for user $username');
      
      final response = await http.post(
        Uri.parse('${HttpClient.baseUrl}/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );
      
      print('Auth service: Login response status code: ${response.statusCode}');
      print('Auth service: Response body: ${response.body}');
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        print('Auth service: Login successful with status 200');
        
        // Save credentials
        await UserService.saveToken(data['token'] ?? '');
        final userId = data['user']?['id']?.toString() ?? '';
        await UserService.saveUserId(userId);
        
        // Set user status to online
        await StatusService.setOnline();
        
        // Initialize socket connection
        await SocketService.initSocket();
        
        // Make sure success=true in the returned data
        return {
          'success': true,
          'message': data['message'] ?? 'Login successful',
          'user': data['user'] ?? {},
          'token': data['token'] ?? '',
        };
      } else {
        print('Auth service: Login failed with message: ${data['message']}');
        return {
          'success': false,
          'message': data['message'] ?? 'ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง',
        };
      }
    } catch (e) {
      print('Auth service: Exception during login: ${e.toString()}');
      rethrow;
    }
  }
}
