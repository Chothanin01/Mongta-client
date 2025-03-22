import 'package:flutter/material.dart';
import 'package:client/core/theme/theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';

class ScanResultPage extends StatelessWidget {
  final Map<String, dynamic> scanResult;
  final VoidCallback onBackPressed;
  final VoidCallback onNewScan;

  const ScanResultPage({
    super.key,
    required this.scanResult,
    required this.onBackPressed,
    required this.onNewScan,
  });

  // Add this method to extract image URLs regardless of format
  Map<String, dynamic> _extractPhotoData(Map<String, dynamic> data) {
    // Debug the incoming structure
    debugPrint('Extracting photo from: ${jsonEncode(data)}');
    
    // Try all possible paths to photo data
    if (data.containsKey('photo')) {
      return data['photo'] is String 
          ? jsonDecode(data['photo']) 
          : (data['photo'] ?? {});
    } else if (data.containsKey('scanlog') && data['scanlog'] is Map) {
      final scanlog = data['scanlog'] as Map<String, dynamic>;
      if (scanlog.containsKey('photo')) {
        return scanlog['photo'] is String
            ? jsonDecode(scanlog['photo'])
            : (scanlog['photo'] ?? {});
      }
    }
    
    // Return empty map if no photo data found
    return {};
  }

  @override
  Widget build(BuildContext context) {
    // Debug the entire scan result
    debugPrint('FULL SCAN RESULT: ${jsonEncode(scanResult)}');
    
    // Extract photo data
    final photoData = _extractPhotoData(scanResult);
    debugPrint('EXTRACTED PHOTO DATA: ${jsonEncode(photoData)}');
    
    final String? rightEyeUrl = photoData['right_eye'];
    final String? leftEyeUrl = photoData['left_eye'];
    final String? rightAiUrl = photoData['ai_right'];
    final String? leftAiUrl = photoData['ai_left'];
    
    // Debug all URLs
    debugPrint('RIGHT EYE URL: $rightEyeUrl');
    debugPrint('LEFT EYE URL: $leftEyeUrl');
    debugPrint('RIGHT AI URL: $rightAiUrl');
    debugPrint('LEFT AI URL: $leftAiUrl');
    
    // Get VA data
    final Map<String, dynamic> va = scanResult['va'] is String
        ? jsonDecode(scanResult['va'])
        : (scanResult['va'] ?? {});
        
    // Extract diagnoses from the appropriate properties
    // First try direct access of descriptions, fall back to scanlog if needed
    String rightEyeDescription = scanResult['description_right'] ?? '';
    String leftEyeDescription = scanResult['description_left'] ?? '';
    
    // If descriptions are not at the top level, check scanlog object
    if ((rightEyeDescription.isEmpty || leftEyeDescription.isEmpty) && 
        scanResult.containsKey('scanlog') && scanResult['scanlog'] is Map) {
      final scanlogData = scanResult['scanlog'] as Map<String, dynamic>;
      rightEyeDescription = scanlogData['description_right'] ?? 'ไม่พบข้อมูล';
      leftEyeDescription = scanlogData['description_left'] ?? 'ไม่พบข้อมูล';
    }
    
    // If still empty, use default
    if (rightEyeDescription.isEmpty) rightEyeDescription = 'ไม่พบข้อมูลดวงตาขวา';
    if (leftEyeDescription.isEmpty) leftEyeDescription = 'ไม่พบข้อมูลดวงตาซ้าย';

    return Scaffold(
      backgroundColor: MainTheme.mainBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App bar
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: MainTheme.mainText,
                          size: 22,
                        ),
                        onPressed: onBackPressed,
                      ),
                      const Expanded(
                        child: Text(
                          'ผลการสแกนดวงตา',
                          style: TextStyle(
                            color: MainTheme.mainText,
                            fontSize: 18,
                            fontFamily: 'BaiJamjuree',
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // Placeholder to balance layout
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Right Eye Results - removed risk level
                _buildEyeSection(
                  context,
                  rightEyeUrl,
                  rightAiUrl,
                  'การสแกนดวงตาขวา',
                  rightEyeDescription,
                ),

                const SizedBox(height: 30),

                // Left Eye Results - removed risk level
                _buildEyeSection(
                  context,
                  leftEyeUrl,
                  leftAiUrl,
                  'การสแกนดวงตาซ้าย',
                  leftEyeDescription,
                ),

                const SizedBox(height: 30),

                // Action buttons
                Row(
                  children: [
                    // Changed: Go home button (was Consult doctor)
                    Expanded(
                      child: _buildCustomButton(
                        context: context,
                        onTap: () {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                          context.go('/home');
                        },
                        icon: Icons.home,
                        title: 'หน้าโฮมเพจ',
                        subtitle: 'กลับสู่หน้าแรก',
                        isBlueButton: false,
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Changed: View scan history button (was New scan)
                    Expanded(
                      child: _buildCustomButton(
                        context: context,
                        onTap: () {
                          context.go('/scanlog');
                        },
                        icon: Icons.history,
                        title: 'ผลการสแกน',
                        subtitle: 'เข้าไปดูประวัติ',
                        isBlueButton: true,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Updated _buildEyeSection with centered text and conditional color
  Widget _buildEyeSection(
    BuildContext context,
    String? originalImageUrl,
    String? aiImageUrl,
    String title,
    String diagnosis,
  ) {
    // Determine text color based on the diagnosis content
    final Color diagnosisColor = 
        diagnosis.contains("ยังไม่พบเจอสิ่งผิดปกติ") || 
        diagnosis.contains("การสเเกนดวงตาซ้ายยังไม่พบเจอสิ่งผิดปกติ") || 
        diagnosis.contains("การสเเกนดวงตาขวายังไม่พบเจอสิ่งผิดปกติ")
            ? MainTheme.greenComplete // Green for normal results
            : const Color(0xFFE57373); // Light red for abnormal results

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MainTheme.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        // Changed to center alignment for the whole section
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: MainTheme.mainText,
              fontSize: 16,
              fontFamily: 'BaiJamjuree',
              fontWeight: FontWeight.w600,
            ),
            // Center the title text
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Images row
          Row(
            children: [
              // Original Image
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'รูปต้นฉบับ',
                        style: TextStyle(
                        color: MainTheme.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'BaiJamjuree',
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    _buildImageWidget(
                      context,
                      originalImageUrl, 
                      width: 140, 
                      height: 140, 
                      borderRadius: 8
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // AI-Processed Image section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'รูปวิเคราะห์ AI',
                      style: TextStyle(
                        color: MainTheme.black,  
                        fontSize: 12,
                        fontWeight: FontWeight.w500,                     
                        fontFamily: 'BaiJamjuree',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    _buildImageWidget(
                      context,
                      aiImageUrl,
                      width: 140,
                      height: 140,
                      borderRadius: 8
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Show only diagnosis, without risk level
          const SizedBox(height: 16),
          
          // Updated diagnosis text with conditional styling and centered
          Container(
            width: double.infinity, // Full width for better centering
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: diagnosisColor.withOpacity(0.1), // Light background based on diagnosis
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              diagnosis,
              style: TextStyle(
                color: diagnosisColor, // Dynamic text color
                fontSize: 14,
                fontFamily: 'BaiJamjuree',
                height: 1.4,
                fontWeight: FontWeight.w500, // Slightly bolder
              ),
              textAlign: TextAlign.center, // Center the text
            ),
          ),
        ],
      ),
    );
  }

  // Updated _buildImageWidget method to add tap to view fullscreen
  Widget _buildImageWidget(
    BuildContext context, // Add context parameter
    String? imageUrl, {
    required double width,
    required double height,
    required double borderRadius,
  }) {
    // Debug the actual URL being used
    debugPrint('Attempting to load image from: $imageUrl');
    
    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildPlaceholderWidget(width, height, borderRadius);
    }

    // Add tap to view fullscreen
    return GestureDetector(
      onTap: () {
        // Open fullscreen image viewer when tapped
        if (imageUrl.isNotEmpty) {
          Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (context) => FullscreenImageViewer(imageUrl: imageUrl),
            ),
          );
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: width,
          height: height,
          fit: BoxFit.cover,
          // Add caching key to prevent conflicts
          cacheKey: imageUrl.split('/').last,
          // Add Firebase Storage specific headers
          httpHeaders: {
            'Accept': 'image/jpeg, image/png, image/*',
            'Cache-Control': 'max-age=86400', // 24 hours cache
          },
          // Better placeholder
          placeholder: (context, url) => Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          // Better error handling with fallback
          errorWidget: (context, url, error) {
            debugPrint('Error loading image from $url: $error');
            
            // Try an alternative URL format for Firebase Storage
            final String altUrl = url.replaceFirst(
              'https://storage.googleapis.com/mongta-66831.firebasestorage.app/',
              'https://firebasestorage.googleapis.com/v0/b/mongta-66831/o/'
            ) + '?alt=media';
            
            debugPrint('Trying alternative URL: $altUrl');
            
            return CachedNetworkImage(
              imageUrl: altUrl,
              width: width,
              height: height,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: width,
                height: height,
                color: Colors.grey[200],
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (context, url, error) {
                debugPrint('Alternative URL also failed: $error');
                return _buildErrorPlaceholder(width, height);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlaceholderWidget(double width, double height, double borderRadius) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: const Center(
        child: Icon(Icons.image_not_supported, color: Colors.grey),
      ),
    );
  }

  Widget _buildErrorPlaceholder(double width, double height) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.error_outline, color: Colors.red),
      ),
    );
  }

  Widget _buildCustomButton({
    required BuildContext context,
    required VoidCallback onTap,
    IconData? icon,
    String? imagePath,
    required String title,
    required String subtitle,
    required bool isBlueButton,
  }) {
    return Container(
      width: double.infinity,
      height: 80,
      decoration: BoxDecoration(
        color: isBlueButton ? MainTheme.blueText : MainTheme.white,
        borderRadius: BorderRadius.circular(10),
        border: isBlueButton
            ? null
            : Border.all(color: MainTheme.textfieldBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Icon or Image
                if (icon != null)
                  Icon(
                    icon,
                    size: 24,
                    color: isBlueButton ? Colors.white : MainTheme.blueText,
                  )
                else if (imagePath != null)
                  Image.asset(
                    imagePath,
                    width: 24,
                    height: 24,
                  ),
                  
                const SizedBox(width: 12),
                
                // Text content
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: isBlueButton ? MainTheme.white : MainTheme.mainText,
                          fontSize: 16,
                          fontFamily: 'BaiJamjuree',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      
                      const SizedBox(height: 4),
                      
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: isBlueButton 
                              ? MainTheme.white
                              : MainTheme.mainText,
                          fontSize: 12,
                          fontFamily: 'BaiJamjuree',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Add this new widget for fullscreen image viewing
class FullscreenImageViewer extends StatelessWidget {
  final String imageUrl;
  
  const FullscreenImageViewer({super.key, required this.imageUrl});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 3.0,
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.contain,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            errorWidget: (context, url, error) => const Center(
              child: Icon(Icons.error_outline, color: Colors.red, size: 50),
            ),
          ),
        ),
      ),
    );
  }
}