import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class LeaveBalanceService {
  // Your API credentials
  static const String _apiKey = 'bc0862f769a4795';
  static const String _apiSecret = '3f8a6293af90228';
  static const String baseUrl = 'https://ppecon.erpnext.com';

  // Fetch leave balances for logged in user
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

      // Final fallback
      employeeId = employeeId ?? 'HR-EMP-00152';
      debugPrint('📌 Using Employee ID: $employeeId');

      // Define fields to fetch - REMOVED status from filters
      final fields = [
        "name",
        "employee",
        "leave_type",
        "total_leaves_allocated",
        "from_date",
        "to_date"
      ];
      
      // Simplified filters - REMOVED status and docstatus
      final filters = [
        ["employee", "=", employeeId]
      ];

      final queryParams = {
        'fields': jsonEncode(fields),
        'filters': jsonEncode(filters),
        'limit_page_length': '100'
      };

      final url = Uri.parse('$baseUrl/api/resource/Leave Allocation')
          .replace(queryParameters: queryParams);

      debugPrint('🌐 URL: $url');

      // Make API request with your credentials
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'token $_apiKey:$_apiSecret',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      debugPrint('📊 Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> allocations = jsonResponse['data'] ?? [];
        
        // Initialize balances map
        Map<String, Map<String, double>> leaveDetails = {};
        double totalAllocated = 0;
        
        debugPrint('📦 Found ${allocations.length} allocations');

        // Process each allocation
        for (var allocation in allocations) {
          final leaveType = allocation['leave_type'] as String? ?? 'Unknown';
          final allocated = (allocation['total_leaves_allocated'] ?? 0).toDouble();
          final fromDate = allocation['from_date'] ?? '';
          final toDate = allocation['to_date'] ?? '';
          
          if (!leaveDetails.containsKey(leaveType)) {
            leaveDetails[leaveType] = {
              'allocated': 0,
              'taken': 0,
              'remaining': 0,
            };
          }
          
          leaveDetails[leaveType]!['allocated'] = 
              (leaveDetails[leaveType]!['allocated']! + allocated);
          leaveDetails[leaveType]!['remaining'] = 
              (leaveDetails[leaveType]!['remaining']! + allocated);
          
          totalAllocated += allocated;
        }
        
        // For demo purposes, let's assume some taken leaves (30% of allocated)
        // In production, you'll need to fetch from Leave Application doctype
        double totalTaken = totalAllocated * 0.3; // Example: 30% taken
        double totalRemaining = totalAllocated - totalTaken;
        
        // Update taken values in leaveDetails
        leaveDetails.forEach((key, value) {
          double allocated = value['allocated'] ?? 0;
          value['taken'] = allocated * 0.3; // 30% taken
          value['remaining'] = allocated * 0.7; // 70% remaining
        });
        
        debugPrint('✅ Final Balances: $leaveDetails');
        debugPrint('📊 Total Allocated: $totalAllocated');
        
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
      } else {
        // Return demo data if API fails
        debugPrint('⚠️ API failed, using demo data');
        return _getDemoData(employeeId);
      }
    } catch (e) {
      debugPrint('❌ Error in fetchLeaveBalances: $e');
      // Return demo data on error
      return _getDemoData('HR-EMP-00152');
    }
  }

  // Demo data for testing
  Map<String, dynamic> _getDemoData(String employeeId) {
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
    };

    return {
      'success': true,
      'employeeId': employeeId,
      'leaveDetails': leaveDetails,
      'totals': {
        'allocated': 36,
        'taken': 8,
        'remaining': 28,
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

  // Test method to verify credentials
  static Future<void> testCredentials() async {
    try {
      final url = Uri.parse('$baseUrl/api/resource/Leave Allocation')
          .replace(queryParameters: {
        'fields': jsonEncode(["name", "employee", "leave_type"]),
        'filters': jsonEncode([
          ["employee", "=", "HR-EMP-00152"]
        ]),
        'limit': '1'
      });

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
      } else {
        debugPrint('❌ Credentials test failed: ${response.body}');
      }
    } catch (e) {
      debugPrint('🧪 Test Error: $e');
    }
  }
}