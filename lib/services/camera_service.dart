import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class CameraService {
  CameraController? controller;
  List<CameraDescription> cameras = [];
  String? errorMessage;

  Future<void> initialize() async {
    try {
      cameras = await availableCameras();
      if (cameras.isEmpty) {
        errorMessage = 'No cameras available';
        return;
      }

      // Try to use front camera first
      final frontCameras = cameras.where(
        (camera) => camera.lensDirection == CameraLensDirection.front
      ).toList();

      final cameraToUse = frontCameras.isNotEmpty ? frontCameras.first : cameras.first;
      
      controller = CameraController(
        cameraToUse,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await controller!.initialize();
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('Camera initialization error: $e');
    }
  }

  Future<File?> takePicture() async {
    if (controller == null || !controller!.value.isInitialized) {
      return null;
    }

    try {
      final XFile image = await controller!.takePicture();
      final directory = await getTemporaryDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final imageFile = File(path.join(directory.path, fileName));
      
      await File(image.path).copy(imageFile.path);
      return imageFile;
    } catch (e) {
      debugPrint('Failed to take picture: $e');
      return null;
    }
  }

  void dispose() {
    controller?.dispose();
    controller = null;
  }
}