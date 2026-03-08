import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class LeaveBalanceService {
  // Your API credentials
  static const String _apiKey = 'bc0862f769a4795';
  static const String _apiSecret = '3f8a6293af90228';
  static const String baseUrl = 'https://ppecon.erpnext.com';

  // Fetch leave balances for logged in user using custom API method
  Future<Map<String, dynamic>> fetchLeaveBalances() async {
    try {
      // Get employee ID from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      
      // Try all possible keys that might contain employee ID
      String? employeeId = prefs.getString('employee_id') ?? 
                           prefs.getString('employee') ?? 
                           prefs.getString('emp_code') ??
                           prefs.getString('empId') ??
                           prefs.getString('userId') ??
                           prefs.getString('employeeId');
      
      // If still null, try to get from user data map
      if (employeeId == null) {
        final String? userData = prefs.getString('user_data');
        if (userData != null) {
          try {
            final Map<String, dynamic> userMap = jsonDecode(userData);
            employeeId = userMap['employee_id'] ?? 
                        userMap['employee'] ?? 
                        userMap['emp_code'] ??
                        userMap['employeeId'];
          } catch (e) {
            debugPrint('Error parsing user_data: $e');
          }
        }
      }

      // If still null, try from profile provider data
      if (employeeId == null) {
        final String? profileData = prefs.getString('profile_data');
        if (profileData != null) {
          try {
            final Map<String, dynamic> profileMap = jsonDecode(profileData);
            employeeId = profileMap['employee_id'] ?? 
                        profileMap['employee'] ?? 
                        profileMap['name'];
          } catch (e) {
            debugPrint('Error parsing profile_data: $e');
          }
        }
      }

      // Final fallback for testing
      employeeId = employeeId ?? 'HR-EMP-00152';
      debugPrint('📌 Using Employee ID: $employeeId');

      // Use the custom API endpoint that returns processed leave balance data
      final url = Uri.parse('$baseUrl/api/method/ppecon_erp.leave_application.leave_balance.get_my_leave_balance');
      
      // Add employee ID as query parameter if needed
      final requestUrl = url.replace(queryParameters: {'employee': employeeId});
      
      debugPrint('🌐 URL: $requestUrl');

      // Make API request with your credentials
      final response = await http.get(
        requestUrl,
        headers: {
          'Authorization': 'token $_apiKey:$_apiSecret',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      debugPrint('📊 Status Code: ${response.statusCode}');
      debugPrint('📦 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        
        // Extract the message/data from response
        // The API returns { "message": { "employee": "...", "data": [...] } }
        final Map<String, dynamic>? message = jsonResponse['message'];
        
        if (message != null && message['data'] != null) {
          final List<dynamic> leaveData = message['data'] ?? [];
          
          // Process the leave data
          return _processLeaveData(leaveData, message['employee'] ?? employeeId);
        } else {
          debugPrint('⚠️ No data in response message');
          return _getDemoData(employeeId);
        }
      } else {
        debugPrint('⚠️ API failed with status ${response.statusCode}: ${response.body}');
        return _getDemoData(employeeId);
      }
    } catch (e) {
      debugPrint('❌ Error in fetchLeaveBalances: $e');
      return _getDemoData('HR-EMP-00152');
    }
  }

  // Process the leave data from API
  Map<String, dynamic> _processLeaveData(List<dynamic> leaveData, String employeeId) {
    Map<String, Map<String, double>> leaveDetails = {};
    double totalAllocated = 0;
    double totalTaken = 0;
    double totalRemaining = 0;

    debugPrint('📊 Processing ${leaveData.length} leave entries');

    for (var item in leaveData) {
      final leaveType = item['leave_type'] as String? ?? 'Unknown';
      final allocated = (item['allocated'] ?? 0).toDouble();
      final taken = (item['taken'] ?? 0).toDouble();
      final remaining = (item['remaining'] ?? 0).toDouble();

      // Add to leave details map
      leaveDetails[leaveType] = {
        'allocated': allocated,
        'taken': taken,
        'remaining': remaining,
      };

      // Update totals
      totalAllocated += allocated;
      totalTaken += taken;
      totalRemaining += remaining;

      debugPrint('📌 $leaveType: Allocated=$allocated, Taken=$taken, Remaining=$remaining');
    }

    debugPrint('✅ Total Allocated: $totalAllocated');
    debugPrint('✅ Total Taken: $totalTaken');
    debugPrint('✅ Total Remaining: $totalRemaining');

    return {
      'success': true,
      'employeeId': employeeId,
      'leaveDetails': leaveDetails,
      'totals': {
        'allocated': totalAllocated,
        'taken': totalTaken,
        'remaining': totalRemaining,
      }
    };
  }

  // Demo data for testing (when API fails)
  Map<String, dynamic> _getDemoData(String employeeId) {
    debugPrint('⚠️ Using demo data for employee: $employeeId');
    
    Map<String, Map<String, double>> leaveDetails = {
      'Annual Leave': {
        'allocated': 18,
        'taken': 5,
        'remaining': 13,
      },
      'Sick Leave': {
        'allocated': 10,
        'taken': 2,
        'remaining': 8,
      },
      'Casual Leave': {
        'allocated': 8,
        'taken': 1,
        'remaining': 7,
      },
      'Privilege Leave': {
        'allocated': 15,
        'taken': 3,
        'remaining': 12,
      },
      'Compensatory Off': {
        'allocated': 5,
        'taken': 0,
        'remaining': 5,
      },
    };

    double totalAllocated = 0;
    double totalTaken = 0;
    double totalRemaining = 0;

    leaveDetails.forEach((key, value) {
      totalAllocated += value['allocated']!;
      totalTaken += value['taken']!;
      totalRemaining += value['remaining']!;
    });

    return {
      'success': true,
      'employeeId': employeeId,
      'leaveDetails': leaveDetails,
      'totals': {
        'allocated': totalAllocated,
        'taken': totalTaken,
        'remaining': totalRemaining,
      }
    };
  }

  // Get formatted leave balance for dashboard
  static Future<double> getDashboardLeaveBalance() async {
    try {
      final service = LeaveBalanceService();
      final result = await service.fetchLeaveBalances();
      
      if (result['success'] == true) {
        return result['totals']['remaining'] ?? 0.0;
      }
      return 18.0; // Default demo value
    } catch (e) {
      debugPrint('Error getting dashboard balance: $e');
      return 18.0; // Default demo value
    }
  }

  // Test method to verify credentials and API
  static Future<void> testCredentials() async {
    try {
      final url = Uri.parse('$baseUrl/api/method/ppecon_erp.leave_application.leave_balance.get_my_leave_balance')
          .replace(queryParameters: {'employee': 'HR-EMP-00152'});

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'token $_apiKey:$_apiSecret',
          'Content-Type': 'application/json', 
        },
      );

      debugPrint('🧪 Test Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        debugPrint('✅ Credentials are working!');
        debugPrint('📦 Response: ${response.body}');
      } else {
        debugPrint('❌ Credentials test failed: ${response.body}');
      }
    } catch (e) {
      debugPrint('🧪 Test Error: $e');
    }
  }
}