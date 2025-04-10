import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:client/services/scan_history_service.dart';
import 'package:client/services/http_client.dart';

class ScanHistoryScreen extends StatefulWidget {
  const ScanHistoryScreen({Key? key}) : super(key: key);

  @override
  State<ScanHistoryScreen> createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen> {
  bool isLoading = true;
  String errorMessage = '';
  List<Map<String, dynamic>> scanHistory = [];
  String userName = '';

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
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
        scanHistory = []; // Clear existing data
      });
      
      // Get the conversation ID saved during navigation
      final prefs = await SharedPreferences.getInstance();
      final conversationId = prefs.getInt('conversation_id');
      
      if (conversationId == null) {
        setState(() {
          errorMessage = 'No conversation ID found';
          isLoading = false;
        });
        return;
      }
      
      // Make API request directly like in scanlog.dart
      final response = await HttpClient.get('/api/scanlog/ophtha/$conversationId');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('API Response: ${jsonEncode(data)}'); // Debug print
        
        if (data['success'] == true) {
          if (mounted) {
            setState(() {
              // Store user data directly
              final userData = data['user'] ?? {};
              
              // Process the scanlog EXACTLY as it comes from API without manipulation
              final rawScanLogs = data['scanlog'] as List? ?? [];
              
              // Simply map each scan log to a Map without any extra manipulation
              scanHistory = rawScanLogs.map((item) {
                // Create a direct copy of the scan item
                final Map<String, dynamic> scanItem = Map<String, dynamic>.from(item);
                
                // Only add these essential fields but don't manipulate the original data
                scanItem['isExpanded'] = false;
                scanItem['user'] = userData;
                
                // Process date if available
                if (scanItem.containsKey('date') && scanItem['date'] != null) {
                  final date = scanItem['date'] is String 
                      ? DateTime.parse(scanItem['date']) 
                      : DateTime.fromMillisecondsSinceEpoch(scanItem['date']);
                  scanItem['formattedDate'] = _formatDate(date.toIso8601String());
                }
                
                return scanItem;
              }).toList();
              
              isLoading = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              errorMessage = data['message'] ?? 'Failed to fetch scan logs';
              isLoading = false;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            errorMessage = 'API Error: ${response.statusCode}';
            isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching scan history: $e');
      if (mounted) {
        setState(() {
          errorMessage = 'Error: $e';
          isLoading = false;
        });
      }
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

  static Map<String, dynamic> _safelyConvertMap(dynamic data) {
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    } else {
      // Return an empty map if the data is not a map
      return <String, dynamic>{};
    }
  }
  
  static Map<String, dynamic> _processScanData(dynamic scan) {
    // Convert to proper Map<String, dynamic>
    final Map<String, dynamic> scanData = _safelyConvertMap(scan);
    
    // Ensure each scan item has an ID
    if (!scanData.containsKey('id')) {
      scanData['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    }
    
    // Add UI state
    scanData['isExpanded'] = false;
    
    // Rest of your processing...
    
    return scanData;
  }

  @override
  Widget build(BuildContext context) {
    // Extract user data with complete null safety at the beginning
    final bool hasData = scanHistory.isNotEmpty && scanHistory[0] != null;
    
    // Create a local user map with null safety
    final Map<String, dynamic>? userData = hasData ? scanHistory[0]['user'] as Map<String, dynamic>? : null;
    
    // Extract individual properties safely
    final String profilePicture = userData?['profile_picture'] ?? '';
    final String firstName = userData?['first_name'] ?? '';
    final String lastName = userData?['last_name'] ?? '';
    final String fullName = userData?['fullName'] ?? '$firstName $lastName';
    final String displayName = fullName.isNotEmpty ? fullName : 'คุณ แก้วตา ฟ้าประทานพร';
    
    // Parse age safely
    final dynamic rawAge = userData?['age'];
    final String ageDisplay = rawAge != null ? 'อายุ: $rawAge ปี' : 'อายุ: 40 ปี';
    
    // Parse sex safely
    final String sexValue = userData?['sex'] ?? 'หญิง';
    final String sexDisplay = 'เพศ: $sexValue';

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
                      child: profilePicture.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              profilePicture,
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Text(
                                  'ภพ', // Fallback if image load fails
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
                            'ภพ', // Fallback if no profilePicture
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
                          displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ageDisplay,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          sexDisplay,
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

    // Create variables with default values for missing fields
    final String itemTitle = item['formattedDate'] ?? 'ผลการตรวจวันที่ไม่ระบุ';
    final String itemDate = item['formattedDate'] ?? 'ไม่มีข้อมูลวันที่';
    final bool isExpanded = item['isExpanded'] ?? false;

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
                          "ผลการตรวจวัดสายตา", // Fixed title instead of using dynamic data
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          itemDate,
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
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) _buildExpandedContent(item),
        ],
      ),
    );
  }

  Widget _buildExpandedContent(Map<String, dynamic> item) {
    // Debug the exact item being expanded
    debugPrint('Building expanded content for scan ID: ${item['id']}');
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 23.0),
      child: Column(
        children: [
          // Eye Test Section (Visual Acuity/VA data)
          if (item.containsKey('va')) _buildEyeTestSection(item),
          
          // Eye Scan Section (Photos)
          if (item.containsKey('photo')) _buildEyeScanSection(item),
          
          // Description/Conclusion
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              item['description'] ?? 'ไม่มีผลวิเคราะห์',
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
    // Process VA data from the API structure which uses 'va' key
    final va = item['va'] as Map<String, dynamic>? ?? {};
    
    final leftEyeValue = va['va_left'] ?? '0/0';
    final rightEyeValue = va['va_right'] ?? '0/0';
    final leftEyeLine = va['line_left'] ?? '0';
    final rightEyeLine = va['line_right'] ?? '0';
    
    final leftPercentage = _convertVAToPercentage(leftEyeValue);
    final rightPercentage = _convertVAToPercentage(rightEyeValue);
    final description = va['description'] ?? 'ไม่มีข้อมูล';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        // Text header for this section
        const Text(
          'การวัดสายตา',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            letterSpacing: -0.5,
          ),
        ),
        // 2px gap
        const SizedBox(height: 2),
        // Pink container
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color(0xFFF9CDCF), // Light pink
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              // Results label
              const Text(
                'ผลการตรวจวัดสายตา',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Eye results row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Use _buildEyeResult for left eye
                  _buildEyeResult(
                    'ตาซ้าย',
                    leftEyeValue,
                    leftPercentage,
                  ),
                  
                  // Use _buildEyeResult for right eye
                  _buildEyeResult(
                    'ตาขวา',
                    rightEyeValue,
                    rightPercentage,
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Description
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
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

  Widget _buildEyeScanSection(Map<String, dynamic> item) {
    // Process photo data from the API structure which uses 'photo' key
    final photo = item['photo'] as Map<String, dynamic>? ?? {};
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        // Text header for this section
        const Text(
          'สแกนดวงตา',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            letterSpacing: -0.5,
          ),
        ),
        // 2px gap
        const SizedBox(height: 2),
        // Blue container
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
              // Pass the CURRENT item's photo data, not scanHistory[0]
              _buildEyeScanGrid(photo, item),
              
              const SizedBox(height: 16),
              
              // Description
              Text(
                photo['description'] ?? 'ไม่มีผลการวิเคราะห์',
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

  // Update method signature to also receive the entire item
  Widget _buildEyeScanGrid(Map<String, dynamic> photos, Map<String, dynamic> item) {
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
                child: const Center(
                  child: Text(
                    'ตาซ้าย',
                    style: TextStyle(
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
                child: const Center(
                  child: Text(
                    'ตาขวา',
                    style: TextStyle(
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
            // Left eye photo - Pass the current item, not scanHistory[0]
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: _buildEyeImage('lefteye', item),
              ),
            ),
            // Right eye photo
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: _buildEyeImage('righteye', item),
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
                child: _buildEyeImage('lefteyeai', item),
              ),
            ),
            // Right eye AI image
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: _buildEyeImage('righteyeai', item),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEyeImage(String? eyeType, Map<String, dynamic> scanData) {
    // Get photo data directly from the API structure
    final photoData = scanData['photo'] as Map<String, dynamic>? ?? {};
    
    // Map the eyeType parameter to the correct field in the API response
    String? imageUrl;
    switch (eyeType?.toLowerCase()) {
      case 'lefteye':
        imageUrl = photoData['left_eye'];
        break;
      case 'righteye':
        imageUrl = photoData['right_eye'];
        break;
      case 'lefteyeai':
        imageUrl = photoData['ai_left'];
        break;
      case 'righteyeai':
        imageUrl = photoData['ai_right'];
        break;
    }
    
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: imageUrl != null && imageUrl.isNotEmpty
            ? GestureDetector(
                onTap: () {
                  // Show fullscreen image when tapped
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullscreenImageViewer(imageUrl: imageUrl ?? ''),
                    ),
                  );
                },
                child: ClipRRect(
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
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.contain,
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(color: Color(0xFF3B5998)),
          ),
          errorWidget: (context, url, error) => const Icon(
            Icons.error_outline,
            color: Colors.white,
            size: 48,
          ),
        ),
      ),
    );
  }
}