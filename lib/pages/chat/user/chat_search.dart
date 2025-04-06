import 'package:client/pages/chat/user/chat_user_screen.dart';
import 'package:flutter/material.dart';
import 'package:client/core/theme/theme.dart';
import 'package:client/pages/chat/user/chat_empty_view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChatSearch(),
    );
  }
}

class ChatSearch extends StatefulWidget {
  const ChatSearch({super.key});

  @override
  State<ChatSearch> createState() => _ChatSearchState();
}

class _ChatSearchState extends State<ChatSearch> {
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
      return 'both';
    }
  }

void _searchOphth() async {
  final url = Uri.parse('http://localhost:5000/api/findophth'); 
  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "user_id": 5, 
      "sex": _selectedGender, 
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
  final data = jsonDecode(response.body);
  final chatSession = data["create"]; 

      if (chatSession != null) {
        print("ChatSession: $chatSession");
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>  ChatUserScreen (),
          ),
        );
      } else {
        print("Error: chatSession is null");
      }
    } else {
      print('Error: ${response.statusCode} - ${response.body}');
    }
  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
        backgroundColor: MainTheme.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: screenHeight * 0.04),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildRoundedBox(context, 'กฟ'),
                      SizedBox(width: screenWidth * 0.05),
                      _buildBlueBox(context, 'คุณแก้วตา ฟ้าประทานพร'),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  
                  Text(
                    'ค้นหาจักษุแพทย์',
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                      color: MainTheme.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  // SizedBox(height: screenHeight * 0.01),
                  
                  Image.asset(
                    'assets/images/search.png',
                    width: screenWidth * 0.3,
                    height: screenHeight * 0.3,
                  ),
                  
                  Container(
                    width: screenWidth * 0.9,
                    padding: EdgeInsets.all(screenWidth * 0.05),
                    child: Text(
                      'เลือกเพศของจักษุแพทย์',
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        color: MainTheme.black,
                      ),
                    ),
                  ),
                  
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
                          context: context,
                          isSelected: _isMaleSelected,
                          imagePath: 'assets/images/male_gender.png',
                          label: 'เพศชาย',
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.05),
                      
                      // Female Button
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isFemaleSelected = !_isFemaleSelected;
                          });
                        },
                        child: _buildGenderButton(
                          context: context,
                          isSelected: _isFemaleSelected,
                          imagePath: 'assets/images/femenine.png',
                          label: 'เพศหญิง',
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: screenHeight * 0.1),
                  
                  // Start Search Button
                  GestureDetector(
                    onTap: () {
                      print('Selected gender: $_selectedGender');
                      _searchOphth();   
                    },
                      child: _buildSearchButton(context),
                  ),
                  
                  SizedBox(height: screenHeight * 0.02),
                  
                  // Back Button - Responsive
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => ChatEmptyView()),
                      );
                    },
                    child: Text(
                      'ย้อนกลับ',
                      style: TextStyle(
                        color: Color(0xFF12358F),
                        fontSize: screenWidth * 0.04, 
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: screenHeight * 0.03),
                ],
              ),
            ),
          ),
        ),
      );
  }
  

  Widget _buildRoundedBox(BuildContext context, String imageUrl) {
    double boxSize = MediaQuery.of(context).size.width * 0.18;

    return ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: Image.network(
      imageUrl,
      width: boxSize,
      height: boxSize,
      fit: BoxFit.cover,
    ),
  );
}

  Widget _buildBlueBox(BuildContext context, String text) {
    double boxWidth = MediaQuery.of(context).size.width * 0.55;
    double boxHeight = MediaQuery.of(context).size.width * 0.18;

    return Container(
      width: boxWidth,
      height: boxHeight,
      decoration: BoxDecoration(
        color: MainTheme.chatBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: MainTheme.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildGenderButton({
    required BuildContext context,
    required bool isSelected,
    required String imagePath,
    required String label,
  }) {
    double screenWidth = MediaQuery.of(context).size.width;
    
    return Container(
      width: screenWidth * 0.3, 
      height: screenWidth * 0.15, 
      decoration: BoxDecoration(
        color: isSelected ? MainTheme.chatBlue : MainTheme.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: MainTheme.chatGrey,
          width: 1,
      ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            width: screenWidth * 0.06, 
            height: screenWidth * 0.06,
            color: isSelected ? MainTheme.white : MainTheme.black,
          ),
          SizedBox(width: screenWidth * 0.01),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? MainTheme.white : MainTheme.black,
              fontSize: screenWidth * 0.035, // Responsive font size
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchButton(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      child: Container(
        width: screenWidth * 0.7,
        height: screenWidth * 0.14,
        decoration: BoxDecoration(
          color: MainTheme.chatBlue,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
            'เริ่มค้นหาจักษุแพทย์',
            style: TextStyle(
              color: MainTheme.chatWhite,
              fontSize: screenWidth * 0.045,
            ),
          ),
        ),
      ),
    );
  }
}

// void _showPopup(BuildContext context) async {
//   double screenWidth = MediaQuery.of(context).size.width;

//   await Future.delayed(const Duration(milliseconds: 300));

//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (BuildContext context) {
//       return Dialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Container(
//           width: screenWidth * 0.3,
//           height: screenWidth * 0.7,
//           decoration: BoxDecoration(
//             color: MainTheme.white,
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Center(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 TweenAnimationBuilder(
//                   tween: Tween<double>(begin: 0.0, end: 1.0),
//                   duration: const Duration(seconds: 2),
//                   onEnd: () {
//                     Navigator.of(context).pop();
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => ChatScreenClient(),
//                       ),
//                     );
//                   },
//                   builder: (context, double opacity, child) {
//                     return AnimatedOpacity(
//                       opacity: opacity,
//                       duration: const Duration(milliseconds: 500),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Image.asset(
//                             'assets/images/SE_logo 3.png',
//                             width: screenWidth * 0.4,
//                           ),
//                         ],
//                       ),
//                       );
//                   },
//                 ),
//                 const SizedBox(height: 0.5),
//                  Text(
//                    'กำลังค้นหาจักษุแพทย์ รอสักครู่...',
//                    style: TextStyle(
//                      fontSize: screenWidth * 0.04,
//                      fontFamily: 'BaiJamjuree',
//                      color: MainTheme.black,
//                  ),
//                  ),
//               ],
//             ),
//           ),
//         ),
//       );
//     },
//   );
// }
