import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:client/services/http_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScanHistoryService {
  // Helper function to safely convert dynamic maps to strongly typed maps
  static Map<String, dynamic> _safelyConvertMap(dynamic source) {
    if (source == null) return {};
    if (source is Map<String, dynamic>) return source;
    return Map<String, dynamic>.from(source as Map);
  }

  // Main function to fetch scan history for an ophthalmologist
  static Future<Map<String, dynamic>> getOphthScanHistory() async {
    try {
      // Get the conversation ID saved during navigation
      final prefs = await SharedPreferences.getInstance();
      final conversationId = prefs.getInt('conversation_id');
      
      if (conversationId == null) {
        return {'user': {}, 'scanHistory': []};
      }
      
      debugPrint('Fetching scan history for conversation ID: $conversationId');
      
      // Make API request
      final response = await HttpClient.get('/api/scanlog/ophtha/$conversationId');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          // Extract user data with null safety
          final userData = data['user'] ?? {};
          final user = _safelyConvertMap(userData);
          
          // Add fullName field
          user['fullName'] = '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}';
          
          // Process scan logs with type safety and ensure uniqueness
          final List<Map<String, dynamic>> processedLogs = [];
          final Set<String> processedIds = {}; // Track unique IDs
          
          if (data['scanlog'] is List) {
            final scanLogs = data['scanlog'] as List;
            
            // Sort logs by date (newest first) if available
            scanLogs.sort((a, b) {
              try {
                final dateA = a['date'] != null ? DateTime.parse(a['date'].toString()) : DateTime(1970);
                final dateB = b['date'] != null ? DateTime.parse(b['date'].toString()) : DateTime(1970);
                return dateB.compareTo(dateA); // Newest first
              } catch (e) {
                return 0; // If date comparison fails
              }
            });
            
            // Process each scan log with a unique ID marker
            for (int i = 0; i < scanLogs.length; i++) {
              try {
                final scan = scanLogs[i];
                // Check if we've already processed a scan with this ID
                final scanId = scan['id']?.toString() ?? '$i-${DateTime.now().microsecondsSinceEpoch}';
                
                if (!processedIds.contains(scanId)) {
                  processedIds.add(scanId); // Mark as processed
                  
                  final processedScan = _processScanData(scan);
                  // Add unique identifier
                  processedScan['uniqueId'] = scanId;
                  processedScan['uniqueIndex'] = i;
                  
                  processedLogs.add(processedScan);
                  debugPrint('Added unique scan: $scanId');
                } else {
                  debugPrint('Skipped duplicate scan: $scanId');
                }
              } catch (e) {
                debugPrint('Error processing scan: $e');
              }
            }
          }
          
          debugPrint('Processed ${processedLogs.length} unique scan logs');
          
          return {
            'user': user,
            'scanHistory': processedLogs,
          };
        }
      }
      return {'user': {}, 'scanHistory': []};
    } catch (e) {
      debugPrint('Error in getOphthScanHistory: $e');
      return {'user': {}, 'scanHistory': []};
    }
  }

  // Helper to format sex display
  static String _getSexDisplay(String? sex) {
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
  
  // Process an individual scan record
  static Map<String, dynamic> _processScanData(dynamic scan) {
    // Convert to proper Map<String, dynamic>
    final Map<String, dynamic> scanData = _safelyConvertMap(scan);
    
    // Add UI state
    scanData['isExpanded'] = false;
    
    // Create a unique conclusion for each item based on its data
    scanData['conclusion'] = scanData['description'] ?? 'ผลการตรวจ: ' + _formatDate(scanData['date'] ?? '');
    
    // Process VA (visual acuity) data
    if (scanData.containsKey('va')) {
      final vaMap = _safelyConvertMap(scanData['va']);
      
      if (vaMap.isNotEmpty) {
        final lineLeft = vaMap['line_left']?.toString() ?? '0';
        final lineRight = vaMap['line_right']?.toString() ?? '0';
        final vaLeft = vaMap['va_left']?.toString() ?? '0/0';
        final vaRight = vaMap['va_right']?.toString() ?? '0/0';
        final description = vaMap['description']?.toString() ?? 'ไม่มีข้อมูล';
        
        // Format VA data to match expected eyeTest structure
        scanData['eyeTest'] = {
          'leftEye': {
            'line': lineLeft,
            'value': vaLeft,
            'percentage': _vaToPercentage(vaLeft),
          },
          'rightEye': {
            'line': lineRight,
            'value': vaRight,
            'percentage': _vaToPercentage(vaRight),
          },
          'result': description,
        };
      } else {
        scanData['eyeTest'] = _getDefaultEyeTestData();
      }
    } else {
      scanData['eyeTest'] = _getDefaultEyeTestData();
    }
    
    // Process photo data
    if (scanData.containsKey('photo')) {
      final photoMap = _safelyConvertMap(scanData['photo']);
      
      // Format photo data to match expected eyeScan structure
      scanData['eyeScan'] = {
        'photos': {
          'leftEye': photoMap['left_eye'] ?? '',
          'rightEye': photoMap['right_eye'] ?? '',
          'leftEyeAI': photoMap['ai_left'] ?? '',
          'rightEyeAI': photoMap['ai_right'] ?? '',
        },
        'description': photoMap['description'] ?? 'ไม่มีคำอธิบาย',
      };
    } else {
      scanData['eyeScan'] = {
        'photos': {},
        'description': 'ไม่มีข้อมูลภาพ',
      };
    }
    
    // Format date
    try {
      if (scanData.containsKey('date') && scanData['date'] != null) {
        final date = scanData['date'] is String 
            ? DateTime.parse(scanData['date']) 
            : DateTime.fromMillisecondsSinceEpoch(scanData['date']);
        
        scanData['formattedDate'] = _formatDate(date.toIso8601String());
      } else {
        scanData['formattedDate'] = 'ไม่มีข้อมูลวันที่';
      }
    } catch (e) {
      scanData['formattedDate'] = 'ไม่มีข้อมูลวันที่';
    }
    
    return scanData;
  }
  
  // Helper function to convert VA value to percentage
  static double _vaToPercentage(String va) {
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
  
  // Helper function to get default eye test data
  static Map<String, dynamic> _getDefaultEyeTestData() {
    return {
      'leftEye': {
        'line': '0',
        'value': '0/0',
        'percentage': 0.0,
      },
      'rightEye': {
        'line': '0',
        'value': '0/0',
        'percentage': 0.0,
      },
      'result': 'ไม่มีข้อมูลผลการวัดสายตา',
    };
  }
  
  // Helper function to format date
  static String _formatDate(String dateString) {
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
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');

      return 'วันที่ $day $month พ.ศ. $thaiYear เวลา $hour:$minute น.';
    } catch (e) {
      return dateString;
    }
  }
}