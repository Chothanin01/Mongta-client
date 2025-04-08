import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:client/core/components/landing/landing_button.dart';
import 'package:client/core/theme/theme.dart';
import 'package:client/services/tutorial_preferences.dart';

class LandingPageData {
  final String step;
  final String? welcome;
  final String? logoPath;
  final String? mongtaTitle;
  final String? centerLogoPath;
  final String? imagePath;
  final String? centerMongtaTitle;
  final String? subTitle;

  LandingPageData({
    required this.step,
    this.welcome,
    this.logoPath,
    this.mongtaTitle,
    this.centerLogoPath,
    this.imagePath,
    this.centerMongtaTitle,
    this.subTitle,
  });
}

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<LandingPageData> _pages = [
    LandingPageData(
      step: "1",
      welcome: "ยินดีต้อนรับสู่...",
      centerLogoPath: "assets/images/MongtaLogo_landing.png",
      centerMongtaTitle: "มองตา",
      subTitle: "เรื่องดวงตา ให้เราดูแล",
    ),
    LandingPageData(
      step: "2",
      logoPath: "assets/images/MongtaLogo.png",
      mongtaTitle: "มองตา",
      imagePath: "assets/images/LandingNearChart.png",
    ),
    LandingPageData(
      step: "3",
      logoPath: "assets/images/MongtaLogo.png",
      mongtaTitle: "มองตา",
      imagePath: "assets/images/final_landing.png",
    ),
  ];

  void _nextPage() async {
    if (_currentIndex < _pages.length - 1) {
      _controller.nextPage(
          duration: Duration(milliseconds: 500), curve: Curves.ease);
    } else {
      // Mark landing page as viewed
      await TutorialPreferences.setLandingPageViewed();
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    
    return Scaffold(
      backgroundColor: MainTheme.mainBackground,
      body: SafeArea(
        child: Stack(
          children: [
            // Main Content Column
            Column(
              children: [            
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
                  padding: EdgeInsets.all(screenWidth * 0.04), // Responsive padding
                  child: SizedBox(
                    height: screenHeight * 0.15, // Responsive height
                    child: Column(
                      children: [

                        // Next button
                        LandingButton(
                          onTap: _nextPage,
                          buttonText: _currentIndex == _pages.length - 1
                              ? "เริ่มต้นใช้งาน"
                              : "ต่อไป",
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
  final LandingPageData pageData;

  const OnboardingPage({super.key, required this.pageData});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    
    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.08), // Responsive padding
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: screenHeight * 0.7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (pageData.welcome != null)
                Text(
                  pageData.welcome!,
                  style: TextStyle(
                    color: MainTheme.mainText,
                    fontSize: screenWidth * 0.06, // Responsive font size
                    fontFamily: 'BaiJamjuree',
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                
              if (pageData.logoPath != null)
                Center(
                  child: Image.asset(
                    pageData.logoPath!, 
                    width: screenWidth * 0.2, 
                    height: screenWidth * 0.2
                  ),
                ),

              if (pageData.mongtaTitle != null)
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: pageData.mongtaTitle!.substring(0, 3), // "มอง"
                          style: TextStyle(
                            color: const Color.fromRGBO(18, 53, 143, 1), // Blue color for "มอง"
                            fontSize: screenWidth * 0.24, // Responsive font size
                            fontFamily: 'FCLamoonBold',
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        TextSpan(
                          text: pageData.mongtaTitle!.substring(3), // "ตา"
                          style: TextStyle(
                            color: const Color.fromRGBO(228, 77, 81, 1), // Red color for "ตา"
                            fontSize: screenWidth * 0.24, // Responsive font size
                            fontFamily: 'FCLamoonBold',
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              if (pageData.centerLogoPath != null)
                Center(
                  child: Image.asset(
                    pageData.centerLogoPath!, 
                    width: screenWidth * 0.6, 
                    height: screenWidth * 0.6
                  ),
                ),

              SizedBox(height: screenHeight * 0.01),
              
              if (pageData.imagePath != null)
                Center(
                  child: Image.asset(
                    pageData.imagePath!, 
                    width: screenWidth * 0.7, 
                    height: screenWidth * 0.7,
                    fit: BoxFit.contain,
                  ),
                ),
                
              if (pageData.centerMongtaTitle != null)
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: pageData.centerMongtaTitle!.substring(0, 3), // "มอง"
                          style: TextStyle(
                            color: const Color.fromRGBO(18, 53, 143, 1), // Blue color for "มอง"
                            fontSize: screenWidth * 0.24, // Responsive font size
                            fontFamily: 'FCLamoonBold',
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        TextSpan(
                          text: pageData.centerMongtaTitle!.substring(3), // "ตา"
                          style: TextStyle(
                            color: const Color.fromRGBO(228, 77, 81, 1), // Red color for "ตา"
                            fontSize: screenWidth * 0.24, // Responsive font size
                            fontFamily: 'FCLamoonBold',
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              if (pageData.subTitle != null)
                Text(
                  pageData.subTitle!,
                  style: TextStyle(
                    color: MainTheme.mainText,
                    fontSize: screenWidth * 0.06, // Responsive font size
                    fontFamily: 'BaiJamjuree',
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}