import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:client/core/router/path.dart';

import 'package:client/pages/landing/landing.dart';


// Import auth section
import 'package:client/pages/auth/login.dart';
import 'package:client/pages/auth/register.dart';
import 'package:client/pages/auth/ggfb_register.dart';


import 'package:client/pages/map/map.dart';
import 'package:client/pages/home/home.dart';
import 'package:client/pages/chat/chat.dart';
import 'package:client/pages/scan/scan.dart';
import 'package:client/pages/near_chart/near_chart_one.dart';
/* import 'package:client/pages/near_chart/near_chart_two.dart';
import 'package:client/pages/near_chart/near_chart_three.dart';
import 'package:client/pages/near_chart/near_chart_four.dart'; */
import 'package:client/pages/misc/setting.dart';
import 'package:client/core/components/navbar.dart';

// import tutorial section
import 'package:client/pages/tutorial/choose_tutorial.dart';
import 'package:client/pages/tutorial/nearchart_tutorial.dart';
import 'package:client/pages/tutorial/scan_tutorial.dart';


// Define a key for the root navigator
final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

// Define the router configuration
final GoRouter router = GoRouter(
  initialLocation: Path.landingPage,
  navigatorKey: _rootNavigatorKey,
  routes: [
    
    // Landing Page Route
    GoRoute(
      path: Path.landingPage,
      builder: (context, state) => LandingPage(),
    ),
    
    // Login Page Route
    GoRoute(
      path: Path.loginPage,
      builder: (context, state) => LoginPage(),
    ),

    GoRoute(
      path: Path.registerPage,
      builder: (context, state) => RegisterPage(),
    ),

    GoRoute(
      path: '/ggfbregister',
      builder: (context, state) {
        final Map<String, dynamic> extra = state.extra as Map<String, dynamic>;
        return GoogleFacebookRegisterPage(
          userData: extra['userData'],
          idToken: extra['idToken'],
          provider: extra['provider'],
        );
      },
    ),

    
    // Map Page Route
    GoRoute(
      path: Path.mapPage,
      builder: (context, state) => HospitalMapScreen(),
    ),
    

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

    GoRoute(
      path: Path.chooseTutorial,
      builder: (context, state) => TutorialSelection(),
    ),
    GoRoute(
      path: Path.nearChartTutorial,
      builder: (context, state) => NearChartTutorial(),
    ),
    GoRoute(
      path: Path.scanTutorial,
      builder: (context, state) => ScanTutorial(),
    ),
    GoRoute(
      path: Path.nearchartonePage,
      builder: (context, state) => NearChartOne(),
    ),

  ],
);
