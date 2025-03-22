// lib/services/camera_service.dart
import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart';

class CameraService {
  CameraController? controller;
  List<CameraDescription> cameras = [];
  bool _isInitialized = false;
  bool _useMockCamera = false;
  String? _errorMessage;

  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  bool get useMockCamera => _useMockCamera;

  Future<void> initializeService() async {
    if (_isInitialized) return;
    
    try {
      cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw 'No cameras available';
      }
      
      // Use front camera instead of back camera
      await initializeCamera(CameraLensDirection.front);
      _isInitialized = true;
    } catch (e) {
      debugPrint("Camera initialization error: $e");
      // Don't rethrow, instead set error state that can be handled
      _isInitialized = false;
      _errorMessage = e.toString();
    }
  }
  
  Future<void> initializeCamera(CameraLensDirection direction) async {
    if (controller != null) {
      await controller!.dispose();
    }
    
    CameraDescription? selectedCamera;
    
    // Always try to find front camera first
    for (var camera in cameras) {
      if (camera.lensDirection == CameraLensDirection.front) {
        selectedCamera = camera;
        debugPrint("Front camera found and selected");
        break;
      }
    }
    
    // If front camera not found, then try the specified direction
    if (selectedCamera == null) {
      for (var camera in cameras) {
        if (camera.lensDirection == direction) {
          selectedCamera = camera;
          debugPrint("Requested camera direction found");
          break;
        }
      }
    }
    
    // If still no camera found, use first available
    selectedCamera ??= cameras.first;
    debugPrint("Using camera: ${selectedCamera.name}, direction: ${selectedCamera.lensDirection}");
    
    // Create controller
    controller = CameraController(
      selectedCamera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    
    // Initialize controller
    await controller!.initialize();
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
      // Take picture
      final XFile image = await controller!.takePicture();
      
      // Get application directory
      final directory = await getTemporaryDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File imageFile = File(path.join(directory.path, fileName));
      
      // Copy image to new file to ensure proper handling
      await File(image.path).copy(imageFile.path);
      
      return imageFile;
    } catch (e) {
      debugPrint('Failed to take picture: $e');
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