import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AttendanceRequestService {
  static const String baseUrl = "https://ppecon.erpnext.com";

  Future<void> submitRequest({
    required String employeeId,
    required DateTime date,
    required String reason,
    required String explanation,
  }) async {
    final url = Uri.parse("$baseUrl/api/attendance/request");

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
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      }
      final decoded = jsonDecode(response.body);
      final message =
          decoded["message"] ?? decoded["error"] ?? "Request failed";

      throw Exception(message);
    }

    on SocketException {
      throw Exception("No internet connection");
    } on HttpException {
      throw Exception("Server error");
    } on FormatException {
      throw Exception("Invalid server response");
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
