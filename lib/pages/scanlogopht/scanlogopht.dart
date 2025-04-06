import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ประวัติการสแกน',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'BaiJamjuree', // Thai font
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const ScanHistoryScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ScanHistoryScreen extends StatefulWidget {
  const ScanHistoryScreen({Key? key}) : super(key: key);

  @override
  State<ScanHistoryScreen> createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen> {
  bool isLoading = true;
  String errorMessage = '';
  List<Map<String, dynamic>> scanHistory = [];

  @override
  void initState() {
    super.initState();
    fetchScanHistory();
  }

  double vaToPercentage(String va) {
    // Map of VA values to percentages
    final Map<String, double> vaPercentages = {
      '20/200': 0.1, // 10%
      '20/100': 0.2, // 20%
      '20/70': 0.3, // 30%
      '20/50': 0.4, // 40%
      '20/40': 0.5, // 50%
      '20/30': 0.6, // 60%
      '20/25': 0.7, // 70%
      '20/20': 1.0, // 100%
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

  Future<void> fetchScanHistory() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final conversationId = prefs.getInt('conversation_id') ?? 1;
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/scanlog/ophtha/$conversationId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(
            'API Response: ${json.encode(data)}'); // Debug print with full JSON

        if (data['success'] == true) {
          final List<dynamic> scanLogs = data['scanlog'];
          final Map<String, dynamic> userData = data['user']; // ดึงข้อมูล user จาก response
          print('Scan logs count: ${scanLogs.length}');

          // คำนวณข้อมูลผู้ใช้จากฟังก์ชันที่เพิ่มเข้ามา
          final fullName = _getFullNameWithPrefix(
            userData['first_name'] ?? '',
            userData['last_name'] ?? '',
            userData['is_opthamologist'] as bool?,
            userData['sex'] as String?,
          );
          final sexDisplay = _getSexDisplay(userData['sex'] as String?);
          final age = _calculateAge(userData['date_of_birth'] as String);
          final profilePicture = userData['profile_picture'] as String?;

          print(
              'User Full Name: $fullName, Sex: $sexDisplay, Age: $age, Profile Picture: $profilePicture');

          setState(() {
            scanHistory = scanLogs.map<Map<String, dynamic>>((scan) {
              print('Processing scan: ${json.encode(scan)}'); // Debug each scan

              // Parse the scan data from API to match our UI format
              final Map<String, dynamic> scanData = {
                'id': scan['id'],
                'title': 'ประวัติการสแกน',
                'date': _formatDate(scan['date']),
                'isExpanded': true, // Set to true to show expanded by default
                'description': scan['description'] ?? '',
                // เพิ่มข้อมูลผู้ใช้เข้าไปใน scanData
                'user': {
                  'fullName': fullName,
                  'sex': sexDisplay,
                  'age': age,
                  'profilePicture': profilePicture,
                },
              };

              // Parse VA (Visual Acuity) data if available
              if (scan['va'] != null) {
                try {
                  final va = scan['va'];
                  print('VA data: ${json.encode(va)}'); // Debug VA data

                  Map<String, dynamic> vaMap;
                  if (va is String) {
                    try {
                      vaMap = json.decode(va) as Map<String, dynamic>;
                    } catch (e) {
                      print('Error parsing VA string: $e');
                      vaMap = {};
                    }
                  } else if (va is Map) {
                    vaMap = Map<String, dynamic>.from(va);
                  } else {
                    print('VA is neither string nor map: ${va.runtimeType}');
                    vaMap = {};
                  }

                  if (vaMap.isNotEmpty) {
                    final vaLeft = vaMap['va_left'] ?? '0/0';
                    final vaRight = vaMap['va_right'] ?? '0/0';
                    final lineLeft = vaMap['line_left'] ?? '0';
                    final lineRight = vaMap['line_right'] ?? '0';
                    final description =
                        vaMap['description'] ?? 'ไม่มีข้อมูลผลการวัดสายตา';

                    double percentageLeft = _convertVAToPercentage(vaLeft);
                    double percentageRight = _convertVAToPercentage(vaRight);

                    final leftEye = {
                      'line': lineLeft,
                      'value': vaLeft,
                      'percentage': percentageLeft,
                    };

                    final rightEye = {
                      'line': lineRight,
                      'value': vaRight,
                      'percentage': percentageRight,
                    };

                    scanData['eyeTest'] = {
                      'leftEye': leftEye,
                      'rightEye': rightEye,
                      'result': description,
                    };
                  }
                } catch (e) {
                  print('Error parsing VA data: $e');
                  scanData['eyeTest'] = {
                    'leftEye': _getDefaultEyeData(),
                    'rightEye': _getDefaultEyeData(),
                    'result': 'ไม่มีข้อมูลผลการวัดสายตา',
                  };
                }
              } else {
                scanData['eyeTest'] = {
                  'leftEye': _getDefaultEyeData(),
                  'rightEye': _getDefaultEyeData(),
                  'result': 'ไม่มีข้อมูลผลการวัดสายตา',
                };
              }

              // Parse photo data if available
              try {
                var photos = scan['photo'];
                print('Photo data: ${json.encode(photos)}'); // Debug photo data

                Map<String, dynamic> photoMap;
                if (photos is String) {
                  try {
                    photoMap = json.decode(photos) as Map<String, dynamic>;
                  } catch (e) {
                    print('Error parsing photo string: $e');
                    photoMap = {};
                  }
                } else if (photos is Map) {
                  photoMap = Map<String, dynamic>.from(photos);
                } else {
                  print(
                      'Photo is neither string nor map: ${photos.runtimeType}');
                  photoMap = {};
                }

                final mappedPhotos = {
                  'leftEye': photoMap['left_eye'],
                  'rightEye': photoMap['right_eye'],
                  'leftEyeAI': photoMap['ai_left'],
                  'rightEyeAI': photoMap['ai_right'],
                  'description':
                      photoMap['description'] ?? 'ไม่มีข้อมูลผลการสแกนดวงตา',
                };

                scanData['eyeScan'] = {
                  'photos': mappedPhotos,
                  'result': photoMap['description'] ??
                      scan['description'] ??
                      'ไม่มีข้อมูลผลการสแกนดวงตา',
                };
              } catch (e) {
                print('Error parsing photo data: $e');
                scanData['eyeScan'] = {
                  'photos': {},
                  'result': scan['description'] ?? 'ไม่มีข้อมูลผลการสแกนดวงตา',
                };
              }

              scanData['conclusion'] =
                  scan['description'] ?? 'ไม่มีข้อมูลสรุปผล';

              return scanData;
            }).toList();
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = data['message'] ?? 'Failed to load scan history';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Server error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Network error: $e'); // Debug print
      setState(() {
        errorMessage = 'Network error: $e';
        isLoading = false;
      });
    }
  }

// เพิ่ม 3 ฟังก์ชันที่คุณให้มา
  String _getFullNameWithPrefix(
      String firstName, String lastName, bool? isOphth, String? sex) {
    String prefix = 'คุณ';
    if (isOphth == true) {
      if (sex?.toLowerCase() == 'male') {
        prefix = 'นพ.';
      } else if (sex?.toLowerCase() == 'female') {
        prefix = 'พญ.';
      }
    }
    return '$prefix$firstName $lastName';
  }

  String _getSexDisplay(String? sex) {
    if (sex == null) return 'ไม่ระบุ';
    switch (sex.toLowerCase()) {
      case 'male':
        return 'ชาย';
      case 'female':
        return 'หญิง';
      default:
        return 'ไม่ระบุ';
    }
  }

  int _calculateAge(String dob) {
    DateTime birthDate = DateTime.parse(dob);
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  // Helper method to get default eye data
  Map<String, dynamic> _getDefaultEyeData() {
    return {
      'line': 0,
      'value': '0/0',
      'percentage': 0.0,
    };
  }

  // Helper method to convert VA value like "20/20" to percentage
  double _convertVAToPercentage(String vaValue) {
    try {
      // For format like "20/20"
      final parts = vaValue.split('/');
      if (parts.length == 2) {
        // Try to convert to numeric values
        final numerator = double.parse(parts[0]);
        final denominator = double.parse(parts[1]);

        if (denominator == 0) return 0.0; // Avoid division by zero

        // Calculate percentage based on VA ratio
        // 20/20 is considered perfect vision (100%)
        // Lower values like 20/40 indicate worse vision
        if (numerator == 20) {
          // Standard Snellen notation
          return 20 / denominator; // 20/20 = 1.0, 20/40 = 0.5, etc.
        } else {
          // Generic ratio
          return numerator / denominator;
        }
      }

      // If it's just a number (like "10"), convert to percentage based on scale
      // Assuming 10 is max (perfect vision)
      final lineNumber = double.parse(vaValue);
      return lineNumber / 10.0; // Scale to 0.0-1.0
    } catch (e) {
      print('Error converting VA to percentage: $e');
      return 0.5; // Default to 50% if parsing fails
    }
  }

  // Helper method to format date from API
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      // Format date in Thai Buddhist calendar (BE = CE + 543)
      final thaiYear = date.year + 543;
      const thaiMonths = [
        'มกราคม',
        'กุมภาพันธ์',
        'มีนาคม',
        'เมษายน',
        'พฤษภาคม',
        'มิถุนายน',
        'กรกฎาคม',
        'สิงหาคม',
        'กันยายน',
        'ตุลาคม',
        'พฤศจิกายน',
        'ธันวาคม'
      ];
      final day = date.day;
      final month = thaiMonths[date.month - 1];
      final hour = date.hour.toString().padLeft(2, '0'); // ทำให้เป็น 2 หลัก
      final minute = date.minute.toString().padLeft(2, '0'); // ทำให้เป็น 2 หลัก

      return 'วันที่ $day $month พ.ศ. $thaiYear เวลา $hour:$minute น.';
    } catch (e) {
      return dateString;
    }
  }

  void toggleExpand(int index) {
    setState(() {
      scanHistory[index]['isExpanded'] = !scanHistory[index]['isExpanded'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 30),
        child: Container(
          padding: const EdgeInsets.only(top: 30),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios,
                  color: Colors.black, size: 20),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            title: const Text(
              'ประวัติผู้ป่วย',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontFamily: 'BaiJamjuree',
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            centerTitle: true,
          ),
        ),
      ),
      body: Column(
        children: [
          // เพิ่มกรอบสีฟ้าตรงนี้
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(0xFF12358F),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Center(
                      child: scanHistory.isNotEmpty &&
                              scanHistory[0]['user']['profilePicture'] != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                scanHistory[0]['user']['profilePicture'],
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Text(
                                    'ภพ', // Fallback ถ้าโหลดรูปไม่สำเร็จ
                                    style: TextStyle(
                                      color: Color(0xFF12358F),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                            )
                          : const Text(
                              'ภพ', // Fallback ถ้าไม่มี profilePicture
                              style: TextStyle(
                                color: Color(0xFF12358F),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          scanHistory.isNotEmpty
                              ? scanHistory[0]['user']['fullName']
                              : 'คุณ แก้วตา ฟ้าประทานพร', // Fallback ถ้าไม่มีข้อมูล
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          scanHistory.isNotEmpty
                              ? 'อายุ: ${scanHistory[0]['user']['age']} ปี'
                              : 'อายุ: 40 ปี', // Fallback ถ้าไม่มีข้อมูล
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          scanHistory.isNotEmpty
                              ? 'เพศ: ${scanHistory[0]['user']['sex']}'
                              : 'เพศ: หญิง', // Fallback ถ้าไม่มีข้อมูล
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ส่วนที่เหลือของ body
          Expanded(
            child: isLoading
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
                                style: const TextStyle(
                                    color: Colors.red, letterSpacing: -0.5),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  fetchScanHistory();
                                },
                                child: const Text('ลองใหม่',
                                    style: TextStyle(letterSpacing: -0.5)),
                              ),
                            ],
                          ),
                        ),
                      )
                    : scanHistory.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'ไม่พบประวัติการสแกน',
                                  style: TextStyle(
                                      fontSize: 16, letterSpacing: -0.5),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    fetchScanHistory();
                                  },
                                  child: const Text('รีเฟรช',
                                      style: TextStyle(letterSpacing: -0.5)),
                                ),
                              ],
                            ),
                          )
                        : SafeArea(
                            child: RefreshIndicator(
                              onRefresh: fetchScanHistory,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8.0),
                                child: ListView.builder(
                                  itemCount: scanHistory.length,
                                  itemBuilder: (context, index) {
                                    return _buildScanHistoryItem(index);
                                  },
                                ),
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanHistoryItem(int index) {
    final item = scanHistory[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => toggleExpand(index),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF12358F),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.insert_chart_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          item['date'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    item['isExpanded']
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
          if (item['isExpanded']) _buildExpandedContent(item),
        ],
      ),
    );
  }

  Widget _buildExpandedContent(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 23.0),
      child: Column(
        children: [
          // Eye Test Section (Pink Background)
          _buildEyeTestSection(item),

          // Eye Scan Section (Blue Background)
          _buildEyeScanSection(item),

          // Conclusion
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              item['conclusion'],
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEyeTestSection(Map<String, dynamic> item) {
    final eyeTest = item['eyeTest'];
    final leftEye = eyeTest['leftEye'];
    final rightEye = eyeTest['rightEye'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text moved outside the container
        const Text(
          'วัดค่าสายตา (Near Chart)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        // 2px gap between the text and container
        const SizedBox(height: 2),
        // Pink container without the title
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color(0xFFFBD6E3), // Light pink
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildEyeResult('ตาข้างซ้าย อยู่บรรทัดที่ ${leftEye['line']}',
                      leftEye['value'], leftEye['percentage']),
                  _buildEyeResult('ตาข้างขวา อยู่บรรทัดที่ ${rightEye['line']}',
                      rightEye['value'], rightEye['percentage']),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                eyeTest['result'],
                style: const TextStyle(
                  fontSize: 14,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEyeResult(String title, String value, double percentage) {
    final parts = value.split('/');
    final percentage = vaToPercentage(value);
    final progressColor = getColorForPercentage(percentage);

    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: percentage,
                  strokeWidth: 8,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      parts.isNotEmpty ? parts[0] : '0',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(
                      color: Colors.black,
                      thickness: 1,
                      indent: 25,
                      endIndent: 25,
                    ),
                    Text(
                      parts.length > 1 ? parts[1] : '0',
                      style: const TextStyle(
                        fontSize: 16,
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

  Widget _buildEyeScanSection(Map<String, dynamic> item) {
    final eyeScan = item['eyeScan'];
    final photos = eyeScan['photos'] ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        // Text moved outside the container
        const Text(
          'สแกนดวงตา',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            letterSpacing: -0.5,
          ),
        ),
        // 2px gap between the text and container
        const SizedBox(height: 2),
        // Blue container without the title
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color(0xFF3B5998), // Dark blue
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEyeScanGrid(photos),
              const SizedBox(height: 16),
              Text(
                eyeScan['result'],
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEyeScanGrid(Map<String, dynamic> photos) {
    // Extract photo URLs from the photos object if available

    return Column(
      children: [
        // Header row with "ตาซ้าย" and "ตาขวา" labels
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              // Empty space for left column label alignment
              const SizedBox(width: 70),
              // Left eye label
              Expanded(
                child: Center(
                  child: Text(
                    'ตาซ้าย',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
              // Right eye label
              Expanded(
                child: Center(
                  child: Text(
                    'ตาขวา',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // First row: Photos
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left label "ภาพถ่าย"
            SizedBox(
              width: 70,
              child: Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Text(
                  'ภาพถ่าย',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),
            // Left eye photo
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: _buildEyeImage('leftEye', scanHistory[0]),
              ),
            ),
            // Right eye photo
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: _buildEyeImage('rightEye', scanHistory[0]),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Second row: AI Images
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left label "ภาพจาก AI"
            SizedBox(
              width: 70,
              child: Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Text(
                  'ภาพจาก AI',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),
            // Left eye AI image
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: _buildEyeImage('leftEyeAI', scanHistory[0]),
              ),
            ),
            // Right eye AI image
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: _buildEyeImage('rightEyeAI', scanHistory[0]),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEyeImage(String? fileName, Map<String, dynamic> scanData) {
    // ตรวจสอบว่ามี eyeScan และ photos ใน scanData หรือไม่
    final eyeScan = scanData['eyeScan'] as Map<String, dynamic>?;
    final photos = eyeScan?['photos'] as Map<String, dynamic>?;

    // เลือก URL รูปภาพตาม fileName
    String? imageUrl;
    if (fileName != null && photos != null) {
      switch (fileName.toLowerCase()) {
        case 'lefteye':
          imageUrl = photos['leftEye'];
          break;
        case 'righteye':
          imageUrl = photos['rightEye'];
          break;
        case 'lefteyeai':
          imageUrl = photos['leftEyeAI'];
          break;
        case 'righteyeai':
          imageUrl = photos['rightEyeAI'];
          break;
      }
    }

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: imageUrl != null && imageUrl.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  httpHeaders: {
                    'Accept': 'image/jpeg, image/png, image/*',
                    'Cache-Control': 'max-age=86400', // 24 hours cache
                  },
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(color: Color(0xFF3B5998)),
                  ),
                  errorWidget: (context, url, error) => Center(
                    child: Icon(
                      Icons.remove_red_eye,
                      color: const Color(0xFF3B5998).withOpacity(0.5),
                      size: 24,
                    ),
                  ),
                ),
              )
            : Center(
                child: Icon(
                  Icons.remove_red_eye,
                  color: const Color(0xFF3B5998).withOpacity(0.5),
                  size: 24,
                ),
              ),
      ),
    );
  }
}
