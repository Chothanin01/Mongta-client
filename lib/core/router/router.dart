import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:client/core/router/path.dart';

import 'package:client/pages/landing/landing.dart';

import 'package:client/pages/auth/login.dart';
import 'package:client/pages/auth/register.dart';
import 'package:client/pages/auth/ggfb_register.dart';
import 'package:client/pages/auth/otp/complete_otp.dart';

import 'package:client/pages/map/map.dart';
import 'package:client/pages/home/home.dart';
import 'package:client/pages/near_chart/near_chart_one.dart';
import 'package:client/pages/near_chart/near_chart_two.dart';
import 'package:client/pages/near_chart/near_chart_three.dart';
import 'package:client/pages/near_chart/near_chart_four.dart';
import 'package:client/pages/misc/setting/setting.dart';
import 'package:client/core/components/navbar.dart';

import 'package:client/pages/tutorial/first_time_choose_tutorial.dart';
import 'package:client/pages/tutorial/nearchart_tutorial.dart';
import 'package:client/pages/tutorial/scan_tutorial.dart';

import 'package:client/pages/tutorial/option_choose_tutorial.dart';
import 'package:client/pages/tutorial/manual_nearchart_tutorial.dart';
import 'package:client/pages/tutorial/manual_scan_tutorial.dart';

import 'package:client/pages/auth/otp/email/verify_email_otp.dart';

import 'package:client/pages/scan/scan_coordinator.dart';
import 'package:client/core/router/auth_guard.dart';
import 'package:client/pages/scanlog/scanlog.dart';

import 'package:client/pages/misc/change-password/forgot_password.dart';
import 'package:client/pages/misc/change-password/forgot_password_OTP.dart';
import 'package:client/pages/misc/change-password/forgot_password_mail.dart';
import 'package:client/pages/misc/change-password/complete_forgot_password.dart';

import 'package:client/pages/misc/change-password/change_password.dart';
import 'package:client/pages/misc/change-password/change_password_OTP.dart';
import 'package:client/pages/misc/change-password/change_password_mail.dart';
import 'package:client/pages/misc/change-password/complete_change_password.dart';

import 'package:client/pages/homeopht/homeopht.dart';
import 'package:client/pages/misc/settingopht/settingopht.dart';

import 'package:client/pages/change_profile/change_profile.dart';

import 'package:client/pages/chat/chat_navigator.dart';
import 'package:client/pages/chat/user/chat_empty_view.dart';
import 'package:client/pages/chat/user/chat_user_history.dart';
import 'package:client/pages/chat/user/chat_user_screen.dart';
import 'package:client/pages/chat/user/chat_search.dart';
import 'package:client/pages/chat/ophth/chat_ophth_history.dart';
import 'package:client/pages/chat/ophth/chat_ophth_screen.dart';

