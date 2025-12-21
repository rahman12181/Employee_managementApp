import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CheckinService {
  static const String _url =
      "https://ppecon.erpnext.com/api/resource/Employee%20Checkin";

  Future<void> checkIn({
    required String employeeId,
    required String logType, 
    double latitude = 0,
    double longitude = 0,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cookies = prefs.getStringList("cookies");

    if (cookies == null || cookies.isEmpty) {
      throw Exception("Session expired. Please login again.");
    }

    final response = await http.post(
      Uri.parse(_url),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Cookie": cookies.join("; "),
      },
      body: jsonEncode({
        "employee": employeeId,
        "log_type": logType, 
        "latitude": latitude,
        "longitude": longitude,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        "Punch failed (${response.statusCode}): ${response.body}",
      );
    }
  }
}
