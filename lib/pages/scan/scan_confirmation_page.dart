import 'dart:io';
import 'package:flutter/material.dart';
import 'package:client/core/theme/theme.dart';

class ScanConfirmationPage extends StatelessWidget {
  final File imageFile;
  final bool isRightEye;
  final VoidCallback onConfirm;
  final VoidCallback onRetake;
  final VoidCallback onBackPressed;
  
  const ScanConfirmationPage({
    super.key,
    required this.imageFile,
    required this.isRightEye,
    required this.onConfirm,
    required this.onRetake,
    required this.onBackPressed,
  });
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MainTheme.mainBackground,
      body: SafeArea(
        child: Column(
          children: [
            // App bar with back button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      'ยืนยันรูปภาพ',
                      style: TextStyle(
                        color: MainTheme.mainText,
                        fontSize: 18,
                        fontFamily: 'BaiJamjuree',
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Empty container to balance the layout
                  Container(width: 48),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Eye type indicator
            Text(
              isRightEye ? 'รูปตาขวา' : 'รูปตาซ้าย',
              style: const TextStyle(
                color: MainTheme.blueText,
                fontSize: 18,
                fontFamily: 'BaiJamjuree',
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Instructions
            const Text(
              'คุณพอใจกับรูปนี้หรือไม่?',
              style: TextStyle(
                color: MainTheme.mainText,
                fontSize: 16,
                fontFamily: 'BaiJamjuree',
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Image preview
            Expanded(
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    imageFile,
                    fit: BoxFit.contain,
                    width: 300,
                    height: 300,
                  ),
                ),
              ),
            ),
            
            // Action buttons
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Retake button
                  Expanded(
                    child: TextButton(
                      onPressed: onRetake,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: MainTheme.redWarning),
                        ),
                      ),
                      child: const Text(
                        'ถ่ายใหม่',
                        style: TextStyle(
                          color: MainTheme.redWarning,
                          fontSize: 16,
                          fontFamily: 'BaiJamjuree',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Confirm button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MainTheme.blueText,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'ยืนยัน',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'BaiJamjuree',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}