import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AttendanceRequestService {
  static const String baseUrl = "https://ppecon.erpnext.com";

  Future<void> submitRequest({
    required DateTime date,
    required String reason,
    required String explanation,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final employeeId = prefs.getString("employeeId");
    final cookies = prefs.getStringList("cookies");
    final authToken = prefs.getString("authToken");

    if (employeeId == null || employeeId.isEmpty) {
      throw Exception("Session expired. Please login again.");
    }

    if (cookies == null || cookies.isEmpty) {
      throw Exception("Authentication failed. Please login again.");
    }

    final url = Uri.parse(
      "$baseUrl/api/resource/Attendance%20Request",
    );

    final body = {
      "employee": employeeId,
      "from_date": DateFormat("yyyy-MM-dd").format(date),
      "to_date": DateFormat("yyyy-MM-dd").format(date),
      "reason": reason,
      "explanation": explanation,
    };

    try {
      final response = await http
          .post(
            url,
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
              "Cookie": cookies.join("; "),
              if (authToken != null)
                "Authorization": authToken, 
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      }
      String errorMessage = "Request failed";

      try {
        final decoded = jsonDecode(response.body);

        if (decoded is Map) {
          errorMessage =
              decoded["message"] ??
              decoded["exception"] ??
              decoded["_server_messages"]?.toString() ??
              errorMessage;
        }
      } catch (_) {}

      throw Exception(
        "(${response.statusCode}) $errorMessage",
      );
    } on SocketException {
      throw Exception("No internet connection");
    } on HttpException {
      throw Exception("Server error");
    } on FormatException {
      throw Exception("Invalid server response");
    }
  }
}
