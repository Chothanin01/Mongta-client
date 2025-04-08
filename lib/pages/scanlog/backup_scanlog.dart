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

  // Original functions that you have...
  double vaToPercentage(String va) {
    // Keep existing implementation
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
    // Keep existing implementation
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
      // Use HttpClient instead of direct http call
      final response = await HttpClient.get('/api/scanlog/$_userId');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('API Response: ${json.encode(data)}'); // Debug print

        if (data['success'] == true) {
          final List<dynamic> scanLogs = data['scanlog'];
          print('Scan logs count: ${scanLogs.length}');

          setState(() {
            scanHistory = scanLogs.map<Map<String, dynamic>>((scan) {
              // Keep your existing data processing logic
              print('Processing scan: ${json.encode(scan)}'); // Debug each scan

              // Parse the scan data from API to match our UI format
              final Map<String, dynamic> scanData = {
                'id': scan['id'],
                'title': 'ประวัติการสแกน',
                'date': _formatDate(scan['date'] ?? scan['created_at'] ?? DateTime.now().toIso8601String()),
                'isExpanded': true, // Set to true to show expanded by default
                'description': scan['description'] ?? '',
              };

              // Keep your existing VA data processing logic
              if (scan['va'] != null) {
                try {
                  final va = scan['va'];
                  // Rest of your existing VA processing code
                  // ...
                  
                  // Convert string JSON to Map if needed
                  Map<String, dynamic> vaMap;
                  if (va is String) {
                    try {
                      vaMap = json.decode(va) as Map<String, dynamic>;
                    } catch (e) {
                      print('Error parsing VA string: $e');
                      vaMap = {};
                    }
                  } else if (va is Map) {
                    // Cast Map<dynamic, dynamic> to Map<String, dynamic>
                    vaMap = Map<String, dynamic>.from(va);
                  } else {
                    print('VA is neither string nor map: ${va.runtimeType}');
                    vaMap = {};
                  }

                  // Now process the VA map based on the actual API structure
                  if (vaMap.isNotEmpty) {
                    // Extract values from the API response
                    final vaLeft = vaMap['va_left'] ?? '0/0';
                    final vaRight = vaMap['va_right'] ?? '0/0';
                    final lineLeft = vaMap['line_left'] ?? '0';
                    final lineRight = vaMap['line_right'] ?? '0';
                    final description =
                        vaMap['description'] ?? 'ไม่มีข้อมูลผลการวัดสายตา';

                    // Convert VA values to percentages
                    double percentageLeft = _convertVAToPercentage(vaLeft);
                    double percentageRight = _convertVAToPercentage(vaRight);

                    // Create eye data objects with the correct structure
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

              // Keep your existing photo data processing logic
              try {
                var photos = scan['photo'];
                // Rest of your existing photo processing code
                // ...
                
                // Convert string JSON to Map if needed
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

                // Map the API photo structure to our UI structure
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

              // Add conclusion
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
        // Unauthorized - handle token expiration
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
        'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
        'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'
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
                context.go('/home'); // Navigate directly to home
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
                            color: MainTheme.resultRed, 
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
        color: MainTheme.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: MainTheme.logGrey.withOpacity(0.1),
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
                      color: MainTheme.white,
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
                            color: MainTheme.logGrey2,
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
                    color: MainTheme.logGrey2,
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
                color: MainTheme.logBlack,
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
            fontFamily: 'BaiJamjuree',
          ),
        ),
        // 2px gap between the text and container
        const SizedBox(height: 2),
        // Pink container without the title
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12.0), // Reduced padding
          decoration: BoxDecoration(
            color: const Color(0xFFFBD6E3), // Light pink
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Wrap the Row in a LayoutBuilder to control sizing
              LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = constraints.maxWidth / 2 - 8;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: itemWidth,
                        child: _buildEyeResult(
                          'ตาข้างซ้าย อยู่บรรทัดที่ ${leftEye['line']}',
                          leftEye['value'], 
                          leftEye['percentage']
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: _buildEyeResult(
                          'ตาข้างขวา อยู่บรรทัดที่ ${rightEye['line']}',
                          rightEye['value'], 
                          rightEye['percentage']
                        ),
                      ),
                    ],
                  );
                }
              ),
              const SizedBox(height: 12), // Reduced space
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
            fontFamily: 'BaiJamjuree',
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
                  backgroundColor: MainTheme.resultGrey,
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
                      color: MainTheme.black,
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
            color: MainTheme.black,
            letterSpacing: -0.5,
            fontFamily: 'BaiJamjuree',
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
                  color: MainTheme.white,
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
    final leftEyePhoto = photos['leftEye'];
    final rightEyePhoto = photos['rightEye'];
    final leftEyeAI = photos['leftEyeAI'];
    final rightEyeAI = photos['rightEyeAI'];

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
                      color: MainTheme.white,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.5,
                      fontFamily: 'BaiJamjuree',
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
                      color: MainTheme.white,
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
                    color: MainTheme.white,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.5,
                    fontFamily: 'BaiJamjuree',
                  ),
                ),
              ),
            ),
            // Left eye photo
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: _buildEyeImage(leftEyePhoto),
              ),
            ),
            // Right eye photo
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: _buildEyeImage(rightEyePhoto),
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
                    color: MainTheme.white,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.5,
                    fontFamily: 'BaiJamjuree',
                  ),
                ),
              ),
            ),
            // Left eye AI image
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: _buildEyeImage(leftEyeAI),
              ),
            ),
            // Right eye AI image
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
    // If fileName is null or empty, show placeholder
    if (fileName == null || fileName.isEmpty) {
      return Center(
        child: Icon(Icons.remove_red_eye,
            color: const Color(0xFF3B5998).withOpacity(0.5), size: 24),
      );
    }
    
    // Check if fileName is already a URL (starts with http)
    final bool isUrl = fileName.startsWith('http');
    final String imageUrl = isUrl ? fileName : '';

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: MainTheme.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: isUrl
            ? GestureDetector(
                onTap: () {
                  // Show fullscreen image when tapped
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
      backgroundColor: MainTheme.black,
      appBar: AppBar(
        backgroundColor: MainTheme.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: MainTheme.white),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 3.0,
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.contain,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(color: MainTheme.white),
            ),
            errorWidget: (context, url, error) => const Center(
              child: Icon(Icons.error_outline, color: MainTheme.resultRed, size: 50),
            ),
          ),
        ),
      ),
    );
  }
}