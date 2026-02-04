import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class AttendanceService {
  static const String baseUrl =
      "https://ppecon.erpnext.com/api/resource/Employee%20Checkin";

  Future<List<dynamic>> fetchLogs({
    required String employeeId,
    required DateTime start,
    required DateTime end,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cookies = prefs.getStringList("cookies");

    if (cookies == null || cookies.isEmpty) {
      throw Exception("Session expired");
    }

    final df = DateFormat("yyyy-MM-dd");

    final formattedStart = "${df.format(start)} 00:00:00";
    final formattedEnd = "${df.format(end)} 23:59:59";

    final url =
        "$baseUrl?fields=[\"name\",\"employee\",\"log_type\",\"time\"]"
        "&filters=[[\"employee\",\"=\",\"$employeeId\"],"
        "[\"time\",\">=\",\"$formattedStart\"],"
        "[\"time\",\"<=\",\"$formattedEnd\"]]"
        "&order_by=time%20asc"
        "&limit_page_length=1000";

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Cookie": cookies.join("; "),
        },
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to fetch attendance: ${response.statusCode}");
      }

      final jsonData = jsonDecode(response.body);
      
      if (jsonData["data"] == null) {
        return [];
      }

      return jsonData["data"] as List;
    } catch (e) {
      throw Exception("Attendance fetch error: $e");
    }
  }
}