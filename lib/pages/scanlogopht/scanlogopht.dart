import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:client/services/http_client.dart';
import 'package:client/services/user_service.dart';
import 'package:go_router/go_router.dart';

class ScanHistoryScreen extends StatefulWidget {
  const ScanHistoryScreen({Key? key}) : super(key: key);

  @override
  State<ScanHistoryScreen> createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen> {
  bool isLoading = true;
  String errorMessage = '';
  List<Map<String, dynamic>> scanHistory = [];
  int? conversationId;

  final ThemeData theme = ThemeData(
    primarySwatch: Colors.blue,
    fontFamily: 'BaiJamjuree',
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
  );

  @override
  void initState() {
    super.initState();
    _loadConversationIdAndFetchData();
  }

  Future<void> _loadConversationIdAndFetchData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      conversationId = prefs.getInt('conversation_id');

      if (conversationId == null) {
        setState(() {
          errorMessage = 'Cannot find conversation ID';
          isLoading = false;
        });
        return;
      }

      fetchScanHistory();
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading data: $e';
        isLoading = false;
      });
    }
  }

  double vaToPercentage(String va) {
    final Map<String, double> vaPercentages = {
      '20/200': 0.1,
      '20/100': 0.2,
      '20/70': 0.3,
      '20/50': 0.4,
      '20/40': 0.5,
      '20/30': 0.6,
      '20/25': 0.7,
      '20/20': 1.0,
    };

    return vaPercentages[va] ?? 0.0;
  }

  Color getColorForPercentage(double percentage) {
    if (percentage <= 0.3) {
      return Colors.red;
    } else if (percentage <= 0.6) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  Future<void> fetchScanHistory() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await HttpClient.get('/api/scanlog/ophtha/$conversationId');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('API Response: ${json.encode(data)}');

        if (data['success'] == true) {
          final List<dynamic> scanLogs = data['scanlog'];
          final Map<String, dynamic> userData = data['user'];
          print('Scan logs count: ${scanLogs.length}');

          final fullName = _getFullNameWithPrefix(
            userData['first_name'] ?? '',
            userData['last_name'] ?? '',
            userData['is_opthamologist'] as bool?,
            userData['sex'] as String?,
          );
          final sexDisplay = _getSexDisplay(userData['sex'] as String?);
          final age = _calculateAge(userData['date_of_birth'] as String);
          final profilePicture = userData['profile_picture'] as String?;

          print('User Full Name: $fullName, Sex: $sexDisplay, Age: $age, Profile Picture: $profilePicture');

          setState(() {
            scanHistory = scanLogs.map<Map<String, dynamic>>((scan) {
              print('Processing scan: ${json.encode(scan)}');

              final Map<String, dynamic> scanData = {
                'id': scan['id'],
                'title': 'ประวัติการสแกน',
                'date': _formatDate(scan['date']),
                'isExpanded': true,
                'description': scan['description'] ?? '',
                'user': {
                  'fullName': fullName,
                  'sex': sexDisplay,
                  'age': age,
                  'profilePicture': profilePicture,
                },
              };

              if (scan['va'] != null) {
                try {
                  final va = scan['va'];
                  print('VA data: ${json.encode(va)}');

                  final eyeTest = {
                    'leftEye': {
                      'line': va['line_left'] ?? 0,
                      'value': va['va_left'] ?? '0/0',
                      'percentage': _convertVAToPercentage(va['va_left'] ?? '0/0'),
                    },
                    'rightEye': {
                      'line': va['line_right'] ?? 0,
                      'value': va['va_right'] ?? '0/0',
                      'percentage': _convertVAToPercentage(va['va_right'] ?? '0/0'),
                    },
                  };
                  scanData['eyeTest'] = eyeTest;
                } catch (e) {
                  print('Error processing VA data: $e');
                  scanData['eyeTest'] = {
                    'leftEye': _getDefaultEyeData(),
                    'rightEye': _getDefaultEyeData(),
                  };
                }
              } else {
                scanData['eyeTest'] = {
                  'leftEye': _getDefaultEyeData(),
                  'rightEye': _getDefaultEyeData(),
                };
              }

              if (scan['photos'] != null) {
                try {
                  final photos = scan['photos'];
                  scanData['eyeScan'] = {
                    'photos': {
                      'leftEye': photos['left_eye'] ?? '',
                      'rightEye': photos['right_eye'] ?? '',
                      'leftEyeAI': photos['left_eye_ai'] ?? '',
                      'rightEyeAI': photos['right_eye_ai'] ?? '',
                    }
                  };
                } catch (e) {
                  print('Error processing photo data: $e');
                  scanData['eyeScan'] = {
                    'photos': {}
                  };
                }
              } else {
                scanData['eyeScan'] = {
                  'photos': {}
                };
              }

              return scanData;
            }).toList();
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = data['message'] ?? 'Unknown error';
            isLoading = false;
          });
        }
      } else if (response.statusCode == 401) {
        await UserService.logout();
        setState(() {
          errorMessage = 'Session expired. Please log in again.';
          isLoading = false;
        });

        if (context.mounted) {
          context.go('/login');
        }
      } else {
        setState(() {
          errorMessage = 'Server error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Network error: $e');
      setState(() {
        errorMessage = 'Network error: $e';
        isLoading = false;
      });
    }
  }

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

  Map<String, dynamic> _getDefaultEyeData() {
    return {
      'line': 0,
      'value': '0/0',
      'percentage': 0.0,
    };
  }

  double _convertVAToPercentage(String vaValue) {
    try {
      final parts = vaValue.split('/');
      if (parts.length == 2) {
        final numerator = double.parse(parts[0]);
        final denominator = double.parse(parts[1]);

        if (denominator == 0) return 0.0;

        if (numerator == 20) {
          return 20 / denominator;
        } else {
          return 0.5;
        }
      }

      final lineNumber = double.parse(vaValue);
      return lineNumber / 10.0;
    } catch (e) {
      print('Error converting VA to percentage: $e');
      return 0.5;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final thaiYear = date.year + 543;
      const thaiMonths = [
        'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
        'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'
      ];
      final day = date.day;
      final month = thaiMonths[date.month - 1];
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');

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
    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'ประวัติการสแกน',
            style: TextStyle(color: Colors.black),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => context.pop(),
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
                ? Center(child: Text(errorMessage))
                : scanHistory.isEmpty
                    ? const Center(child: Text('ไม่พบประวัติการสแกน'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: scanHistory.length,
                        itemBuilder: (context, index) {
                          return _buildScanHistoryItem(index);
                        },
                      ),
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => toggleExpand(index),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomLeft: item['isExpanded'] ? Radius.zero : Radius.circular(12),
                  bottomRight: item['isExpanded'] ? Radius.zero : Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item['title'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        item['date'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        item['isExpanded'] ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: Colors.grey[700],
                      ),
                    ],
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundImage: item['user']['profilePicture'] != null && 
                                 item['user']['profilePicture'].isNotEmpty
                    ? NetworkImage(item['user']['profilePicture'])
                    : null,
                child: item['user']['profilePicture'] == null || 
                       item['user']['profilePicture'].isEmpty
                    ? Icon(Icons.person, size: 30)
                    : null,
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['user']['fullName'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'เพศ: ${item['user']['sex']} | อายุ: ${item['user']['age']} ปี',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          if (item.containsKey('eyeTest'))
            _buildEyeTestSection(item),
          if (item.containsKey('eyeScan'))
            _buildEyeScanSection(item),
          if (item['description'] != null && item['description'].isNotEmpty) ...[
            SizedBox(height: 16),
            Text(
              'หมายเหตุ',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              item['description'],
              style: TextStyle(fontSize: 14),
            ),
          ],
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
        const Text(
          'ผลการวัดค่าสายตา',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.pink[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildEyeResult('ตาซ้าย', leftEye['value'], leftEye['percentage']),
              _buildEyeResult('ตาขวา', rightEye['value'], rightEye['percentage']),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEyeResult(String title, String value, double percentage) {
    final color = getColorForPercentage(percentage);

    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 100,
          height: 100,
          child: Stack(
            children: [
              Center(
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: percentage,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${(percentage * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
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
        const Text(
          'ภาพถ่ายดวงตา',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: _buildEyeScanGrid(photos),
        ),
      ],
    );
  }

  Widget _buildEyeScanGrid(Map<String, dynamic> photos) {
    final leftEyePhoto = photos['leftEye'];
    final rightEyePhoto = photos['rightEye'];
    final leftEyeAI = photos['leftEyeAI'];
    final rightEyeAI = photos['rightEyeAI'];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text('ตาซ้าย (ต้นฉบับ)', style: TextStyle(fontSize: 12)),
                SizedBox(height: 4),
                GestureDetector(
                  onTap: leftEyePhoto != null && leftEyePhoto.isNotEmpty
                      ? () => _showFullImage(leftEyePhoto)
                      : null,
                  child: _buildEyeImage(leftEyePhoto),
                ),
              ],
            ),
            Column(
              children: [
                Text('ตาขวา (ต้นฉบับ)', style: TextStyle(fontSize: 12)),
                SizedBox(height: 4),
                GestureDetector(
                  onTap: rightEyePhoto != null && rightEyePhoto.isNotEmpty
                      ? () => _showFullImage(rightEyePhoto)
                      : null,
                  child: _buildEyeImage(rightEyePhoto),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text('ตาซ้าย (AI วิเคราะห์)', style: TextStyle(fontSize: 12)),
                SizedBox(height: 4),
                GestureDetector(
                  onTap: leftEyeAI != null && leftEyeAI.isNotEmpty
                      ? () => _showFullImage(leftEyeAI)
                      : null,
                  child: _buildEyeImage(leftEyeAI),
                ),
              ],
            ),
            Column(
              children: [
                Text('ตาขวา (AI วิเคราะห์)', style: TextStyle(fontSize: 12)),
                SizedBox(height: 4),
                GestureDetector(
                  onTap: rightEyeAI != null && rightEyeAI.isNotEmpty
                      ? () => _showFullImage(rightEyeAI)
                      : null,
                  child: _buildEyeImage(rightEyeAI),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEyeImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.image_not_supported, color: Colors.grey),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[200],
          child: Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[200],
          child: Icon(Icons.error, color: Colors.red),
        ),
      ),
    );
  }

  void _showFullImage(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullscreenImageViewer(imageUrl: imageUrl),
      ),
    );
  }
}

class FullscreenImageViewer extends StatelessWidget {
  final String imageUrl;

  const FullscreenImageViewer({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          boundaryMargin: EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 4,
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.error, color: Colors.red),
          ),
        ),
      ),
    );
  }
}