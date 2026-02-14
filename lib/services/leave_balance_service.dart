import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class LeaveBalanceService {
  // ✅ YOUR ACTUAL API CREDENTIALS - WORKING
  static const String _apiKey = 'bc0862f769a4795';
  static const String _apiSecret = '3f8a6293af90228';
  static const String baseUrl = 'https://ppecon.erpnext.com';

  Future<Map<String, double>> fetchLeaveBalances() async {
    try {
      // Get employee ID from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      
      // Try all possible keys that might contain employee ID
      String? employeeId = prefs.getString('employee_id') ?? 
                           prefs.getString('employee') ?? 
                           prefs.getString('emp_code') ??
                           prefs.getString('empId') ??
                           prefs.getString('userId') ??
                           prefs.getString('HR-EMP-00152'); // Direct key check
      
      // If still null, try to get from user data map
      if (employeeId == null) {
        final String? userData = prefs.getString('user_data');
        if (userData != null) {
          try {
            final Map<String, dynamic> userMap = jsonDecode(userData);
            employeeId = userMap['employee_id'] ?? 
                        userMap['employee'] ?? 
                        userMap['emp_code'];
          } catch (e) {
            debugPrint('Error parsing user_data: $e');
          }
        }
      }

      employeeId = employeeId ?? 'HR-EMP-00152';
      debugPrint('📌 Using Employee ID: $employeeId');

      final fields = [
        "name",
        "employee",
        "leave_type",
        "total_leaves_allocated"
      ];
      
      final filters = [
        ["employee", "=", employeeId],
        ["leave_type", "in", ["Sick Leave", "Annual Leave"]]
      ];

      final queryParams = {
        'fields': jsonEncode(fields),
        'filters': jsonEncode(filters),
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
      debugPrint('📦 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> allocations = jsonResponse['data'] ?? [];
        
        // Initialize balances
        Map<String, double> balances = {
          'Annual Leave': 0.0,
          'Sick Leave': 0.0,
        };

        // Process each allocation
        for (var allocation in allocations) {
          final leaveType = allocation['leave_type'] as String? ?? '';
          final allocated = (allocation['total_leaves_allocated'] ?? 0).toDouble();
          
          if (balances.containsKey(leaveType)) {
            balances[leaveType] = allocated;
          }
        }
        
        debugPrint('✅ Final Balances: $balances');
        return balances;
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}\n${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Error in fetchLeaveBalances: $e');
      throw Exception('Failed to load leave data: $e');
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
      debugPrint('🧪 Test Response: ${response.body}');
    } catch (e) {
      debugPrint('🧪 Test Error: $e');
    }
  }
}