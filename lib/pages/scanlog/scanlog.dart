import 'dart:convert';
import 'package:client/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:client/services/user_service.dart';
import 'package:client/services/http_client.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

class ScanlogPage extends StatefulWidget {
  const ScanlogPage({Key? key}) : super(key: key);

  @override
  State<ScanlogPage> createState() => _ScanlogPageState();
}

class _ScanlogPageState extends State<ScanlogPage> {
  bool isLoading = true;
  String errorMessage = '';
  List<Map<String, dynamic>> scanHistory = [];
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _loadUserAndFetchData();
  }
  
  Future<void> _loadUserAndFetchData() async {
    try {
      final userId = await UserService.getCurrentUserId();
      if (userId.isEmpty) {
        setState(() {
          errorMessage = 'ไม่พบข้อมูลผู้ใช้ กรุณาเข้าสู่ระบบใหม่อีกครั้ง';
          isLoading = false;
        });
        return;
      }
      
      setState(() {
        _userId = userId;
      });
      
      fetchScanHistory();
    } catch (e) {
      setState(() {
        errorMessage = 'เกิดข้อผิดพลาด: $e';
        isLoading = false;
      });
    }
  }

  double vaToPercentage(String va) {
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

  Color getColorForPercentage(double percentage) {
    if (percentage <= 0.3) {
      return MainTheme.resultRed; // Poor vision
    } else if (percentage <= 0.6) {
      return MainTheme.resultOrange; // Moderate vision
    } else {
      return MainTheme.resultGreen; // Good vision
    }
  }

  Future<void> fetchScanHistory() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await HttpClient.get('/api/scanlog/$_userId');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('API Response: ${json.encode(data)}'); // Debug print

        if (data['success'] == true) {
          final List<dynamic> scanLogs = data['scanlog'];
          print('Scan logs count: ${scanLogs.length}');

          setState(() {
            scanHistory = scanLogs.map<Map<String, dynamic>>((scan) {
              print('Processing scan: ${json.encode(scan)}'); // Debug each scan

              final Map<String, dynamic> scanData = {
                'id': scan['id'],
                'title': 'ประวัติการสแกน',
                'date': _formatDate(scan['date'] ?? scan['created_at'] ?? DateTime.now().toIso8601String()),
                'isExpanded': true,
                'description': scan['description'] ?? '',
              };

              if (scan['va'] != null) {
                try {
                  final va = scan['va'];
                  
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

              try {
                var photos = scan['photo'];
                
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
                  print('Photo is neither string nor map: ${photos.runtimeType}');
                  photoMap = {};
                }

                final mappedPhotos = {
                  'leftEye': photoMap['left_eye'],
                  'rightEye': photoMap['right_eye'],
                  'leftEyeAI': photoMap['ai_left'],
                  'rightEyeAI': photoMap['ai_right'],
                  'description': photoMap['description'] ?? 'ไม่มีข้อมูลผลการสแกนดวงตา',
                };

                scanData['eyeScan'] = {
                  'photos': mappedPhotos,
                  'result': photoMap['description'] ?? scan['description'] ?? 'ไม่มีข้อมูลผลการสแกนดวงตา',
                };
              } catch (e) {
                print('Error parsing photo data: $e');
                scanData['eyeScan'] = {
                  'photos': {},
                  'result': scan['description'] ?? 'ไม่มีข้อมูลผลการสแกนดวงตา',
                };
              }

              scanData['conclusion'] = scan['description'] ?? 'ไม่มีข้อมูลสรุปผล';

              return scanData;
            }).toList();
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = data['message'] ?? 'ไม่สามารถโหลดประวัติการสแกนได้';
            isLoading = false;
          });
        }
      } else if (response.statusCode == 401) {
        await UserService.logout();
        setState(() {
          errorMessage = 'กรุณาเข้าสู่ระบบใหม่';
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'เซิร์ฟเวอร์ผิดพลาด: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Network error: $e'); // Debug print
      setState(() {
        errorMessage = 'การเชื่อมต่อผิดพลาด: $e';
        isLoading = false;
      });
    }
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
          return numerator / denominator;
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
    return Scaffold(
      backgroundColor: MainTheme.mainBackground,
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(kToolbarHeight + 30),
        child: Container(
          padding: const EdgeInsets.only(top: 30),
          child: AppBar(
            backgroundColor: MainTheme.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios,
                  color: MainTheme.black, size: 20),
              onPressed: () {
                context.go('/home');
              },
            ),
            title: const Text(
              'ประวัติการสแกน',
              style: TextStyle(
                color: MainTheme.black,
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
                          style: const TextStyle(
                            color: MainTheme.redWarning, 
                            letterSpacing: -0.5,
                            fontFamily: 'BaiJamjuree',
                          ),
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
                              fontSize: 16, 
                              letterSpacing: -0.5,
                              fontFamily: 'BaiJamjuree',
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              fetchScanHistory();
                            },
                            child: const Text('รีเฟรช',
                                style: TextStyle(
                                  letterSpacing: -0.5,
                                  fontFamily: 'BaiJamjuree',
                                )),
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
                      Icons.insert_chart,
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
                            fontFamily: 'BaiJamjuree',
                          ),
                        ),
                        Text(
                          item['date'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            letterSpacing: -0.5,
                            fontFamily: 'BaiJamjuree',
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
          _buildEyeTestSection(item),
          _buildEyeScanSection(item),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              item['conclusion'],
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                letterSpacing: -0.5,
                fontFamily: 'BaiJamjuree',
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
    final screenWidth = MediaQuery.of(context).size.width;
    final eyeSize = screenWidth * 0.2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'วัดค่าสายตา (Near Chart)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            fontFamily: 'BaiJamjuree',
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: const Color(0xFFFBD6E3),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildEyeResult(
                    'ตาข้างซ้าย อยู่บรรทัดที่ ${leftEye['line']}',
                    leftEye['value'],
                    eyeSize,
                  ),
                  _buildEyeResult(
                    'ตาข้างขวา อยู่บรรทัดที่ ${rightEye['line']}',
                    rightEye['value'],
                    eyeSize,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                eyeTest['result'],
                style: const TextStyle(
                  fontSize: 14,
                  letterSpacing: -0.5,
                  fontFamily: 'BaiJamjuree',
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEyeResult(String title, String value, double eyeSize) {
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
            fontFamily: 'BaiJamjuree',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: eyeSize,
          height: eyeSize,
          child: Stack(
            children: [
              SizedBox(
                width: eyeSize,
                height: eyeSize,
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
        const Text(
          'สแกนดวงตา',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            letterSpacing: -0.5,
            fontFamily: 'BaiJamjuree',
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color(0xFF3B5998),
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
    final leftEyePhoto = photos['leftEye'];
    final rightEyePhoto = photos['rightEye'];
    final leftEyeAI = photos['leftEyeAI'];
    final rightEyeAI = photos['rightEyeAI'];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              const SizedBox(width: 70),
              Expanded(
                child: Center(
                  child: Text(
                    'ตาซ้าย',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.5,
                      fontFamily: 'BaiJamjuree',
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'ตาขวา',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.5,
                      fontFamily: 'BaiJamjuree',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    fontFamily: 'BaiJamjuree',
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: _buildEyeImage(leftEyePhoto),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: _buildEyeImage(rightEyePhoto),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    fontFamily: 'BaiJamjuree',
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: _buildEyeImage(leftEyeAI),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: _buildEyeImage(rightEyeAI),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEyeImage(String? fileName) {
    if (fileName == null || fileName.isEmpty) {
      return Center(
        child: Icon(Icons.remove_red_eye,
            color: const Color(0xFF3B5998).withOpacity(0.5), size: 24),
      );
    }
    
    final bool isUrl = fileName.startsWith('http');
    final String imageUrl = isUrl ? fileName : '';

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: isUrl
            ? GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullscreenImageViewer(imageUrl: imageUrl),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(color: Color(0xFF3B5998)),
                    ),
                    errorWidget: (context, url, error) {
                      debugPrint('Error loading image from $url: $error');
                      return Center(
                        child: Icon(Icons.broken_image,
                            color: const Color(0xFF3B5998).withOpacity(0.5),
                            size: 24),
                      );
                    },
                  ),
                ),
              )
            : Center(
                child: Icon(Icons.remove_red_eye,
                    color: const Color(0xFF3B5998).withOpacity(0.5), size: 24),
              ),
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
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 3.0,
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.contain,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            errorWidget: (context, url, error) => const Center(
              child: Icon(Icons.error_outline, color: Colors.red, size: 50),
            ),
          ),
        ),
      ),
    );
  }
}