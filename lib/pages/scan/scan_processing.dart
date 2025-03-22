// lib/pages/scan/scan_processing.dart
import 'package:flutter/material.dart';
import 'package:client/core/theme/theme.dart';

class ScanProcessingPage extends StatelessWidget {
  final VoidCallback onBackPressed;
  
  const ScanProcessingPage({super.key, required this.onBackPressed});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MainTheme.mainBackground,
      appBar: AppBar(
        title: const Text('กำลังวิเคราะห์ภาพ'),
        backgroundColor: MainTheme.mainBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: MainTheme.mainText,
            size: 22,
          ),
          onPressed: onBackPressed,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Eye analysis image/icon
            Image.asset(
              'assets/images/MongtaLogo.png',
              width: 150,
              height: 150,
            ),
            
            const SizedBox(height: 30),
            
            const Text(
              'กำลังวิเคราะห์ภาพของคุณ',
              style: TextStyle(
                color: MainTheme.mainText,
                fontSize: 20,
                fontFamily: 'BaiJamjuree',
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'กรุณารอสักครู่ ระบบกำลังวิเคราะห์ภาพ',
                style: TextStyle(
                  color: MainTheme.mainText,
                  fontSize: 16,
                  fontFamily: 'BaiJamjuree',
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 40),
            
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(MainTheme.blueText),
              strokeWidth: 4, 
            ),
            
            const SizedBox(height: 16),
            
            const Text(
              'อาจใช้เวลาเพียงสักครู่เท่านั้น',
              style: TextStyle(
                color: MainTheme.placeholderText,
                fontSize: 14,
                fontFamily: 'BaiJamjuree',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}