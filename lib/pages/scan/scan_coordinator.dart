import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:client/core/theme/theme.dart';
import 'package:client/pages/scan/eye_scan_page.dart';
import 'package:client/pages/scan/scan_confirmation_page.dart';
import 'package:client/pages/scan/scan_result.dart';
import 'package:client/pages/scan/scan_processing.dart';
import 'package:client/services/scan_api_service.dart';
import 'package:client/services/user_service.dart';

enum ScanStage {
  capture,
  confirm,
  processing,
  result,
}

class ScanCoordinatorPage extends StatefulWidget {
  const ScanCoordinatorPage({super.key});
  
  @override
  State<ScanCoordinatorPage> createState() => _ScanCoordinatorPageState();
}

class _ScanCoordinatorPageState extends State<ScanCoordinatorPage> {
  File? _rightEyeImage;
  File? _leftEyeImage;
  File? _currentImage;
  bool _isRightEyeSelected = true;
  ScanStage _currentStage = ScanStage.capture;
  Map<String, dynamic>? _scanResult;
  String? _errorMessage;
  
  @override
  Widget build(BuildContext context) {
    switch (_currentStage) {
      case ScanStage.capture:
        return EyeScanPage(
          onImageCaptured: _handleImageCaptured,
          onBackPressed: _handleBackPressed,
          rightEyeImage: _rightEyeImage,
          leftEyeImage: _leftEyeImage,
        );
        
      case ScanStage.confirm:
        if (_currentImage == null) {
          // Fallback to capture if no image to confirm
          _currentStage = ScanStage.capture;
          return EyeScanPage(
            onImageCaptured: _handleImageCaptured,
            onBackPressed: _handleBackPressed,
            rightEyeImage: _rightEyeImage,
            leftEyeImage: _leftEyeImage,
          );
        }
        
        return ScanConfirmationPage(
          imageFile: _currentImage!,
          isRightEye: _isRightEyeSelected,
          onConfirm: _handleConfirmImage,
          onRetake: _handleRetakeImage,
          onBackPressed: () {
            setState(() {
              _currentStage = ScanStage.capture;
            });
          },
        );
        
      case ScanStage.processing:
        return ScanProcessingPage(
          onBackPressed: () {
            setState(() {
              _currentStage = ScanStage.capture;
            });
          },
        );
        
      case ScanStage.result:
        if (_scanResult == null) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return ScanResultPage(
          scanResult: _scanResult!,
          onBackPressed: () {
            context.go('/home'); // Go back to home
          },
          onNewScan: _restartScanProcess,
        );
    }
  }
  
  void _handleImageCaptured(File image, bool isRightEye) {
    if (image.path.isEmpty) {
      // This is a signal to clear the current image
      setState(() {
        if (isRightEye) {
          _rightEyeImage = null;
        } else {
          _leftEyeImage = null;
        }
        // Stay on capture stage
      });
      return;
    }
    
    setState(() {
      _isRightEyeSelected = isRightEye;
      _currentImage = image;
      _currentStage = ScanStage.confirm;
    });
  }
  
  void _handleConfirmImage() {
    if (_currentImage == null) return;
    
    setState(() {
      if (_isRightEyeSelected) {
        _rightEyeImage = _currentImage;
        _isRightEyeSelected = false; // Switch to left eye after right is confirmed
        _currentImage = null;
        _currentStage = ScanStage.capture; // Go back to capture with left eye selected
        
        // Add a notification that right eye was captured and we're now scanning left eye
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('บันทึกภาพตาขวาสำเร็จ กรุณาถ่ายภาพตาซ้าย'),
            backgroundColor: MainTheme.blueText,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        _leftEyeImage = _currentImage;
        _currentImage = null;
        
        // If both eyes are captured, proceed to processing
        _currentStage = ScanStage.processing;
        _uploadScanImages();
      }
    });
  }
  
  void _handleRetakeImage() {
    setState(() {
      _currentImage = null;
      _currentStage = ScanStage.capture;
    });
  }
  
  Future<void> _uploadScanImages() async {
    if (_rightEyeImage == null || _leftEyeImage == null) return;
    
    setState(() {
      _errorMessage = null;
    });
    
    try {
      // Check if user is authenticated
      final userId = await UserService.getCurrentUserId();
      final token = await UserService.getToken();
      
      if (userId.isEmpty || token == null) {
        // User is not authenticated, redirect to login
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please login to continue'),
              backgroundColor: MainTheme.redWarning,
            ),
          );
          context.go('/login'); // Redirect to login page
          return;
        }
      }
      
      // We already have userId from above, so we'll reuse it
      if (userId.isEmpty) {
        throw Exception("User not authenticated");
      }
      
      // Upload scan images to backend
      final response = await ScanApiService.uploadScanImages(
        userId: userId,
        rightEyeImage: _rightEyeImage!,
        leftEyeImage: _leftEyeImage!,
      );
      
      // Debug the ENTIRE raw response
      debugPrint('FULL API RESPONSE: ${jsonEncode(response)}');
      
      // Extract scan data - try both possible paths
      Map<String, dynamic> scanData;
      
      if (response.containsKey('scanlog')) {
        scanData = response['scanlog'];
      } else {
        scanData = response;
      }
      
      // Debug what we're actually passing to the result page
      debugPrint('SCAN DATA PASSED TO RESULT PAGE: ${jsonEncode(scanData)}');
      
      if (mounted) {
        setState(() {
          _scanResult = scanData;
          _currentStage = ScanStage.result;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'เกิดข้อผิดพลาด: $e';
          // Go back to capture stage if upload fails
          _currentStage = ScanStage.capture;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage!),
            backgroundColor: MainTheme.redWarning,
          ),
        );
      }
    }
  }
  
  void _handleBackPressed() {
    // Navigate back to home screen or previous page
    context.go('/home');
  }
  
  void _restartScanProcess() {
    setState(() {
      _rightEyeImage = null;
      _leftEyeImage = null;
      _currentImage = null;
      _isRightEyeSelected = true;
      _currentStage = ScanStage.capture;
      _scanResult = null;
      _errorMessage = null;
    });
  }
}