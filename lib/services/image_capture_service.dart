import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:client/main.dart';

class ImageCaptureService {
  static final ImageCaptureService _instance = ImageCaptureService._internal();
  
  factory ImageCaptureService() {
    return _instance;
  }
  
  ImageCaptureService._internal();
  
  final ImagePicker _picker = ImagePicker();
  
  Future<File?> captureImageFromCamera() async {
    try {
      
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 90,
      );
            
      return image != null ? File(image.path) : null;
    } catch (e) {
      debugPrint('Error capturing image: $e');
      return null;
    }
  }
  
  Future<File?> pickImageFromGallery() async {
    try {
      
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      
      if (pickedFile == null) return null;
      
      // Process and optimize the image
      return await _optimizeImage(File(pickedFile.path));
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }
  
  Future<File?> _optimizeImage(File imageFile) async {
    try {
      // Decode image
      final bytes = await imageFile.readAsBytes();
      final originalImage = img.decodeImage(bytes);
      
      if (originalImage == null) return imageFile;
      
      // Resize and compress if needed
      img.Image processedImage = originalImage;
      if (originalImage.width > 1024 || originalImage.height > 1024) {
        processedImage = img.copyResize(
          originalImage,
          width: originalImage.width > originalImage.height ? 1024 : null,
          height: originalImage.height >= originalImage.width ? 1024 : null,
        );
      }
      
      // Save to a temporary file
      final directory = await getTemporaryDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_optimized.jpg';
      final File optimizedFile = File(path.join(directory.path, fileName));
      
      // Encode as JPEG with quality setting
      final jpegBytes = img.encodeJpg(processedImage, quality: 85);
      await optimizedFile.writeAsBytes(jpegBytes);
      
      return optimizedFile;
    } catch (e) {
      debugPrint('Error optimizing image: $e');
      return imageFile; // Return original if optimization fails
    }
  }
}