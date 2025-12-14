import 'dart:convert';
import 'package:http/http.dart' as http;

class LeaveRequestService {

  static String formatDate(String date) {
    final parts = date.split("-");
    return "${parts[2]}-${parts[1]}-${parts[0]}";
  }

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

  static Future<Map<String, dynamic>> submitLeave({
    required String employeeCode,
    required String leaveType,
    required String fromDate,
    required String toDate,
    required String reason,
    required String compOff,
  }) async {

    final url = Uri.parse(
      "https://ppecon.erpnext.com/api/resource/Leave Application",
    );

    final body = {
      "employee": employeeCode,
      "leave_type": leaveType,
      "custom_ticket_":
          compOff == "YES" ? "Yes (On Company)" : "No",
      "incharge_replacement": "N/A",
      "from_date": formatDate(fromDate),
      "to_date": formatDate(toDate),
      "description": reason,
    };

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      return {
        "success": true,
        "data": jsonDecode(response.body),
      };
    } else {
      final err = jsonDecode(response.body);
      return {
        "success": false,
        "message": err["message"] ?? "Something went wrong",
      };
    }
  }
}
