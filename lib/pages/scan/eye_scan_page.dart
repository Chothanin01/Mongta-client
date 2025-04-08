import 'dart:io';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:client/core/theme/theme.dart';
import 'package:client/services/camera_service.dart';
import 'package:client/services/image_capture_service.dart';
import 'package:client/main.dart';
import 'package:flutter/services.dart';


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
  int _initAttempts = 0;
  bool _forceMockCamera = false;

  // Camera state variables
  DeviceOrientation _lastKnownOrientation = DeviceOrientation.portraitUp;
  Size? _previewSize;
  Size? _screenSize;
  double _cameraScale = 1.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    lifecycleObserver.setMediaPickerActive();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    setState(() {
      _isCameraInitializing = true;
      _errorMessage = null;
    });

    try {
      // Increment attempt counter
      _initAttempts++;

      // Get screen dimensions to help with aspect ratio calculations
      final width = MediaQuery.of(context).size.width;
      final height = MediaQuery.of(context).size.height;
      _screenSize = Size(width, height);

      // Check if we should use mock camera after multiple failures
      if (_initAttempts > 3) {
        _forceMockCamera = true;
        _cameraService.enableMockCamera();
        setState(() {
          _isCameraInitializing = false;
        });
        return;
      }

      // Use a timeout to prevent hanging
      await _cameraService.initializeService().timeout(
        Duration(seconds: 5),
        onTimeout: () {
          throw TimeoutException('Camera initialization timed out');
        },
      );

      // If successful, get preview size and calculate scale
      if (_cameraService.controller?.value.isInitialized ?? false) {
        final previewSize = _cameraService.controller!.value.previewSize;
        if (previewSize != null) {
          _previewSize = previewSize;
          _calculateCameraScale();
        }
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
      if (mounted) { // Add mounted check
        setState(() {
          _errorMessage = 'ไม่สามารถเข้าถึงกล้องได้: ${e.toString().split(':').first}';
        });
      }

      // Auto retry with exponential backoff
      if (_initAttempts < 3) {
        Future.delayed(Duration(milliseconds: 500 * _initAttempts), () {
          if (mounted) _initializeCamera();
        });
      } else {
        // Fall back to mock camera after repeated failures
        _forceMockCamera = true;
        _cameraService.enableMockCamera();
      }
    } finally {
      if (mounted) { // Add mounted check
        setState(() {
          _isCameraInitializing = false;
        });
      }
    }
  }

  // Calculate camera scale to maintain aspect ratio
  void _calculateCameraScale() {
    if (_previewSize == null || _screenSize == null) return;

    final previewRatio = _previewSize!.width / _previewSize!.height;
    final screenRatio = _screenSize!.width / _screenSize!.height;

    // Calculate scale to fit the preview correctly
    if (previewRatio > screenRatio) {
      // Wide camera aspect ratio, scale to fit height
      _cameraScale = _screenSize!.width / (_screenSize!.height * previewRatio);
    } else {
      // Tall camera aspect ratio, scale to fit width
      _cameraScale = (_screenSize!.width * previewRatio) / _screenSize!.height;
    }

    setState(() {});
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
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Update screen size when dependencies change
    final newSize = MediaQuery.of(context).size;
    if (_screenSize == null || _screenSize!.width != newSize.width || _screenSize!.height != newSize.height) {
      _screenSize = newSize;
      _calculateCameraScale();
    }
  }

  @override
  void dispose() {
    lifecycleObserver.setMediaPickerInactive();
    WidgetsBinding.instance.removeObserver(this);
    _cameraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if right eye is already captured and auto-switch to left
    if (widget.rightEyeImage != null && _isRightEyeSelected) {
      setState(() {
        _isRightEyeSelected = false;
      });
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview with adaptive layout
          _buildAdaptiveCameraPreview(),

          // SafeArea for UI controls
          SafeArea(
            child: Column(
              children: [
                // Top segmented control for eye selection
                _buildEyeSelectionControls(),

                // Spacer to push capture button to bottom
                Spacer(),

                // Bottom section with capture button
                _buildCaptureControls(),
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
              onTap: _isCameraInitializing ? null : _pickImageFromGallery,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: MainTheme.white.withOpacity(0.85),
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
    );
  }

  Widget _buildEyeSelectionControls() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      width: double.infinity,
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: 280,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: MainTheme.blueText, width: 1),
          ),
          child: Row(
            children: [
              // Right Eye Tab
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
    );
  }

  Widget _buildCaptureControls() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30),
      color: Colors.transparent,
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
              color: MainTheme.white,
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
                            color: MainTheme.blueText,
                            shape: BoxShape.circle,
                          ),
                        ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdaptiveCameraPreview() {
    // If images are already captured, show them
    if ((_isRightEyeSelected && widget.rightEyeImage != null) || 
        (!_isRightEyeSelected && widget.leftEyeImage != null)) {
      final File imageToShow = _isRightEyeSelected 
          ? widget.rightEyeImage! 
          : widget.leftEyeImage!;

      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              imageToShow,
              fit: BoxFit.contain,
            ),
          ),
        ),
      );
    }

    // Handle error states
    if (_errorMessage != null || _cameraService.errorMessage != null) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: MainTheme.redWarning, size: 64),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                _errorMessage ?? _cameraService.errorMessage ?? 'กล้องไม่พร้อมใช้งาน',
                style: const TextStyle(
                  color: MainTheme.redWarning,
                  fontFamily: 'BaiJamjuree',
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            if (!_forceMockCamera)
              ElevatedButton(
                onPressed: () {
                  _forceMockCamera = true;
                  _cameraService.enableMockCamera();
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: MainTheme.blueText,
                ),
                child: const Text('ใช้กล้องจำลองแทน', style: TextStyle(fontFamily: 'BaiJamjuree')),
              ),
          ],
        ),
      );
    }

    if (_isCameraInitializing) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: MainTheme.blueText),
              SizedBox(height: 16),
              Text(
                'กำลังเปิดกล้อง...',
                style: TextStyle(color: Colors.white, fontFamily: 'BaiJamjuree'),
              ),
            ],
          ),
        ),
      );
    }

    // Full-screen camera preview with focus frame overlay
    if (_cameraService.controller?.value.isInitialized ?? false) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Adaptive camera preview with transform to handle different aspect ratios
            ClipRect(
              child: Transform.scale(
                scale: _cameraScale,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1 / _cameraService.controller!.value.aspectRatio,
                    child: CameraPreview(_cameraService.controller!),
                  ),
                ),
              ),
            ),

            // Semi-transparent scrim for better contrast
            Container(
              color: Colors.black.withOpacity(0.2),
            ),

            // Centered focus frame
            Center(
              child: _buildFocusFrame(),
            ),
          ],
        ),
      );
    }

    // Fallback if camera isn't initialized
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: const Center(
        child: Text(
          'กล้องไม่พร้อมใช้งาน',
          style: TextStyle(color: Colors.white, fontFamily: 'BaiJamjuree'),
        ),
      ),
    );
  }

  // Improved focus frame with adaptive sizing
  Widget _buildFocusFrame() {
    // Determine optimal focus frame size based on screen dimensions
    final screenSize = MediaQuery.of(context).size;
    final smallerDimension = math.min(screenSize.width, screenSize.height);
    final frameSize = smallerDimension * 0.65; // Use 65% of the smaller dimension

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Eye type indicator text
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        SizedBox(height: 20),

        // Focus frame with corners
        Container(
          width: frameSize,
          height: frameSize,
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
        ),

      ],
    );
  }

  Future<void> _captureImage() async {
    if (_cameraService.controller == null ||
        !_cameraService.controller!.value.isInitialized && !_forceMockCamera) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กล้องไม่พร้อมใช้งาน'),
          backgroundColor: MainTheme.redWarning,
        ),
      );
      return;
    }

    // Show loading indicator
    setState(() {
      _isCameraInitializing = true;
    });

    try {
      final File? image = await _cameraService.takePicture();
      
      if (mounted) { // Add mounted check here
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
    } catch (e) {
      debugPrint('Error taking picture: $e');
      if (mounted) { // Add mounted check here
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('เกิดข้อผิดพลาดในการถ่ายภาพ กรุณาลองอีกครั้ง'),
            backgroundColor: MainTheme.redWarning,
          ),
        );
      }
    } finally {
      if (mounted) { // Add mounted check here
        setState(() {
          _isCameraInitializing = false;
        });
      }
    }
  }

  void _retakeCurrentImage() {
    widget.onImageCaptured(File(''), _isRightEyeSelected);
  }

  Future<void> _pickImageFromGallery() async {
    try {
      setState(() {
        _isCameraInitializing = true;
      });
      
      final File? image = await _imageService.pickImageFromGallery();
      
      if (mounted) { // Add mounted check here
        if (image != null) {
          widget.onImageCaptured(image, _isRightEyeSelected);
        }
      }
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      if (mounted) { // Add mounted check here
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ไม่สามารถเลือกรูปภาพได้ กรุณาลองอีกครั้ง'),
            backgroundColor: MainTheme.redWarning,
          ),
        );
      }
    } finally {
      if (mounted) { // Add mounted check here
        setState(() {
          _isCameraInitializing = false;
        });
      }
    }
  }
}

// Add this exception class
class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => message;
}