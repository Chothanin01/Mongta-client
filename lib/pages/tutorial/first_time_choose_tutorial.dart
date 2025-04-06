import 'package:flutter/material.dart';
import 'package:client/core/theme/theme.dart';
import 'package:go_router/go_router.dart';

class TutorialBackButton extends StatelessWidget {
  const TutorialBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8,
      left: 16,
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new),
        onPressed: () => context.go('/home'),
      ),
    );
  }
}

class SELogo extends StatelessWidget {
  const SELogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 20,
      right: 16,
      child: Image.asset(
        'assets/images/SE_logo 3.png',
        width: 55,
        height: 57,
      ),
    );
  }
}

class TutorialSelection extends StatefulWidget {
  const TutorialSelection({super.key});

  @override
  State<TutorialSelection> createState() => _TutorialSelectionScreenState();
}

class _TutorialSelectionScreenState extends State<TutorialSelection> {
  // Fixed selection - no longer changeable
  final String selectedCategory = 'scan';

  String _getStepNumber() {
    return '1'; 
  }

  // Navigate to near chart tutorial
  void _handleStartTutorial() {
    context.go('/nearchart-tutorial');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MainTheme.mainBackground,
      body: SafeArea(
        child: Stack(
          children: [
            
            // Separated 
            const TutorialBackButton(), 
            const SELogo(), 
            
            // Main Content Container
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 80), 
                  
                  // Title Section
                  const Text(
                    'หลักการสแกนตา',
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'BaiJamjuree',
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),

                  Text(
                    'ขั้นตอนที่ ${_getStepNumber()}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'BaiJamjuree',
                      fontWeight: FontWeight.w500,
                      color: MainTheme.black,
                    ),
                  ),
                  
                  const SizedBox(height: 40),

                  // First Option: Eye Measurement - Now Container instead of InkWell
                  Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: MainTheme.pinkBackgroundT, 
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: MainTheme.transparent,
                        width: 4.0
                      ),
                    ),
                    child: const Text(
                      '1. การวัดค่าสายตา',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'BaiJamjuree',
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Second Option: Eye Scanning 
                  Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: MainTheme.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: MainTheme.blueBorderT,
                        width: 4.0
                      ),
                    ),
                    child: const Text(
                      '2. การสแกนตา',
                      style: TextStyle(
                        color: MainTheme.black,
                        fontSize: 16,
                        fontFamily: 'BaiJamjuree',
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      
      // Bottom Action Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 16.0,
          bottom: 32.0, 
        ),
        height: 106, 
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: _handleStartTutorial,
                style: ElevatedButton.styleFrom(
                  backgroundColor: MainTheme.buttonBackground,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'เริ่มต้นการสอนใช้งาน',
                  style: TextStyle(
                    color: MainTheme.white,
                    fontSize: 18,
                    fontFamily: 'BaiJamjuree',
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}