import 'package:client/pages/chat/user/chat_user_screen.dart';
import 'package:flutter/material.dart';
import 'package:client/core/theme/theme.dart';
import 'package:client/pages/chat/user/chat_empty_view.dart';
import 'package:client/services/chat_service.dart';
import 'package:client/services/user_service.dart';
import 'package:client/services/user_api_service.dart';


class ChatSearch extends StatefulWidget {
  const ChatSearch({super.key});

  @override
  State<ChatSearch> createState() => _ChatSearchState();
}

class _ChatSearchState extends State<ChatSearch> {
  bool _isMaleSelected = false;
  bool _isFemaleSelected = false;
  bool _isLoading = true;
  String? profilePicture;
  String userName = '';
  final ChatService _chatService = ChatService();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      setState(() => _isLoading = true);
      
      // Try to get user data from chat history first
      try {
        final chatData = await _chatService.getChatHistory();
        
        if (chatData.containsKey('user') && chatData['user'] != null) {
          final user = chatData['user'];
          setState(() {
            profilePicture = user['profile_picture'];
            userName = '${user['first_name']} ${user['last_name']}';
            _isLoading = false;
          });
          return;
        }
      } catch (chatError) {
        print('Chat history error: $chatError');
        // Continue to fallback method
      }
      
      // Fallback: Get user data directly through user API
      final userId = await UserService.getCurrentUserId();
      if (userId.isNotEmpty) {
        final apiService = ApiService();
        final userData = await apiService.getUser(userId);
        
        setState(() {
          profilePicture = userData['profile_picture'];
          userName = '${userData['first_name']} ${userData['last_name']}';
          _isLoading = false;
        });
      } else {
        setState(() {
          profilePicture = null;
          userName = 'ไม่พบข้อมูลผู้ใช้';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('API Error: $e');
      setState(() {
        profilePicture = null;
        userName = 'เกิดข้อผิดพลาด';
        _isLoading = false; 
      });
    }
  }

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
    try {
      final userId = await UserService.getCurrentUserId();
      if (userId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('กรุณาเข้าสู่ระบบก่อนใช้งาน')),
        );
        return;
      }
      
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(child: CircularProgressIndicator());
        },
      );
      
      final chatService = ChatService();
      
      try {
        final result = await chatService.findOphthalmologist(_selectedGender);
        
        // Hide loading indicator if context is still mounted
        if (context.mounted) {
          Navigator.of(context, rootNavigator: true).pop();
        }
        
        if (result['success'] == true && result['create'] != null) {
          final chatSession = result['create'];
          final conversationId = chatSession['id'];
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatUserScreen(conversationId: conversationId),
            ),
          );
        } else {
          // Show error from the result
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result['message'] == "No ophthamologist available." 
                  ? 'ไม่พบจักษุแพทย์ที่ว่างในขณะนี้ กรุณาลองใหม่อีกครั้งในภายหลัง'
                  : (result['message'] ?? 'ไม่สามารถค้นหาจักษุแพทย์ได้ในขณะนี้')
              ),
              backgroundColor: MainTheme.redWarning,
            ),
          );
        }
      } catch (e) {
        // Make sure loading dialog is dismissed on error
        if (context.mounted) {
          Navigator.of(context, rootNavigator: true).pop();
        }
        
        // Then show the error message
        String errorMsg = 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง';
        
        // Handle the specific error message case
        String errorStr = e.toString();
        if (errorStr.contains('No ophthamologist available')) {
          errorMsg = 'ไม่พบจักษุแพทย์ที่ว่างในขณะนี้ กรุณาลองใหม่อีกครั้งในภายหลัง';
        }
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              backgroundColor: MainTheme.redWarning,
            ),
          );
        }
      }
    } catch (e) {
      // This is for errors before the loading dialog appears
      print('Pre-dialog error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง'),
          backgroundColor: MainTheme.redWarning,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: MainTheme.white,
      body: SafeArea(
        child: _isLoading 
          ? Center(child: CircularProgressIndicator())
          : Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: screenHeight * 0.04),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      profilePicture != null
                          ? _buildRoundedBox(context, profilePicture!)
                          : CircleAvatar(
                              radius: MediaQuery.of(context).size.width * 0.09,
                              backgroundColor: Colors.grey[300],
                              child: Icon(Icons.person, size: 40, color: Colors.grey[700]),
                            ),
                      SizedBox(width: screenWidth * 0.05),
                      _buildBlueBox(context, userName),
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
                    onTap: _searchOphth,
                    child: _buildSearchButton(context),
                  ),
                  
                  SizedBox(height: screenHeight * 0.02),
                  
                  // Back Button - Responsive
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'ย้อนกลับ',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: MainTheme.navbarFocusText,
                        decoration: TextDecoration.underline,
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
        errorBuilder: (context, error, stackTrace) => Container(
          width: boxSize,
          height: boxSize,
          color: Colors.grey[300],
          child: Icon(Icons.person, size: boxSize * 0.6, color: Colors.grey[700]),
        ),
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

    return Container(
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
    );
  }
}