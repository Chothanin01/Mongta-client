import 'dart:io';
import 'package:flutter/material.dart';
import 'package:client/core/theme/theme.dart';
import 'package:client/services/camera_service.dart';
import 'package:client/services/image_capture_service.dart';
import 'package:client/widgets/eye_scan_tab_selector.dart';
import 'package:client/widgets/focus_frame.dart';
import 'package:client/widgets/camera_mode_button.dart';
import 'package:camera/camera.dart';

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
  bool _isInitializing = true;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }
  
  Future<void> _initializeCamera() async {
    setState(() {
      _isInitializing = true;
    });
    
    await _cameraService.initialize();
    
    if (mounted) {
      setState(() {
        _isInitializing = false;
      });
    }
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
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
    // Force left eye selection if right eye is already captured
    if (widget.rightEyeImage != null && _isRightEyeSelected) {
      setState(() {
        _isRightEyeSelected = false;
      });
    }
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview or image display
          _buildMainContent(),
          
          // UI overlay
          SafeArea(
            child: Column(
              children: [
                // Top bar with eye selector
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: EyeScanTabSelector(
                      isRightEyeSelected: _isRightEyeSelected,
                      isRightEyeCaptured: widget.rightEyeImage != null,
                      onEyeSelected: (isRight) {
                        setState(() {
                          _isRightEyeSelected = isRight;
                        });
                      },
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // Capture button
                Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Center(
                    child: GestureDetector(
                      onTap: _isInitializing
                          ? null
                          : _isCaptureButtonRetake()
                              ? _retakeCurrentImage
                              : _captureImage,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _isCaptureButtonRetake()
                                ? MainTheme.redWarning
                                : MainTheme.blueText,
                            width: 3,
                          ),
                        ),
                        child: Center(
                          child: _isInitializing
                            ? const CircularProgressIndicator(color: MainTheme.blueText)
                            : _isCaptureButtonRetake()
                                ? const Icon(Icons.refresh, color: MainTheme.redWarning, size: 28)
                                : Container(
                                    width: 48,
                                    height: 48,
                                    decoration: const BoxDecoration(
                                      color: MainTheme.blueText,
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
          ),
          
          // Back button
          SafeArea(
            child: Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 22,
                ),
                onPressed: widget.onBackPressed,
              ),
            ),
          ),
          
          // Gallery button
          Positioned(
            bottom: 40,
            right: 32,
            child: GestureDetector(
              onTap: _isInitializing ? null : _pickImageFromGallery,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.photo_library,
                  color: _isInitializing
                      ? MainTheme.placeholderText
                      : MainTheme.blueText,
                  size: 22,
                ),
              ),
            ),
          ),
          
          // Camera mode button
          Positioned(
            bottom: 40,
            left: 32,
            child: CameraModeButton(
              isDisabled: _isInitializing,
              onTap: () async {
                // Directly use the native camera when this button is tapped
                final image = await _imageService.captureImageFromCamera();
                if (image != null) {
                  widget.onImageCaptured(image, _isRightEyeSelected);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
  
  bool _isCaptureButtonRetake() {
    return (_isRightEyeSelected && widget.rightEyeImage != null) ||
           (!_isRightEyeSelected && widget.leftEyeImage != null);
  }
  
  Widget _buildMainContent() {
    // Show captured image if available
    if (_isCaptureButtonRetake()) {
      final File imageToShow = _isRightEyeSelected
          ? widget.rightEyeImage!
          : widget.leftEyeImage!;
      
      return Center(
        child: Image.file(
          imageToShow,
          fit: BoxFit.contain,
        ),
      );
    }
    
    // Error state
    if (_cameraService.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: MainTheme.redWarning, size: 64),
            const SizedBox(height: 16),
            Text(
              'Camera error: ${_cameraService.errorMessage}',
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('กรุณาลองอีกครั้ง'),
                    backgroundColor: MainTheme.redWarning,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: MainTheme.blueText,
              ),
              child: const Text('ลองอีกครั้ง'),
            ),
          ],
        ),
      );
    }
    
    // Loading state
    if (_isInitializing) {
      return const Center(
        child: CircularProgressIndicator(color: MainTheme.blueText),
      );
    }

    // In-app camera preview with focus frame
    if (_cameraService.controller?.value.isInitialized ?? false) {
      return _buildOptimizedCameraPreview();
    }
    
    // Fallback
    return const Center(
      child: Text(
        'กล้องไม่พร้อมใช้งาน',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildOptimizedCameraPreview() {
    final size = MediaQuery.of(context).size;
    final controller = _cameraService.controller!;
    
    // Calculate the best display approach based on device
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview optimized for full screen
          Center(
            child: AspectRatio(
              aspectRatio: size.aspectRatio,
              child: SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: controller.value.previewSize!.height,
                    height: controller.value.previewSize!.width,
                    child: Stack(
                      children: [
                        // Rotate camera preview if needed
                        Transform.rotate(
                          angle: 0, // Adjust if needed based on device orientation
                          child: CameraPreview(controller),
                        ),
                        
                        // Optional contrast enhancement layer
                        Container(
                          color: Colors.black.withOpacity(0.05), 
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Focus frame
          const Center(
            child: FocusFrame(),
          ),
          
          // Center focus point
          Center(
            child: Container(
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
          ),
        ],
      ),
    );
  }
  
  Future<void> _captureImage() async {
    try {
      // Only use in-app camera from main capture button
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
      
      final image = await _cameraService.takePicture();
      
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาด: $e'),
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

class CameraGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    // Draw grid lines
    canvas.drawLine(Offset(size.width/3, 0), Offset(size.width/3, size.height), paint);
    canvas.drawLine(Offset(2*size.width/3, 0), Offset(2*size.width/3, size.height), paint);
    canvas.drawLine(Offset(0, size.height/3), Offset(size.width, size.height/3), paint);
    canvas.drawLine(Offset(0, 2*size.height/3), Offset(size.width, 2*size.height/3), paint);
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}