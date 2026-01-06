import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class LeaveRequestService {
  static const String _baseUrl = "https://ppecon.erpnext.com";
  static const String _leaveUrl = "$_baseUrl/api/resource/Leave Application";

  static String mapLeaveType(String? value) {
    switch (value) {
      case "CL":
        return "Casual Leave";
      case "SL":
        return "Sick Leave";
      case "EL":
        return "Earned Leave";
      default:
        return "";
    }
  }

  static String _formatDate(String date) {
    try {
      final parts = date.split("-");
      if (parts.length == 3) {
        return "${parts[2]}-${parts[1]}-${parts[0]}";
      }
      return date;
    } catch (_) {
      return date;
    }
  }

  static Future<bool> _hasInternet() async {
    try {
      final result = await InternetAddress.lookup("google.com");
      return result.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> submitLeave({
    required String employeeCode,
    required String leaveType,
    required String fromDate,
    required String toDate,
    required String reason,
    required String compOff,
    required String inchargeReplacement,
  }) async {
    if (!await _hasInternet()) {
      return {
        "success": false,
        "message": "No internet connection",
      };
    }

    try {
      await AuthService.loadCookies();
      
      if (AuthService.cookies.isEmpty) {
        return {
          "success": false,
          "message": "Please login first",
        };
      }

      final body = {
        "employee": employeeCode,
        "leave_type": leaveType,
        "custom_ticket_": compOff == "YES" ? "Yes (On Company)" : "No",
        "incharge_replacement": inchargeReplacement.isNotEmpty 
            ? inchargeReplacement 
            : "N/A",
        "from_date": _formatDate(fromDate),
        "to_date": _formatDate(toDate),
        "description": reason,
        "ticket": compOff == "YES" ? "Yes (On Company)" : "No",
      };

      final response = await http.post(
        Uri.parse(_leaveUrl),
        headers: {
          "Content-Type": "application/json",
          "Cookie": AuthService.cookies.join("; "),
        },
        body: jsonEncode(body),
      );

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          "success": true,
          "message": "Leave applied successfully!",
        };
      }

      if (decoded.containsKey("exception")) {
        return {
          "success": false,
          "message": _extractErrorMessage(decoded["exception"]),
        };
      }

      return {
        "success": false,
        "message": decoded["message"] ?? "Failed to apply leave",
      };
    } catch (e) {
      return {
        "success": false,
        "message": "Something went wrong",
      };
    }
  }

  static String _extractErrorMessage(String error) {
    if (error.contains("MandatoryError")) {
      return "Required information is missing";
    }
    if (error.contains("Authentication")) {
      return "Session expired. Please login again";
    }
    return "Unable to process request";
  }
}