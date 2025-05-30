import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:client/services/auth_service.dart';

class AuthGuard {
  static final AuthService _authService = AuthService();
  
  // Use this to protect routes that require authentication
  static Future<String?> requireAuth(BuildContext context, GoRouterState state) async {
    final isAuthenticated = await _authService.isAuthenticated();
    
    if (!isAuthenticated) {
      return '/login';
    }
    return null;
  }
  
  // Use this to prevent authenticated users from accessing auth pages
  static Future<String?> preventAuthAccess(BuildContext context, GoRouterState state) async {
    final isAuthenticated = await _authService.isAuthenticated();
    
    if (isAuthenticated) {
      return '/home';
    }
    return null;
  }
}