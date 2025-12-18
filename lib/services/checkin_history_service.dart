import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class CheckinHistoryService {
  Future<List<dynamic>> fetchLogs(String employeeId) async {
    if (employeeId.isEmpty) return [];

    final url =
        "https://ppecon.erpnext.com/api/resource/Employee%20Checkin"
        "?filters=[[\"employee\",\"=\",\"$employeeId\"]]"
        "&order_by=time desc"
        "&limit_page_length=500";

    final response = await AuthService.client.get(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Cookie": AuthService.cookies.join("; "),
      },
    );

    if (response.statusCode != 200) {
      throw Exception("History API failed");
    }

    final body = jsonDecode(response.body);
    return body["data"] ?? [];
  }
}
