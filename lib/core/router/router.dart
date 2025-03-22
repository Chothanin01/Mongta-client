import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:client/core/router/path.dart';

import 'package:client/pages/landing/landing.dart';

// Import auth section
import 'package:client/pages/auth/login.dart';
import 'package:client/pages/auth/register.dart';
import 'package:client/pages/auth/ggfb_register.dart';
import 'package:client/pages/auth/otp/complete_otp.dart';

import 'package:client/pages/map/map.dart';
import 'package:client/pages/home/home.dart';
import 'package:client/pages/chat/chat_history.dart';
import 'package:client/pages/chat/chat_screen.dart';
// import 'package:client/pages/scan/scan.dart';
import 'package:client/pages/near_chart/near_chart_one.dart';
import 'package:client/pages/near_chart/near_chart_two.dart';
import 'package:client/pages/near_chart/near_chart_three.dart';
import 'package:client/pages/near_chart/near_chart_four.dart';
import 'package:client/pages/misc/setting.dart';
import 'package:client/core/components/navbar.dart';

// import tutorial section
import 'package:client/pages/tutorial/first_time_choose_tutorial.dart';
import 'package:client/pages/tutorial/nearchart_tutorial.dart';
import 'package:client/pages/tutorial/scan_tutorial.dart';
import 'package:client/pages/auth/otp/email/verify_email_otp.dart';

import 'package:client/pages/scan/scan_coordinator.dart';
import 'package:client/core/router/auth_guard.dart';
import 'package:client/pages/scanlog/scanlog.dart';

// Create a function that returns a GoRouter with the given initial location
GoRouter createRouter({String initialLocation = '/login'}) {
  return GoRouter(
    initialLocation: initialLocation,
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
        redirect: AuthGuard.preventAuthAccess,
        builder: (context, state) => LoginPage(),
      ),

      GoRoute(
        path: Path.registerPage,
        builder: (context, state) => RegisterPage(),
      ),

      // Chat Page Route
      GoRoute(
        path: Path.chatScreenPage,
        builder: (context, state) => ChatScreen(),
      ),

      // Scan Page Route
      GoRoute(
        path: '/scan',
        redirect: AuthGuard.requireAuth,
        builder: (context, state) => const ScanCoordinatorPage(),
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

      // Add the complete OTP route
      GoRoute(
        path: Path.completeOtpPage, // Or use '/complete-otp' directly
        builder: (context, state) => const OtpPage(),
      ),

      GoRoute(
        path: Path.scanlogPage,
        redirect: AuthGuard.requireAuth,
        builder: (context, state) => const ScanlogPage(),
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
            path: Path.chatHistoryPage,
            builder: (context, state) => ChatHistory(),
          ),

          GoRoute(
            path: Path.settingPage,
            builder: (context, state) => SettingPage(),
          ),
        ],
      ),

      // Tutorial routes
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
      GoRoute(
        path: Path.nearcharttwoPage,
        builder: (context, state) => NearChartTwo(),
      ),
      GoRoute(
        path: Path.nearchartthreePage,
        builder: (context, state) => NearChartThree(),
      ),
      GoRoute(
        path: Path.nearchartfourPage,
        builder: (context, state) => NearChartFour(),
      ),

      GoRoute(
        path: '/verify_otp',
        builder: (context, state) {
          final params = state.extra as Map<String, dynamic>;
          return VerifyOtpPage(params: params);
        },
      ),
    ],
  );
}

// Define a key for the root navigator
final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
