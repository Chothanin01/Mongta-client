import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:client/core/theme/theme.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eye Scanner',
      theme: ThemeData(
        primaryColor: MainTheme.blueText,
        scaffoldBackgroundColor: MainTheme.mainBackground,
        fontFamily: 'BaiJamjuree',
      ),
      home: const ScanPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ScanPage extends StatefulWidget {
  const ScanPage({Key? key}) : super(key: key);

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isRightEye = true; // Start with right eye

  Future<void> _getImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        preferredCameraDevice: CameraDevice.front,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        
        // Process image or navigate to results
        if (!mounted) return;
        
        // If capturing right eye, switch to left eye
        if (_isRightEye) {
          setState(() {
            _isRightEye = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('บันทึกภาพตาขวาสำเร็จ กรุณาถ่ายภาพตาซ้าย'),
              backgroundColor: MainTheme.blueText,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          // Both eyes captured, navigate to results
          context.push('/scan_result');
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาด: $e'),
          backgroundColor: MainTheme.redWarning,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Using transparent background for the scaffold
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content area
            Column(
              children: [
                // Top bar showing which eye to scan - now with transparent background
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  width: double.infinity,
                  color: Colors.transparent, // Changed to transparent
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: MainTheme.buttonScanBackground,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'ตาข้าง${_isRightEye ? 'ขวา' : 'ซ้าย'}',
                        style: const TextStyle(
                          color: MainTheme.white,
                          fontFamily: 'BaiJamjuree',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Camera preview / image area with bounding box (transparent background)
                Expanded(
                  child: Container(
                    // Transparent background
                    color: Colors.transparent,
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // This would be your camera preview or selected image
                          _selectedImage != null
                              ? Image.file(
                                  _selectedImage!,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  // Transparent background for placeholder
                                  color: Colors.transparent,
                                ),
                          
                          // BOUNDING BOX CUSTOMIZATION
                          // You can modify the bounding box by changing:
                          // 1. width/height - adjust the size of the box
                          // 2. border.all - change color, width, or style (solid, dashed)
                          // 3. borderRadius - add circular corners for oval/circular shape
                          // 4. boxShadow - add shadow effects around the box
                          // Example for circular: borderRadius: BorderRadius.circular(100)
                          Container(
                            width: 200, // Change size as needed
                            height: 200, // Change size as needed
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: MainTheme.blueText, // Change color as needed
                                width: 2.0, // Change thickness as needed
                                // style: BorderStyle.solid, // Can use solid or none
                              ),
                              // For circular box, add: borderRadius: BorderRadius.circular(100)
                              // For rounded rectangle: borderRadius: BorderRadius.circular(20)
                            ),
                          ),
                          
                          // Corner markers can be customized in the _buildCornerMarker method
                          SizedBox(
                            width: 220,
                            height: 220,
                            child: Stack(
                              children: [
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  child: _buildCornerMarker(false, false),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: _buildCornerMarker(false, true),
                                ),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  child: _buildCornerMarker(true, false),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: _buildCornerMarker(true, true),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Bottom section with only capture button (centered)
                Container(
                  padding: const EdgeInsets.only(bottom: 30),
                  color: Colors.transparent,
                  child: Center(
                    child: GestureDetector(
                      onTap: () => _getImage(ImageSource.camera),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: MainTheme.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: MainTheme.blueText, width: 3),
                        ),
                        child: Center(
                          child: Container(
                            width: 50,
                            height: 50,
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
            
            // Back button - now with black color
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black, // Changed to black
                  size: 22,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            
            // Gallery button - positioned separately at bottom right
            Positioned(
              bottom: 30,
              right: 32,
              child: GestureDetector(
                onTap: () => _getImage(ImageSource.gallery),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: MainTheme.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: MainTheme.textfieldBorder, width: 1.5),
                  ),
                  child: const Icon(
                    Icons.photo_library,
                    color: MainTheme.textfieldBorder,
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
  
  // Helper method to build corner markers
  // To customize corner markers:
  // 1. Change width/height for size
  // 2. Change colors and border widths
  // 3. Modify the shape using different BoxDecoration properties
  Widget _buildCornerMarker(bool isBottom, bool isRight) {
    return Container(
      width: 20, // Size of corner marker
      height: 20, // Size of corner marker
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isBottom ? Colors.transparent : MainTheme.blueText,
            width: 2, // Thickness of marker
          ),
          bottom: BorderSide(
            color: isBottom ? MainTheme.blueText : Colors.transparent,
            width: 2, // Thickness of marker
          ),
          left: BorderSide(
            color: isRight ? Colors.transparent : MainTheme.blueText,
            width: 2, // Thickness of marker
          ),
          right: BorderSide(
            color: isRight ? MainTheme.blueText : Colors.transparent,
            width: 2, // Thickness of marker
          ),
        ),
      ),
    );
  }
}