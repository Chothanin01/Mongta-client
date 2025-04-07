import 'package:flutter/material.dart';
import 'package:client/services/auth_service.dart';
import 'package:client/services/socket_service.dart';
import 'package:client/services/status_service.dart';

class AppLifecycleObserver with WidgetsBindingObserver {
  final AuthService _authService = AuthService();
  bool _isPickingMedia = false; // Add flag to track media picking
  
  AppLifecycleObserver() {
    WidgetsBinding.instance.addObserver(this);
    _initializeSocket();
  }

  // Call this before opening image picker
  void setMediaPickerActive() {
    _isPickingMedia = true;
    debugPrint('Media picker active, pausing lifecycle events');
  }

  // Call this after image picker completes
  void setMediaPickerInactive() {
    _isPickingMedia = false;
    debugPrint('Media picker inactive, resuming lifecycle events');
  }

  Future<void> _initializeSocket() async {
    final isAuthenticated = await _authService.isAuthenticated();
    if (isAuthenticated) {
      await Future.delayed(Duration(milliseconds: 500));
      await SocketService.initSocket();
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Always use HTTP status update for final disconnect
    StatusService.setOffline().then((_) {
      SocketService.disconnect();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    // Skip lifecycle events during media picking
    if (_isPickingMedia) {
      debugPrint('Ignoring lifecycle event during media picking: $state');
      return;
    }
    
    final isAuthenticated = await _authService.isAuthenticated();
    if (!isAuthenticated) return;
    
    debugPrint('App lifecycle state changed to: $state');
    
    switch (state) {
      case AppLifecycleState.resumed:
        // App in foreground - use HTTP for immediate status update
        await StatusService.setOnline();
        // Then initialize socket for real-time updates
        await SocketService.initSocket();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        // Use HTTP for more reliable status update when going to background
        // But DON'T log out or disconnect socket permanently
        await StatusService.setOffline();
        // Don't disconnect socket here - let it timeout naturally
        break;
      default:
        break;
    }
  }
}