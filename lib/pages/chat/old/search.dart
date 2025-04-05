import 'package:client/pages/chat/old/chat_list_view.dart';
import 'package:flutter/material.dart';
import 'package:client/core/theme/theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SearchOphthalmologistScreen(),
    );
  }
}


class SearchOphthalmologistScreen extends StatefulWidget {
  const SearchOphthalmologistScreen({Key? key}) : super(key: key);

  @override
  State<SearchOphthalmologistScreen> createState() => _SearchOphthalmologistScreenState();
}

class _SearchOphthalmologistScreenState extends State<SearchOphthalmologistScreen> {
  bool _isMaleSelected = false;
  bool _isFemaleSelected = false;

  String get _selectedGender {
    if (_isMaleSelected && _isFemaleSelected) {
      return 'both';
    } else if (_isMaleSelected) {
      return 'male';
    } else if (_isFemaleSelected) {
      return 'female';
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.03),
              // Title - Search for Ophthalmologists
              Text(
                'ค้นหาจักษุแพทย์',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: MainTheme.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenHeight * 0.03),
              
              // Search Image
              Image.asset(
                'assets/images/search.png',
                width: 120,
                height: 120,
              ),
              SizedBox(height: screenHeight * 0.03),
              
              // Select Ophthalmologist Gender Text
              Container(
                width: screenWidth * 0.9,
                padding: EdgeInsets.all(screenWidth * 0.05),
                child: Text(
                  'เลือกเพศของจักษุแพทย์',
                  style: TextStyle(
                    fontSize: 20,
                    color: MainTheme.black,
                  ),
                ),
              ),
              
              // Gender Selection Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Male Button
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isMaleSelected = !_isMaleSelected;
                      });
                    },
                    child: _buildGenderButton(
                      isSelected: _isMaleSelected,
                      imagePath: 'assets/images/male_gender.png',
                      label: 'เพศชาย',
                      width: 119,
                      height: 61,
                    ),
                  ),
                  SizedBox(width: 20),
                  
                  // Female Button
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isFemaleSelected = !_isFemaleSelected;
                      });
                    },
                    child: _buildGenderButton(
                      isSelected: _isFemaleSelected,
                      imagePath: 'assets/images/femenine.png',
                      label: 'เพศหญิง',
                      width: 119,
                      height: 61,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: screenHeight * 0.1),
              
              // Start Search Button
              GestureDetector(
                onTap: () {
                  // Handle search with selected gender
                  print('Selected gender: $_selectedGender');
                  // Add your navigation or search logic here
                },
                child: _buildbluebox(
                  width: 270,
                  height: 55,
                  borderRadius: 30,
                  child: Center(
                    child: Text(
                      'เริ่มค้นหาจักษุแพทย์',
                      style: TextStyle(
                        color: Color(0xFFFCFCFC),
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 20),
              
              // Back Button
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => ChatListView()),
                  );
                },
                child: Text(
                  'ย้อนกลับ',
                  style: TextStyle(
                    color: Color(0xFF12358F),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              SizedBox(height: screenHeight * 0.03),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderButton({
    required bool isSelected,
    required String imagePath,
    required String label,
    required double width,
    required double height,
  }) {
    return _buildroundedbox(
      width: width,
      height: height,
      borderRadius: 10,
      color: isSelected ? MainTheme.chatBlue : MainTheme.white,
      shadowColor: Color(0xB3B3B3B3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            width: 24,
            height: 24,
            color: isSelected ? MainTheme.white : MainTheme.black,
          ),
          SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? MainTheme.white : MainTheme.black,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
}

// Assuming these are your existing helper methods
  Widget _buildroundedbox({
    required double width,
    required double height,
    required double borderRadius,
    required Color color,
    required Color shadowColor,
    required Widget child,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildbluebox({
    required double width,
    required double height,
    required double borderRadius,
    required Widget child,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: MainTheme.chatBlue,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: child,
    );
  }
}