import 'package:client/services/tutorial_preferences.dart';

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
        path: Path.chatEntryPage,
        builder: (context, state) => BottomNavBar(
          child: const ChatNavigator(),
        ),
      ),

      GoRoute(
        path: Path.chatHistoryPage,
        redirect: AuthGuard.requireAuth,
        builder: (context, state) => BottomNavBar(child: const ChatUserHistory()),
      ),

      GoRoute(
        path: Path.chatEmptyPage,
        redirect: AuthGuard.requireAuth,
        builder: (context, state) => BottomNavBar(child: const ChatEmptyView()),
      ),

      GoRoute(
        path: Path.chatSearchPage,
        redirect: AuthGuard.requireAuth,
        builder: (context, state) => const ChatSearch(),
      ),

      GoRoute(
        path: Path.chatOphthHistoryPage,
        redirect: AuthGuard.requireAuth,
        builder: (context, state) => const ChatOphthHistory(),
      ),

      GoRoute(
        path: '${Path.chatUserScreenPage}/:conversationId',
        redirect: AuthGuard.requireAuth,
        builder: (context, state) {
          final conversationId = int.parse(state.pathParameters['conversationId']!);
          return ChatUserScreen(conversationId: conversationId);
        },
      ),

      GoRoute(
        path: '${Path.chatOphthScreenPage}/:conversationId',
        redirect: AuthGuard.requireAuth,
        builder: (context, state) {
          final conversationId = int.parse(state.pathParameters['conversationId']!);
          return ChatOphthScreen(conversationId: conversationId);
        },
      ),

      // Scan Page Route
      GoRoute(
        path: '/scan',
        redirect: AuthGuard.requireAuth,
        builder: (context, state) => const ScanCoordinatorPage(),
      ),

      GoRoute(
        path: '/ggfb_register',
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

      GoRoute(
        path: Path.completeOtpPage,
        builder: (context, state) => const CompleteOtpPage(),
      ),

      GoRoute(
        path: '/complete-otp',
        builder: (context, state) => const CompleteOtpPage(),
      ),

      GoRoute(
        path: '/scanlog',
        redirect: AuthGuard.requireAuth,
        builder: (context, state) => const ScanlogPage(),
      ),

      GoRoute(
        path: '/forgot-password-mail',
        builder: (context, state) => const ForgotPasswordMailPage(),
      ),
      GoRoute(
        path: '/forgot-password-otp',
        builder: (context, state) => ForgotPasswordOTPPage(params: state.extra as Map<String, dynamic>),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/complete-forgot-password',
        builder: (context, state) => const CompleteForgotPasswordPage(),
      ),

      GoRoute(
        path: '/change-password-mail',
        builder: (context, state) => const ChangePasswordMailPage(),
      ),
      GoRoute(
        path: '/change-password-otp',
        builder: (context, state) => ChangePasswordOTPPage(params: state.extra as Map<String, dynamic>),
      ),
      GoRoute(
        path: '/change-password',
        builder: (context, state) => const ChangePasswordPage(),
      ),
      GoRoute(
        path: '/complete-change-password',
        builder: (context, state) => const CompleteChangePasswordPage(),
      ),

      GoRoute(
        path: Path.homeOphtPage,
        redirect: AuthGuard.requireAuth,
        builder: (context, state) => const OphtHomePage(),
      ),

      GoRoute(
        path: Path.settingOphtPage,
        redirect: AuthGuard.requireAuth,
        builder: (context, state) => const OphtSettingsPage(),
      ),

      GoRoute(
        path: Path.editProfilePage,
        redirect: AuthGuard.requireAuth, // Ensure authentication
        builder: (context, state) => const ProfileEditPage(),
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
            path: Path.settingPage,
            builder: (context, state) => SettingsPage(),
          ),

          GoRoute(
            path: Path.chatHistoryPage,
            redirect: AuthGuard.requireAuth,
            builder: (context, state) => BottomNavBar(child: const ChatUserHistory()),
          ),

          GoRoute(
            path: Path.chatEmptyPage,
            redirect: AuthGuard.requireAuth,
            builder: (context, state) => BottomNavBar(child: const ChatEmptyView()),
          ),

          GoRoute(
            path: Path.chatSearchPage,
            redirect: AuthGuard.requireAuth,
            builder: (context, state) => const ChatSearch(),
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
        redirect: (context, state) async {
          if (await TutorialPreferences.hasViewedNearChartTutorial()) {
            return '/near_chart_one'; // Skip to the actual chart
          }
          return null;
        },
      ),
      GoRoute(
        path: Path.scanTutorial,
        builder: (context, state) => ScanTutorial(),
        redirect: (context, state) async {
          if (await TutorialPreferences.hasViewedScanTutorial()) {
            return '/scan'; // Skip to the actual scan
          }
          return null;
        },
      ),

      // Manual Tutorial routes
      GoRoute(
        path: Path.manualTutorialSelection,
        builder: (context, state) => ManualTutorialSelection(),
      ),
      GoRoute(
        path: Path.manualNearChartTutorial,
        builder: (context, state) => ManualNearChartTutorial(),
      ),
      GoRoute(
        path: Path.manualScanTutorial,
        builder: (context, state) => ManualScanTutorial(),
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
