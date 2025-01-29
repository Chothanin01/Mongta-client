import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:client/core/router/path.dart';

// Import pages
import 'package:client/pages/auth/login.dart';
// import 'package:client/pages/map.dart';
import 'package:client/pages/home/home.dart';
import 'package:client/pages/chat/chat.dart';
import 'package:client/pages/scan/scan.dart';
import 'package:client/pages/misc/setting.dart';
import 'package:client/core/components/navbar.dart';


// Define a key for the root navigator
final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

// Define the router configuration
final GoRouter router = GoRouter(
  initialLocation: Path.loginPage,
  navigatorKey: _rootNavigatorKey,
  routes: [
    
    // Login Page Route
    GoRoute(
      path: Path.loginPage,
      builder: (context, state) => LoginPage(),
    ),

    /*
    // Map Page Route
    GoRoute(
      path: Path.mapPage,
      builder: (context, state) => HospitalMapScreen(),
    ),
    */

    // Bottom Navigation Shell Route
    ShellRoute(
      builder: (context, state, child) {
        // Wrap all child routes with the BottomNavBar
        return BottomNavBar(child: child);
      },
      routes: [
        // Home Page Route
        GoRoute(
          path: Path.homePage,
          builder: (context, state) => HomePage(),
        ),

        GoRoute(
          path: Path.chatPage,
          builder: (context, state) => ChatPage(),
        ),

        GoRoute(
          path: Path.scanPage,
          builder: (context, state) => ScanPage(),
        ),

        GoRoute(
          path: Path.settingPage,
          builder: (context, state) => SettingPage(),
        ),

        // Additional routes for BottomNavBar pages can go here
        // For example, a scan page or settings page
      ],
    ),
  ],
);
