import 'package:flutter/material.dart';
import 'package:client/core/router/router.dart';
import 'package:client/services/auth_service.dart';
import 'package:client/services/user_api_service.dart'; 
import 'package:client/services/user_service.dart';
import 'package:client/services/tutorial_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Check if landing page has been viewed before
  final hasViewedLanding = await TutorialPreferences.hasViewedLandingPage();
  
  // Initialize initial route based on auth status
  final AuthService authService = AuthService();
  final isAuthenticated = await authService.isAuthenticated();
  
  String initialLocation;
  
  // If user hasn't seen landing page, show it first
  if (!hasViewedLanding) {
    initialLocation = '/landing';
  } else if (isAuthenticated) {
    // User is authenticated, determine which home page based on role
    try {
      print('User is authenticated, checking role...');
      
      final apiService = ApiService();
      final userId = await UserService.getCurrentUserId();
      print('Current user ID: $userId');
      
      if (userId.isEmpty) {
        print('User ID is empty despite being authenticated, defaulting to login');
        initialLocation = '/login';
      } else {
        print('Fetching user data for ID: $userId');
        final userData = await apiService.getUser(userId);
        print('User data retrieved: $userData');
        
        final isOphthalmologist = userData['is_opthamologist'] ?? false;
        print('User is ophthalmologist: $isOphthalmologist');
        
        // Set appropriate home page based on role
        initialLocation = isOphthalmologist ? '/home-opht' : '/home';
        print('Setting initial location to: $initialLocation');
      }
    } catch (e) {
      print('Error determining user role: $e');
      // Fall back to login if there's an error checking role
      initialLocation = '/login';
    }
  } else {
    // Not authenticated
    initialLocation = '/login';
  }
  
  runApp(MyApp(initialLocation: initialLocation));
}

class MyApp extends StatelessWidget {
  final String initialLocation;
  
  const MyApp({super.key, this.initialLocation = '/login'});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: createRouter(initialLocation: initialLocation),
        theme: ThemeData(
          useMaterial3: true,
        ),
      );
}
