import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart';
import 'package:client/main.dart';

class CameraService {
  CameraController? controller;
  List<CameraDescription> cameras = [];
  bool _isInitialized = false;
  bool _useMockCamera = false;
  String? _errorMessage;
  
  // Camera settings
  ResolutionPreset _resolutionPreset = ResolutionPreset.high;
  CameraLensDirection _preferredLensDirection = CameraLensDirection.front;

  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  bool get useMockCamera => _useMockCamera;

  // Call this method to attempt to find a better resolution if initial fails
  Future<bool> _tryAnotherResolution() async {
    if (_resolutionPreset == ResolutionPreset.high) {
      _resolutionPreset = ResolutionPreset.medium;
    } else if (_resolutionPreset == ResolutionPreset.medium) {
      _resolutionPreset = ResolutionPreset.low;
    } else {
      return false; // Can't go lower than low resolution
    }
    
    debugPrint('Trying lower resolution: $_resolutionPreset');
    return await _initializeWithCurrentSettings();
  }

  Future<bool> _initializeWithCurrentSettings() async {
    if (controller != null) {
      await controller!.dispose();
      controller = null;
    }
    
    try {
      // Find appropriate camera
      CameraDescription? selectedCamera;
      
      // Always try to find front camera first
      for (var camera in cameras) {
        if (camera.lensDirection == _preferredLensDirection) {
          selectedCamera = camera;
          debugPrint("Preferred camera direction found: ${camera.lensDirection}");
          break;
        }
      }
      
      // If no preferred camera found, use the first available
      selectedCamera ??= cameras.first;
      debugPrint("Using camera: ${selectedCamera.name}, direction: ${selectedCamera.lensDirection}");
      
      // Create controller with current resolution setting
      controller = CameraController(
        selectedCamera,
        _resolutionPreset,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.yuv420 : ImageFormatGroup.bgra8888,
      );
      
      // Initialize controller with timeout
      await controller!.initialize().timeout(
        Duration(seconds: 3),
        onTimeout: () {
          throw TimeoutException('Camera controller initialization timed out');
        }
      );
      
      // Set flash mode to auto
      if (controller!.value.isInitialized) {
        await controller!.setFlashMode(FlashMode.auto);
      }
      
      return true;
    } catch (e) {
      debugPrint("Error initializing camera with current settings: $e");
      return false;
    }
  }

  Future<void> initializeService() async {
    // Only initialize if not already initialized
    if (controller?.value.isInitialized ?? false) {
      return;
    }

    if (_isInitialized) return;
    
    _errorMessage = null;

    try {
      // Get available cameras
      cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw 'No cameras available on this device';
      }
      
      // Try to initialize with default settings
      bool success = await _initializeWithCurrentSettings();
      
      // If failed, try again with lower resolution
      if (!success) {
        success = await _tryAnotherResolution();
      }
      
      // If still failed, try again with lower resolution
      if (!success) {
        success = await _tryAnotherResolution();
      }
      
      if (!success) {
        throw 'Failed to initialize camera with any resolution';
      }
      
      _isInitialized = true;
    } catch (e) {
      debugPrint("Camera initialization error: $e");
      // Don't rethrow, instead set error state that can be handled
      _isInitialized = false;
      _errorMessage = e.toString();
      throw e; // But do make the error visible to the caller
    }
  }

  Future<File?> takePicture() async {
    if (_useMockCamera) {
      return _generateMockEyeImage();
    }

    if (controller == null || !controller!.value.isInitialized) {
      debugPrint('Camera controller not initialized');
      return null;
    }

    try {
      // Flag taking picture as active media operation
      lifecycleObserver.setMediaPickerActive();
      
      // Optimize photo settings for better eye scan
      await controller!.setExposureMode(ExposureMode.auto);
      await controller!.setFocusMode(FocusMode.auto);
      
      // Wait for auto settings to stabilize
      await Future.delayed(Duration(milliseconds: 300));
      
      // Take picture
      final XFile image = await controller!.takePicture();

      // Get application directory
      final directory = await getTemporaryDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File imageFile = File(path.join(directory.path, fileName));

      // Copy image to new file to ensure proper handling
      await File(image.path).copy(imageFile.path);
      
      // Reset flag after successful picture
      lifecycleObserver.setMediaPickerInactive();
      
      return imageFile;
    } catch (e) {
      debugPrint('Failed to take picture: $e');
      // Reset flag on error
      lifecycleObserver.setMediaPickerInactive();
      return null;
    }
  }

  Future<File?> _generateMockEyeImage() async {
    try {
      // Get a placeholder image from your assets
      final ByteData data = await rootBundle.load('assets/images/mock_eye.png');
      final Uint8List bytes = data.buffer.asUint8List();

      // Save to a temporary file
      final directory = await getTemporaryDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File imageFile = File(path.join(directory.path, fileName));

      await imageFile.writeAsBytes(bytes);
      return imageFile;
    } catch (e) {
      debugPrint('Failed to generate mock image: $e');
      return null;
    }
  }

  void enableMockCamera() {
    _useMockCamera = true;
    _isInitialized = true;
  }

  Future<void> dispose() async {
    if (controller != null) {
      await controller!.dispose();
      controller = null;
    }
    _isInitialized = false;
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
  
  @override
  String toString() => message;
}