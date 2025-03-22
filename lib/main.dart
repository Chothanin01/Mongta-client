import 'package:flutter/material.dart';
import 'package:client/core/router/router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:client/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize initial route based on auth status
  final AuthService authService = AuthService();
  final isAuthenticated = await authService.isAuthenticated();
  
  runApp(MyApp(initialLocation: isAuthenticated ? '/home' : '/login'));
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
