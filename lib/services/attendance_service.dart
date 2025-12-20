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

    final df = DateFormat("yyyy-MM-dd HH:mm:ss");

    final url =
        "$baseUrl"
        "?filters=[[\"employee\",\"=\",\"$employeeId\"],"
        "[\"time\",\">=\",\"${df.format(start)}\"],"
        "[\"time\",\"<=\",\"${df.format(end)}\"]]"
        "&fields=[\"log_type\",\"time\"]"
        "&order_by=time asc";

    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Cookie": cookies.join("; "),
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch attendance");
    }

    return jsonDecode(response.body)["data"];
  }
}
