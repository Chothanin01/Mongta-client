import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:client/core/theme/theme.dart';
import 'package:client/services/camera_service.dart';
import 'package:client/services/image_capture_service.dart';

class EyeScanPage extends StatefulWidget {
  final Function(File, bool) onImageCaptured;
  final VoidCallback onBackPressed;
  final File? rightEyeImage;
  final File? leftEyeImage;
  
  const EyeScanPage({
    super.key,
    required this.onImageCaptured,
    required this.onBackPressed,
    this.rightEyeImage,
    this.leftEyeImage,
  });
  
  @override
  State<EyeScanPage> createState() => _EyeScanPageState();
}

class _EyeScanPageState extends State<EyeScanPage> with WidgetsBindingObserver {
  final ImageCaptureService _imageService = ImageCaptureService();
  final CameraService _cameraService = CameraService();
  bool _isRightEyeSelected = true;
  bool _isCameraInitializing = true;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }
  
  Future<void> _initializeCamera() async {
    setState(() {
      _isCameraInitializing = true;
      _errorMessage = null;
    });
    
    try {
      await _cameraService.initializeService();
    } catch (e) {
      setState(() {
        _errorMessage = 'ไม่สามารถเข้าถึงกล้องได้: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isCameraInitializing = false;
        });
      }
    }
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle changes to manage camera resources
    if (state == AppLifecycleState.inactive) {
      _cameraService.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraService.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // ONLY force right eye selection if right eye is not captured AND left eye is not selected
    if (widget.rightEyeImage == null && !_isRightEyeSelected) {
      setState(() {
        _isRightEyeSelected = true;
      });
    }
    
    return Scaffold(
      backgroundColor: Colors.transparent, // Changed from MainTheme.mainBackground to transparent
      body: SafeArea(
        child: Stack(
          children: [
            // Main content area
            Column(
              children: [
                // Top segmented control for eye selection
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  width: double.infinity,
                  color: Colors.transparent, // Already transparent
                  child: Center(
                    child: Container(
                      width: 280,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white, // Keep this as is (tab)
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: MainTheme.blueText, width: 1),
                      ),
                      child: Row(
                        // Tab row content stays the same
                        children: [
                          // Right Eye Tab - Always enabled
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (!_isRightEyeSelected) {
                                  setState(() {
                                    _isRightEyeSelected = true;
                                  });
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _isRightEyeSelected 
                                      ? MainTheme.blueText 
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(21),
                                ),
                                child: Center(
                                  child: Text(
                                    'ตาขวา',
                                    style: TextStyle(
                                      color: _isRightEyeSelected 
                                          ? Colors.white 
                                          : MainTheme.blueText,
                                      fontFamily: 'BaiJamjuree',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          // Left Eye Tab - Enabled only if right eye is captured
                          Expanded(
                            child: GestureDetector(
                              // Only allow selecting left eye if right eye is captured
                              onTap: widget.rightEyeImage != null
                                  ? () {
                                      setState(() {
                                        _isRightEyeSelected = false;
                                      });
                                    }
                                  : null,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: !_isRightEyeSelected 
                                      ? MainTheme.blueText 
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(21),
                                ),
                                child: Center(
                                  child: Text(
                                    'ตาซ้าย',
                                    style: TextStyle(
                                      color: !_isRightEyeSelected 
                                          ? Colors.white 
                                          : widget.rightEyeImage != null
                                              ? MainTheme.blueText
                                              : MainTheme.placeholderText,
                                      fontFamily: 'BaiJamjuree',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Camera preview area with bounding box
                Expanded(
                  child: Container(
                    color: Colors.transparent, // Changed from black to transparent
                    child: Center(
                      child: _buildCameraPreview(),
                    ),
                  ),
                ),
                
                // Bottom section with capture button
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  color: Colors.transparent, // Already transparent
                  child: Center(
                    child: GestureDetector(
                      onTap: _isCameraInitializing 
                          ? null 
                          : (_isRightEyeSelected && widget.rightEyeImage != null) || 
                             (!_isRightEyeSelected && widget.leftEyeImage != null)
                              ? _retakeCurrentImage
                              : _captureImage,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: MainTheme.white, // Keep this as is (button)
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: (_isRightEyeSelected && widget.rightEyeImage != null) || 
                                  (!_isRightEyeSelected && widget.leftEyeImage != null)
                                ? MainTheme.redWarning
                                : MainTheme.blueText,
                            width: 3
                          ),
                        ),
                        child: Center(
                          child: _isCameraInitializing
                              ? const CircularProgressIndicator(color: MainTheme.blueText)
                              : (_isRightEyeSelected && widget.rightEyeImage != null) || 
                                 (!_isRightEyeSelected && widget.leftEyeImage != null)
                                  ? const Icon(
                                      Icons.refresh,
                                      color: MainTheme.redWarning,
                                      size: 28,
                                    )
                                  : Container(
                                      width: 48,
                                      height: 48,
                                      decoration: const BoxDecoration(
                                        color: MainTheme.blueText, // Keep this as is (button)
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Back button
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: MainTheme.mainText,
                  size: 22,
                ),
                onPressed: widget.onBackPressed,
              ),
            ),
            
            // Gallery button
            Positioned(
              bottom: 30,
              right: 32,
              child: GestureDetector(
                onTap: _isCameraInitializing ? null : _pickImageFromGallery,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: MainTheme.white, // Keep this as is (button)
                    shape: BoxShape.circle,
                    border: Border.all(color: MainTheme.textfieldBorder, width: 1.5),
                  ),
                  child: Icon(
                    Icons.photo_library,
                    color: _isCameraInitializing 
                        ? MainTheme.placeholderText
                        : MainTheme.blueText,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCameraPreview() {
    // Display error message if camera service has an error
    if (_cameraService.errorMessage != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: MainTheme.redWarning, size: 64),
          const SizedBox(height: 16),
          Text(
            'Camera error: ${_cameraService.errorMessage}',
            style: const TextStyle(color: MainTheme.redWarning),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _cameraService.enableMockCamera();
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: MainTheme.blueText,
            ),
            child: const Text('Use Mock Camera Instead'),
          ),
        ],
      );
    }
  
    // Display error message if there's an issue
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: MainTheme.redWarning, size: 64),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(
                color: MainTheme.redWarning,
                fontFamily: 'BaiJamjuree',
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Show loading indicator while camera initializes
    if (_isCameraInitializing) {
      return const Center(
        child: CircularProgressIndicator(color: MainTheme.blueText),
      );
    }

    // Show already captured images if available
    if ((_isRightEyeSelected && widget.rightEyeImage != null) || 
        (!_isRightEyeSelected && widget.leftEyeImage != null)) {
      final File imageToShow = _isRightEyeSelected 
          ? widget.rightEyeImage! 
          : widget.leftEyeImage!;
      
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          imageToShow,
          fit: BoxFit.contain,
          width: 300,
          height: 300,
        ),
      );
    }

    // Show camera preview with improved selection frame
    return Stack(
      alignment: Alignment.center,
      children: [
        // Camera preview
        if (_cameraService.controller?.value.isInitialized ?? false)
          SizedBox(
            width: double.infinity,
            child: AspectRatio(
              aspectRatio: _cameraService.controller!.value.aspectRatio,
              child: CameraPreview(_cameraService.controller!),
            ),
          ),
          
        // New mobile-camera-style focus frame
        Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: Colors.transparent),
          ),
          child: Stack(
            children: [
              // Top-left corner
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.white, width: 3),
                      left: BorderSide(color: Colors.white, width: 3),
                    ),
                  ),
                ),
              ),
              // Top-right corner
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.white, width: 3),
                      right: BorderSide(color: Colors.white, width: 3),
                    ),
                  ),
                ),
              ),
              // Bottom-left corner
              Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.white, width: 3),
                      left: BorderSide(color: Colors.white, width: 3),
                    ),
                  ),
                ),
              ),
              // Bottom-right corner
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.white, width: 3),
                      right: BorderSide(color: Colors.white, width: 3),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Focus point indicator
        Container(
          width: 15,
          height: 15,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.5),
          ),
          child: Center(
            child: Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildCapturedImageIndicator(String text, File image) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            color: MainTheme.greenComplete,
            fontFamily: 'BaiJamjuree',
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            border: Border.all(color: MainTheme.greenComplete),
            borderRadius: BorderRadius.circular(4),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Image.file(
              image,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _captureImage() async {
    if (_cameraService.controller == null ||
        !_cameraService.controller!.value.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กล้องไม่พร้อมใช้งาน'),
          backgroundColor: MainTheme.redWarning,
        ),
      );
      return;
    }

    final File? image = await _cameraService.takePicture();
    if (image != null) {
      widget.onImageCaptured(image, _isRightEyeSelected);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ไม่สามารถถ่ายรูปได้ กรุณาลองอีกครั้ง'),
          backgroundColor: MainTheme.redWarning,
        ),
      );
    }
  }
  
  void _retakeCurrentImage() {
    widget.onImageCaptured(File(''), _isRightEyeSelected);
  }
  
  Future<void> _pickImageFromGallery() async {
    final File? image = await _imageService.pickImageFromGallery();
    if (image != null) {
      widget.onImageCaptured(image, _isRightEyeSelected);
    }
  }
}