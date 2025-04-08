import 'dart:io';
 import 'package:camera/camera.dart';
 import 'package:flutter/material.dart';
 import 'package:flutter/services.dart';
 import 'package:client/core/theme/theme.dart';
 import 'package:client/services/camera_service.dart';
 import 'package:client/services/image_capture_service.dart';
 import 'package:client/main.dart'; // Add this import for lifecycleObserver
 
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
   bool _forceMockCamera = false;
 
   @override
   void initState() {
     super.initState();
     WidgetsBinding.instance.addObserver(this);
     lifecycleObserver.setMediaPickerActive();
 
     // Lock to portrait mode for consistent camera experience
     SystemChrome.setPreferredOrientations([
       DeviceOrientation.portraitUp,
     ]);
 
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
     // Reset orientation when leaving
     SystemChrome.setPreferredOrientations([
       DeviceOrientation.portraitUp,
       DeviceOrientation.portraitDown,
       DeviceOrientation.landscapeLeft,
       DeviceOrientation.landscapeRight,
     ]);
 
     lifecycleObserver.setMediaPickerInactive();
     WidgetsBinding.instance.removeObserver(this);
     _cameraService.dispose();
     super.dispose();
   }
 
   @override
   Widget build(BuildContext context) {
     // Force the selected eye based on what's already captured
     if (widget.rightEyeImage != null && _isRightEyeSelected) {
       // Right eye already captured, switch to left
       setState(() {
         _isRightEyeSelected = false;
       });
     }
 
     return Scaffold(
       // Remove the background color entirely
       backgroundColor: Colors.black,
       body: Stack(
         children: [
           // Camera preview first (full screen)
           _buildFullScreenCameraPreview(),
 
           // SafeArea for UI controls
           SafeArea(
             child: Column(
               children: [
                 // Top segmented control for eye selection (keep as is)
                 Container(
                   padding: const EdgeInsets.symmetric(vertical: 16),
                   width: double.infinity,
                   // Make background transparent
                   color: Colors.transparent,
                   child: Center(
                     child: Container(
                       width: 280,
                       height: 44,
                       decoration: BoxDecoration(
                         color: Colors.white.withOpacity(0.85), // Semi-transparent background
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
 
                 // Spacer to push capture button to bottom
                 Spacer(),
 
                 // Bottom section with capture button
                 Container(
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
                               width: 3),
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
 
   Widget _buildFullScreenCameraPreview() {
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
     if (_cameraService.errorMessage != null || _errorMessage != null) {
       // Your existing error handling code
       return Container(
         width: double.infinity,
         height: double.infinity,
         color: Colors.black,
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             const Icon(Icons.error_outline, color: MainTheme.redWarning, size: 64),
             const SizedBox(height: 16),
             Text(
               _cameraService.errorMessage ?? _errorMessage!,
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
         ),
       );
     }
 
     if (_isCameraInitializing) {
       // Your existing loading code
       return Container(
         width: double.infinity,
         height: double.infinity,
         color: Colors.black,
         child: const Center(
           child: CircularProgressIndicator(color: MainTheme.blueText),
         ),
       );
     }
 
     // Full-screen camera approach that works on all devices
     return Stack(
       children: [
         // Black background with camera frame
         Container(
           width: double.infinity,
           height: double.infinity,
           color: Colors.black,
         ),
 
         // Optional: camera grid lines or frame guides
         CustomPaint(
           size: Size.infinite,
           painter: CameraFramePainter(),
         ),
 
         // Your existing focus frame
         Center(
           child: _buildFocusFrame(),
         ),
 
       ],
     );
   }
 
   Widget _buildFocusFrame() {
     return Container(
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
 
           // Focus point indicator
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
     try {
       final File? image = await _imageService.captureImageFromCamera();
       if (image != null) {
         widget.onImageCaptured(image, _isRightEyeSelected);
       }
     } catch (e) {
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
 
 // Add this helper class for the camera grid/frame
 class CameraFramePainter extends CustomPainter {
   @override
   void paint(Canvas canvas, Size size) {
     final paint = Paint()
       ..color = Colors.white.withOpacity(0.3)
       ..strokeWidth = 1
       ..style = PaintingStyle.stroke;
 
     // Draw grid lines or guide frames if desired
     // Example: draw rule-of-thirds grid
     canvas.drawLine(Offset(size.width / 3, 0), Offset(size.width / 3, size.height), paint);
     canvas.drawLine(Offset(2 * size.width / 3, 0), Offset(2 * size.width / 3, size.height), paint);
     canvas.drawLine(Offset(0, size.height / 3), Offset(size.width, size.height / 3), paint);
     canvas.drawLine(Offset(0, 2 * size.height / 3), Offset(size.width, 2 * size.height / 3), paint);
   }
 
   @override
   bool shouldRepaint(CustomPainter oldDelegate) => false;
 }