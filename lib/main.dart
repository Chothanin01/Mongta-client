import 'package:flutter/material.dart';
import 'package:client/core/router/router.dart';
import 'package:client/services/auth_service.dart';
import 'package:client/services/user_api_service.dart'; 
import 'package:client/services/user_service.dart';
import 'package:client/services/tutorial_preferences.dart';
import 'package:client/services/status_service.dart';
import 'package:client/services/socket_service.dart';
import 'package:client/core/lifecycle/app_lifecycle_observer.dart';
import 'dart:async';

// Global reference to maintain the observer
late AppLifecycleObserver lifecycleObserver;

void main() async {
  // Add error catching for the entire app
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize the lifecycle observer
    lifecycleObserver = AppLifecycleObserver();
    
    // Initialize initial route based on auth status
    String initialLocation = '/landing'; // Default route
    
    try {
      // Check if landing page has been viewed before
      final hasViewedLanding = await TutorialPreferences.hasViewedLandingPage();
      
      // Check authentication status
      final AuthService authService = AuthService();
      final isAuthenticated = await authService.isAuthenticated();
      
      // Set initial user status if authenticated
      if (isAuthenticated) {
        await StatusService.setOnline();
        
        // Only try to check role and set home page if authenticated
        try {
          final apiService = ApiService();
          final userId = await UserService.getCurrentUserId();
          
          if (userId.isNotEmpty) {
            final userData = await apiService.getUser(userId);
            final isOphthalmologist = userData['is_opthamologist'] ?? false;
            initialLocation = isOphthalmologist ? '/home-opht' : '/home';
          }
        } catch (e) {
          print('Error determining role: $e - using default home page');
          initialLocation = '/home';
        }
      } else if (!hasViewedLanding) {
        initialLocation = '/landing';
      }
    } catch (e) {
      print('Error during initialization: $e');
      // Use login as fallback route in case of any errors
    }
    
    runApp(MyApp(initialLocation: initialLocation));
  }, (error, stack) {
    print('Uncaught error: $error');
    print('Stack trace: $stack');
  });
}

class MyApp extends StatefulWidget {
  final String initialLocation;
  
  const MyApp({super.key, this.initialLocation = '/login'});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    // Clean up lifecycle observer when app is terminated
    lifecycleObserver.dispose();
    SocketService.dispose(); // Add this line
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: createRouter(initialLocation: widget.initialLocation),
        theme: ThemeData(
          useMaterial3: true,
        ),
      );
}
