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
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => context.go('/settings'),
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

class ManualTutorialSelection extends StatefulWidget {
  const ManualTutorialSelection({super.key});

  @override
  State<ManualTutorialSelection> createState() => _ManualTutorialSelectionScreenState();
}

class _ManualTutorialSelectionScreenState extends State<ManualTutorialSelection> {
  String? selectedCategory;

  void _handleCategorySelection(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

  // Get step number based on selected category
  String _getStepNumber() {
    if (selectedCategory == 'chart') {
      return '2';
    } else if (selectedCategory == 'scan') {
      return '1';
    }
    return '1'; 
  }

  void _handleStartTutorial() {
    if (selectedCategory == 'chart') {
      context.go('/manual-scan-tutorial');
    } else if (selectedCategory == 'scan') {
      context.go('/manual-nearchart-tutorial');
    }
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

                  // First Option: Eye Measurement
                  InkWell(
                    onTap: () => _handleCategorySelection('scan'),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: selectedCategory == 'scan' 
                            ? MainTheme.pinkBackgroundT 
                            : MainTheme.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selectedCategory == 'scan'
                              ? MainTheme.transparent
                              : MainTheme.pinkBorderT,
                              width: 4.0
                        ),
                      ),
                      child: Text(
                        '1. การวัดค่าสายตา',
                        style: TextStyle(
                          color: selectedCategory == 'scan'
                              ? Colors.black
                              : Colors.black,
                          fontSize: 16,
                          fontFamily: 'BaiJamjuree',
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Second Option: Eye Scanning
                  InkWell(
                    onTap: () => _handleCategorySelection('chart'),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: selectedCategory == 'chart'
                            ? MainTheme.blueBackgroundT
                            : MainTheme.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selectedCategory == 'chart'
                              ? MainTheme.transparent
                              : MainTheme.blueBorderT,
                              width: 4.0
                        ),
                      ),
                      child: Text(
                        '2. การสแกนตา',
                        style: TextStyle(
                          color: selectedCategory == 'chart'
                              ? MainTheme.black
                              : MainTheme.black,
                          fontSize: 16,
                          fontFamily: 'BaiJamjuree',
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
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
        padding: const EdgeInsets.all(16.0),
        height: 90, 
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: selectedCategory != null ? _handleStartTutorial : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: MainTheme.buttonBackground,
                  disabledBackgroundColor: MainTheme.grey,
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