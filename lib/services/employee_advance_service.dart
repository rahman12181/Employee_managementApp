import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:management_app/model/employee_advance_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmployeeAdvanceService {
  static const String _baseUrl = "https://ppecon.erpnext.com/api";
  static const Duration _timeoutDuration = Duration(seconds: 30);

  // ================= GET SESSION TOKEN =================
  Future<String?> _getSessionId() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString("authToken"); // sid saved here

    if (token != null && token.isNotEmpty) {
      return token.trim();
    }

    return null;
  }

  // ================= GET EMPLOYEE ID =================
  Future<String> _getEmployeeId() async {
    final prefs = await SharedPreferences.getInstance();

    final employeeId = prefs.getString("employeeId");

    if (employeeId != null && employeeId.isNotEmpty) {
      return employeeId.trim();
    }

    throw Exception("Employee ID not found. Please login again.");
  }

  // ================= SUBMIT ADVANCE =================
  Future<Map<String, dynamic>> submitAdvance({
    required double advanceAmount,
    required String purpose,
    required String advanceAccount,
    required String modeOfPayment,
    bool repayFromSalary = true,
  }) async {
    try {
      final sid = await _getSessionId();

      if (sid == null) {
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
        };
      }

      final employeeId = await _getEmployeeId();

      const endpoint =
          '/method/ppecon_erp.employee_advance.employee_advance.submit_employee_advance_from_mobile';

      final url = Uri.parse('$_baseUrl$endpoint');

      final requestBody = {
        "employee": employeeId,
        "advance_amount": advanceAmount,
        "purpose": purpose,
        "advance_account": advanceAccount,
        "mode_of_payment": modeOfPayment,
        "repay_unclaimed_amount_from_salary": repayFromSalary ? 1 : 0,
      };

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',

              // 🔥 IMPORTANT
              'Cookie': 'sid=$sid',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return {
          'success': true,
          'message': 'Advance submitted successfully',
          'data': data,
        };
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        return {
          'success': false,
          'message': 'Unauthorized. Please login again.',
        };
      }

      return {
        'success': false,
        'message':
            'Failed. Status: ${response.statusCode} ${response.reasonPhrase}',
        'error': response.body,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // ================= GET APPLIED ADVANCES =================
  Future<Map<String, dynamic>> getAppliedAdvances({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final sid = await _getSessionId();

      if (sid == null) {
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
          'data': [],
        };
      }

      final employeeId = await _getEmployeeId();

      const endpoint =
          '/method/ppecon_erp.employee_advance.employee_advance.get_employee_advances';

      final url = Uri.parse('$_baseUrl$endpoint');

      final requestBody = {
        "employee": employeeId,
        "limit": limit,
        "offset": offset,
        "order_by": "posting_date desc",
      };

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',

              // 🔥 IMPORTANT
              'Cookie': 'sid=$sid',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['message'] is List) {
          final list = List<Map<String, dynamic>>.from(data['message']);

          final advances = list
              .map((e) => EmployeeAdvanceModel.fromJson(e))
              .toList();

          return {
            'success': true,
            'message': 'Data loaded',
            'data':
                advances.map((e) => e.toDisplayMap()).toList(),
            'total': advances.length,
          };
        }

        return {
          'success': true,
          'message': 'No records found',
          'data': [],
          'total': 0,
        };
      }

      return {
        'success': false,
        'message':
            'Failed. Status: ${response.statusCode}',
        'data': [],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
        'data': [],
      };
    }
  }

  // ================= STATIC DATA =================
  Future<Map<String, dynamic>> getAdvanceAccounts() async {
    return {
      'success': true,
      'data': [
        "1610 - Employee Advances - PPE",
        "Cash - Petty Cash",
        "1620 - Travel Advances - PPE",
      ],
    };
  }

  Future<Map<String, dynamic>> getPaymentModes() async {
    return {
      'success': true,
      'data': [
        "Cash",
        "Bank Transfer",
        "Cheque",
        "Online Payment",
      ],
    };
  }
}
