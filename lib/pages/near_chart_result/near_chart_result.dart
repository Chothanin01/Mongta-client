import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:client/services/http_client.dart';
import 'package:client/services/user_service.dart';
import 'package:client/core/router/path.dart';
import 'package:go_router/go_router.dart';
import 'package:client/services/tutorial_preferences.dart';


class EyeTestResultsScreen extends StatefulWidget {
  const EyeTestResultsScreen({Key? key}) : super(key: key);

  @override
  State<EyeTestResultsScreen> createState() => _EyeTestResultsScreenState();
}

class _EyeTestResultsScreenState extends State<EyeTestResultsScreen> {
  bool isLoading = true;
  String errorMessage = '';
  
  // Default data structure that will be replaced with API response
  Map<String, dynamic> eyeTestResults = {
    'right_eye': {
      'line_right': 0,
      'va_right': '',
      'right_risk': 0
    },
    'left_eye': {
      'line_left': 0,
      'va_left': '',
      'left_risk': 0
    },
    'description': '',
  };

  @override
  void initState() {
    super.initState();
    // Call the API when the screen initializes
    fetchEyeTestResults();
  }

  // Function to convert VA to percentage
  double vaToPercentage(String va) {
    // Map of VA values to percentages
    final Map<String, double> vaPercentages = {
      '20/200': 0.1, // 10%
      '20/100': 0.2, // 20%
      '20/70': 0.3,  // 30%
      '20/50': 0.4,  // 40%
      '20/40': 0.5,  // 50%
      '20/30': 0.6,  // 60%
      '20/25': 0.7,  // 70%
      '20/20': 1.0,  // 100%
    };
    
    return vaPercentages[va] ?? 0.0;
  }

  // Function to get color based on percentage
  Color getColorForPercentage(double percentage) {
    if (percentage <= 0.3) {
      return Colors.red; // Poor vision
    } else if (percentage <= 0.6) {
      return Colors.orange; // Moderate vision
    } else {
      return Colors.green; // Good vision
    }
  }

  Future<void> fetchEyeTestResults() async {
  setState(() {
    isLoading = true;
    errorMessage = '';
  });

  try {
    final prefs = await SharedPreferences.getInstance();
    final near1 = prefs.getString('selected_line_1')?.replaceAll(RegExp(r'\D'), '') ?? '0';
    final near2 = prefs.getString('selected_line_2')?.replaceAll(RegExp(r'\D'), '') ?? '0';
    final near3 = prefs.getString('selected_line_3')?.replaceAll(RegExp(r'\D'), '') ?? '0';
    final near4 = prefs.getString('selected_line_4')?.replaceAll(RegExp(r'\D'), '') ?? '0';

    // แปลงค่าเป็นตัวเลข
    final int nearValue1 = int.tryParse(near1) ?? 0;
    final int nearValue2 = int.tryParse(near2) ?? 0;
    final int nearValue3 = int.tryParse(near3) ?? 0;
    final int nearValue4 = int.tryParse(near4) ?? 0;

    // Use HttpClient instead of direct http call
    final response = await HttpClient.post(
      '/api/nearchart',
      {
        'near1': nearValue1,
        'near2': nearValue2,
        'near3': nearValue3,
        'near4': nearValue4,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        setState(() {
          eyeTestResults = {
            'right_eye': data['right_eye'],
            'left_eye': data['left_eye'],
            'description': data['description'],
          };
          isLoading = false;
        });
        
        // SAVE RESULTS TO SHARED PREFERENCES FOR LATER USE
        // Instead of calling saveToScanHistory directly
        await _saveEyeTestResultsToPrefs(eyeTestResults);
      } else {
        setState(() {
          errorMessage = data['message'] ?? 'Unknown error occurred';
          isLoading = false;
        });
      }
    } else if (response.statusCode == 401) {
      // Unauthorized - token invalid or expired
      await UserService.logout();
      setState(() {
        errorMessage = 'กรุณาเข้าสู่ระบบใหม่';
        isLoading = false;
      });
    } else {
      final errorData = json.decode(response.body);
      setState(() {
        errorMessage = errorData['message'] ?? 'Failed to load data. Status code: ${response.statusCode}';
        isLoading = false;
      });
    }
  } catch (e) {
    setState(() {
      errorMessage = 'Network error: $e';
      isLoading = false;
    });
  }
}

Future<void> _saveEyeTestResultsToPrefs(Map<String, dynamic> results) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    
    // Save the raw VA test data for later use in scan
    final rightEye = results['right_eye'];
    final leftEye = results['left_eye'];
    
