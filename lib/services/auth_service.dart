import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final String _baseUrl = 'http://10.0.2.2:5000';

  // Google Sign-In
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null; // User canceled the sign-in
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      print("Google Auth Token: ${googleAuth.idToken}");

      // Check if the ID token is present
      if (googleAuth.idToken == null) {
        throw Exception("Google authentication token is null");
      }

      // Send the ID token to the backend for verification and registration check
      final response = await http.post(
        Uri.parse('$_baseUrl/api/googlelogin'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'idtoken': googleAuth.idToken}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {

        // Check if the user is registered
        if (data['isRegister']) {

          // User is already registered, navigate to home
          return {
            'userData': googleUser,
            'idToken': googleAuth.idToken,
            'isRegister': true,
          };
        } else {

          // User is not registered, proceed to registration
          return {
            'userData': googleUser,
            'idToken': googleAuth.idToken,
            'isRegister': false,
          };
        }
      } else {
        throw Exception('Failed to authenticate with backend');
      }
    } catch (error) {
      print("Error signing in with Google: $error");
      return null;
    }
  }

  // Facebook Sign In
  Future<Map<String, dynamic>?> signInWithFacebook() async {
    try {
      final LoginResult loginResult = await FacebookAuth.instance.login();
      if (loginResult.status != LoginStatus.success) return null;

      final accessToken = loginResult.accessToken!.tokenString;

      // Use the accessToken to authenticate with Firebase
      final AuthCredential credential = FacebookAuthProvider.credential(accessToken);

      // Sign in with Firebase using Facebook credentials
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      final User? user = userCredential.user;

      if (user != null) {
        print("User signed in: ${user.displayName}");
        return {
          'userData': user,
          'idToken': accessToken,
          'provider': 'facebook',
        };
      }
      throw Exception("User authentication failed with Facebook");
    } catch (e) {
      print('Error signing in with Facebook: $e');
      rethrow;
    }
  }

  // Complete Registration for Google or Facebook Login
  Future<Map<String, dynamic>?> completeRegistration(Map<String, dynamic> registrationData) async {
    try {
      final String endpoint = registrationData['provider'] == 'google'
          ? '/api/googleregister'
          : '/api/facebookregister';

      final response = await http.post(
        Uri.parse('$_baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(registrationData),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 201 && data['success']) {
        if (data['token'] != null) {
          await _auth.signInWithCustomToken(data['token']);
        }
        return data; // Returning the user data and token if registration was successful
      }
      throw Exception('Registration failed: ${response.body}');
    } catch (e) {
      print('Error completing registration: $e');
      rethrow;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      await FacebookAuth.instance.logOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
