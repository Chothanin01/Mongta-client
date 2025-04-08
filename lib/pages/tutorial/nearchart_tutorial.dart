import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:client/core/components/tutorial/t_nc_button.dart';
import 'package:client/core/components/tutorial/custom_step_indicator.dart';
import 'package:client/core/theme/theme.dart';
import 'package:client/services/tutorial_preferences.dart';

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

class NearChartTutorial extends StatefulWidget {
  const NearChartTutorial({super.key});

  @override
  State<NearChartTutorial> createState() => _NearChartTutorialState();
}

class _NearChartTutorialState extends State<NearChartTutorial> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<TutorialPageData> _pages = [
    TutorialPageData(
      step: "1",
      title: "ขั้นตอนการใช้งาน",
      subtitle: "การวัดค่าสายตา (Near Chart)",
      redText: "เพิ่มแสงหน้าจอเป็น 100%",
      blackText: "ถือโทรศัพท์ให้สุดเเขน เเละอยู่ในเเนวตั้ง",
      imagePath: 'assets/images/nc_tutorial_1.png',
    ),
    TutorialPageData(
      step: "2",
      title: "ขั้นตอนการใช้งาน",
      subtitle: "การวัดค่าสายตา (Near Chart)",
      redText: "เริ่มต้นดูด้วยตาข้างขวา",
      blackText: "โดยใช้มือซ้ายปิดตาข้างซ้าย",
    ),
    TutorialPageData(
      step: "3",
      title: "ขั้นตอนการใช้งาน",
      subtitle: "การวัดค่าสายตา (Near Chart)",
      redText: "อ่านภาพโดยเริ่มจากข้างบน \n เเล้วไล่ลงมาที่ข้างล่าง",
      blackText: "ให้บันทึกผลบรรทัดล่างสุดที่ยังอ่านได้",
    ),
    TutorialPageData(
      step: "4",
      title: "ขั้นตอนการใช้งาน",
      subtitle: "การวัดค่าสายตา (Near Chart)",
      redText: "อ่านตัวอักษรและเลือกคำตอบ",
      blackText: "ในรอบที่ 1 และ 3 ให้ใช้ตาเปล่าหากมี เเว่นหรือคอนแทคเลนส์ ให้ใช้ในรอบที่ 2 และรอบที่ 4 หากไม่มี ให้ใช้ตาเปล่าในทุกๆรอบ",
    ),
    TutorialPageData(
      step: "5",
      title: "ขั้นตอนการใช้งาน",
      subtitle: "การวัดค่าสายตา (Near Chart)",
      redText: "เมื่อจบตาข้างขวาเเล้วให้ทำตาข้างซ้ายต่อ",
      blackText: "โดยใช้มือขวาปิดตาข้างขวา รวมทั้งสิ้น 4 รอบ",
    ),
  ];

  void _nextPage() async {
    if (_currentIndex < _pages.length - 1) {
      _controller.nextPage(
          duration: Duration(milliseconds: 500), curve: Curves.ease);
    } else {
      await TutorialPreferences.setNearChartTutorialViewed();
      context.go('/near_chart_one');
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
          // Back Button - Positioned independently
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
              // Indicator centered at top
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
                        NcTutorialButton(
                          onTap: _nextPage,
                          buttonText: _currentIndex == _pages.length - 1
                              ? "เริ่มวัดค่าสายตา"
                              : "ต่อไป",
                        ),
                        SizedBox(
                          height: 48, // Fixed height space for the skip button
                          child: _currentIndex == 0
                              ? TextButton(
                                  onPressed: () => context.go('/near_chart_one'),
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
                                  .shrink(), // Empty widget when button is hidden
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
          SizedBox(height: 16),

          if (pageData.imagePath != null)
            Center(
              child: Image.asset(pageData.imagePath!, width: 300, height: 300),
            ),
        ],
      ),
    );
  }
}