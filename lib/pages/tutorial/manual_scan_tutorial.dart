import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:client/core/components/tutorial/t_scan_button.dart';
import 'package:client/core/components/tutorial/custom_step_indicator.dart';
import 'package:client/core/theme/theme.dart';

class TutorialPageData {
  final String step;
  final String title;
  final String? subtitle;
  final String? redText;
  final String? blackText;
  final String? imagePath;

  TutorialPageData({
    required this.step,
    required this.title,
    this.subtitle,
    this.redText,
    this.blackText,
    this.imagePath,
  });
}

class ManualScanTutorial extends StatefulWidget {
  const ManualScanTutorial({super.key});

  @override
  State<ManualScanTutorial> createState() => _ManualScanTutorialState();
}

class _ManualScanTutorialState extends State<ManualScanTutorial> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<TutorialPageData> _pages = [
    TutorialPageData(
      step: "1",
      title: "ขั้นตอนการใช้งาน",
      subtitle: "การสเเกนตา",
      redText: "วางตาให้ตรงกรอบของหน้าจอที่วางไว้\nทีละข้างโดย",
      blackText: "เริ่มจากข้างขวาไปซ้าย",
      imagePath: 'assets/images/scan_tutorial_1.png',
    ),
    TutorialPageData(
      step: "2",
      title: "ขั้นตอนการใช้งาน",
      subtitle: "การสเเกนตา",
      blackText: "ถอดแว่นตาและใช้ตาเปล่า\nแล้ววางตาตรงกับกรอบเเล้ว\nให้มองกล้องของโทรศัพท์เเล้วกดปุ่มถ่ายรูป",
      imagePath: 'assets/images/scan_tutorial_2.png',
    ),
    TutorialPageData(
      step: "3",
      title: "ขั้นตอนการใช้งาน",
      subtitle: "การสเเกนตา",
      blackText: "เมื่อพอใจกับภาพ สามารถกดยืนยันได้เลย \nเเต่ถ้าไม่พอใจให้กดถ่ายอีกรอบ",
      imagePath: 'assets/images/scan_tutorial_3.png',
    ),
  ];

  void _nextPage() {
    if (_currentIndex < _pages.length - 1) {
      _controller.nextPage(
          duration: Duration(milliseconds: 500), curve: Curves.ease);
    } else {
      context.go('/manual-tutorial-selection');
    }
  }

  void _previousPage() {
    if (_currentIndex > 0) {
      _controller.previousPage(
          duration: Duration(milliseconds: 500), curve: Curves.ease);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MainTheme.mainBackground,
      body: SafeArea(
        child: Stack(
          children: [
          Positioned(
            top: 8,
            left: 16,
            child: _currentIndex > 0
              ? IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: _previousPage,
                )
              : SizedBox(width: 48),
          ),

          // Main Content Column
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Center(
                  child: CustomStepIndicator(
                    controller: _controller,
                    count: _pages.length,
                    activeColor: MainTheme.activeDot,
                    inactiveColor: MainTheme.activeDot,
                  ),
                ),
              ),
            
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return OnboardingPage(pageData: _pages[index]);
                },
              ),
            ),
            
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    height: 120, 
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.end, 
                      children: [
                        ScanTutorialButton(
                          onTap: _nextPage,
                          buttonText: _currentIndex == _pages.length - 1
                              ? "เสร็จสิ้น"
                              : "ต่อไป",
                        ),
                        SizedBox(
                          height: 48, 
                          child: _currentIndex == 0
                              ? TextButton(
                                  onPressed: () => context.go('/manual-tutorial-selection'),
                                  child: Text(
                                    'ข้ามการสอนใช้งาน',
                                    style: TextStyle(
                                      color: MainTheme.textfieldFocus,
                                      fontSize: 18,
                                      fontFamily: 'BaiJamjuree',
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                )
                              : const SizedBox
                                  .shrink(), 
                        ),
                      ],
                    ),
                  ),
                )
          ],
        ),
          ],
      ),
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final TutorialPageData pageData;

  const OnboardingPage({super.key, required this.pageData});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 32),
              Text(
                pageData.title,
                style: TextStyle(
                  color: MainTheme.mainText,
                  fontSize: 24,
                  fontFamily: 'BaiJamjuree',
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                ),
              ),
              if (pageData.subtitle != null)
                Text(
                  pageData.subtitle!,
                  style: TextStyle(
                    color: MainTheme.mainText,
                    fontSize: 16,
                    fontFamily: 'BaiJamjuree',
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.5,
                  ),
                ),
            ],
          ),
          SizedBox(height: 32),
          if (pageData.redText != null)
            Center(
              child: Text(
                pageData.redText!,
                style: TextStyle(
                  color: MainTheme.redText,
                  fontSize: 18,
                  fontFamily: 'BaiJamjuree',
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          if (pageData.blackText != null)
            Center(
              child: Text(
                pageData.blackText!,
                style: TextStyle(
                  color: MainTheme.mainText,
                  fontSize: 18,
                  fontFamily: 'BaiJamjuree',
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          SizedBox(height: 12),

          if (pageData.imagePath != null)
            Center(
              child: Image.asset(pageData.imagePath!, width: 200, height: 200),
            ),
        ],
      ),
    );
  }
}