import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = "https://ppecon.erpnext.com";
  static List<String> cookies = [];
  static Client client = Client();

  static Future<void> saveCookies() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('cookies', cookies);
  }

  static Future<void> loadCookies() async {
    final prefs = await SharedPreferences.getInstance();
    cookies = prefs.getStringList('cookies') ?? [];
  }

  void _updateCookies(http.Response response) {
    String? rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      cookies = rawCookie.split(',');
      saveCookies();
    }
  }

  Map<String, String> _buildHeaders() {
    return {
      "Content-Type": "application/x-www-form-urlencoded",
      if (cookies.isNotEmpty) "Cookie": cookies.join(';'),
    };
  }

  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/api/method/login");

    try {
      final response = await client.post(
        url,
        headers: _buildHeaders(),
        body: {"usr": email, "pwd": password},
      );

      _updateCookies(response);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["message"] == "Logged In") {
        return {
          "success": true,
          "message": data["message"],
          "default_route": data["default_route"],
          "home_page": data["home_page"],
          "full_name": data["full_name"],
        };
      }

      if (data["exc_type"] == "AuthenticationError") {
        return {
          "success": false,
          "message": "Incorrect password",
          "exc_type": "AuthenticationError",
        };
      }

      if (data["exc_type"] == "DoesNotExistError") {
        return {
          "success": false,
          "message": "User does not exist",
          "exc_type": "DoesNotExistError",
        };
      }

      return {"success": false, "message": data["message"] ?? "Login failed"};
    } catch (e) {
      return {
        "success": false,
        "message": "Something went wrong",
        "error": e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> logoutUser() async {
    final url = Uri.parse("$baseUrl/api/method/logout");

    try {
      final response = await client.get(url, headers: _buildHeaders());

      cookies.clear();

      if (response.statusCode == 200) {
        return {"success": true, "message": "Logged out successfully"};
      } else {
        return {"success": false, "message": "Logout failed"};
      }
    } catch (e) {
      return {"success": false, "message": "Something went wrong"};
    }
  }

  Future<String> forgotPassword(String email) async {
    const url =
        "$baseUrl/api/method/frappe.core.doctype.user.user.reset_password";

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {"user": email},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final serverMessages = data["_server_messages"];

      if (serverMessages != null) {
        return "A password reset link has been sent to your registered email address.";
      } else {
        return "Request processed, but no confirmation message was received from the server.";
      }
    } else if (response.statusCode == 404) {
      throw "User not found. Please check the email you entered.";
    } else if (response.statusCode == 500) {
      throw "Server error. Please try again later.";
    } else {
      throw "Request failed with status: ${response.statusCode}. Please try again.";
    }
  }

  Future<bool> employeeCheckIn({
    required String employeeId,
    double latitude = 0,
    double longitude = 0,
  }) async {
    final response = await AuthService.client.post(
      Uri.parse("https://ppecon.erpnext.com/api/resource/Employee Checkin"),
      headers: {
        "Content-Type": "application/json",
        "Cookie": AuthService.cookies.join(";"),
      },
      body: jsonEncode({
        "employee": employeeId,
        "log_type": "IN",
        "latitude": latitude,
        "longitude": longitude,
      }),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> employeeCheckOut({
  required String employeeId,
  double latitude = 0,
  double longitude = 0,
}) async {
  final response = await AuthService.client.post(
    Uri.parse("https://ppecon.erpnext.com/api/resource/Employee Checkin"),
    headers: {
      "Content-Type": "application/json",
      "Cookie": AuthService.cookies.join(";"),
    },
    body: jsonEncode({
      "employee": employeeId,
      "log_type": "OUT",
      "latitude": latitude,
      "longitude": longitude,
    }),
  );

  return response.statusCode == 200 || response.statusCode == 201;
}

}