    await prefs.setString('nearchart_results', jsonEncode(results));
    await prefs.setString('va_right', rightEye['va_right'] ?? '');
    await prefs.setString('va_left', leftEye['va_left'] ?? '');
    await prefs.setInt('line_right', rightEye['line_right'] ?? 0);
    await prefs.setInt('line_left', leftEye['line_left'] ?? 0);
    await prefs.setString('near_description', results['description'] ?? '');
    
    debugPrint('Saved eye test results to SharedPreferences');
  } catch (e) {
    debugPrint('Error saving eye test results: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          errorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red, letterSpacing: -0.5),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: fetchEyeTestResults,
                          child: const Text('Try Again', style: TextStyle(letterSpacing: -0.5)),
                        ),
                      ],
                    ),
                  ),
                )
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 50),
                        const Text(
                          'ผลการวัดค่าสายตา',
                          style: TextStyle(
                            fontSize: 24,
                            fontFamily: 'BaiJamjuree',
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5
                          ),
                        ),
                        const SizedBox(height: 90),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Swapped positions - Right eye on the left side
                            _buildEyeResult(
                              'ตาขวา',
                              eyeTestResults['right_eye']['va_right'] ?? '0/0', // Changed from right_va to va_right with null check
                            ),
                            // Left eye on the right side
                            _buildEyeResult(
                              'ตาซ้าย',
                              eyeTestResults['left_eye']['va_left'] ?? '0/0', // Changed from left_va to va_left with null check
                            ),
                          ],
                        ),
                        const SizedBox(height: 50),
                        // Changed order - Right eye first, then left eye
                        Text(
                          'ตาขวาผลการวัดค่าสายตาอยู่ บรรทัดที่ ${eyeTestResults['right_eye']['line_right'] ?? 0}', // Changed from right_line
                          style: const TextStyle(fontSize: 16, fontFamily: 'BaiJamjuree', letterSpacing: -0.5, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'ตาซ้ายผลการวัดค่าสายตาอยู่ บรรทัดที่ ${eyeTestResults['left_eye']['line_left'] ?? 0}', // Changed from left_line
                          style: const TextStyle(fontSize: 16, fontFamily: 'BaiJamjuree', letterSpacing: -0.5, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 30),
                        Text(
                          eyeTestResults['description'],
                          style: const TextStyle(fontSize: 16, fontFamily: 'BaiJamjuree', letterSpacing: -0.5, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                        const Spacer(),
                        const SizedBox(height: 80),
                        _buildFinishButton(),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildEyeResult(String title, String value) {
    // Handle empty values to prevent errors
    final parts = value.isNotEmpty ? value.split('/') : ['0', '0'];
    
    // Calculate percentage based on VA value
    final percentage = vaToPercentage(value);
    
    // Get color based on percentage
    final progressColor = getColorForPercentage(percentage);
    
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontFamily: 'BaiJamjuree',
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: percentage, // Use the calculated percentage
                  strokeWidth: 10,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor), // Use dynamic color
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      parts[0],
                      style: const TextStyle(
                        fontSize: 18,
                        fontFamily: 'BaiJamjuree',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(
                      color: Colors.black,
                      thickness: 1,
                      indent: 30,
                      endIndent: 30,
                    ),
                    Text(
                      parts.length > 1 ? parts[1] : '0',
                      style: const TextStyle(
                        fontSize: 18,
                        fontFamily: 'BaiJamjuree',
                        fontWeight: FontWeight.bold,
                      ),
                    ),                    
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFinishButton() {
    return Container(
      width: 270,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: const LinearGradient(
          colors: [Color(0xFF12358F), Color(0xFFF5BBD1)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: [0.4, 1.0],
        ),
      ),
      child: ElevatedButton(
        onPressed: _onFinishedPressed, // Change to call new method instead of direct navigation
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: const Text(
          'ดำเนินการต่อ',
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'BaiJamjuree',
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _onFinishedPressed() async {
    final hasViewedScanTutorial = await TutorialPreferences.hasViewedScanTutorial();
    
    if (hasViewedScanTutorial) {
      context.go('/scan'); 
    } else {
      context.go('/scan-tutorial');
    }
  }
}