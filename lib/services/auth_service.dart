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
      if (rawCookie.contains('Path=/,')) {
        cookies = rawCookie.split('Path=/,').map((c) {
          String cookie = c.trim();
          if (cookie.contains(';')) {
            return cookie.split(';')[0];
          }
          return cookie;
        }).toList();
      } else {
        if (rawCookie.contains(';')) {
          cookies = [rawCookie.split(';')[0]];
        } else {
          cookies = [rawCookie];
        }
      }
      saveCookies();
    }
  }

  Map<String, String> _buildHeaders() {
    Map<String, String> headers = {
      "Content-Type": "application/x-www-form-urlencoded",
    };
    if (cookies.isNotEmpty) {
      headers["Cookie"] = cookies.join('; ');
    }
    return headers;
  }

  String? _extractSidFromCookies() {
    try {
      for (final cookie in cookies) {
        if (cookie.startsWith("sid=")) {
          return cookie.replaceAll("sid=", "").trim();
        }
      }
    } catch (_) {}
    return null;
  }

  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/api/method/login");

    try {
      cookies.clear();
      
      final response = await client.post(
        url,
        headers: _buildHeaders(),
        body: {"usr": email, "pwd": password},
      );

      _updateCookies(response);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["message"] == "Logged In") {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool("isLoggedIn", true);
        await prefs.setString("email", email);
        await prefs.setString("full_name", data["full_name"] ?? "");
        
        String? employeeId;
        
        try {
          final empResponse = await client.get(
            Uri.parse(
              '$baseUrl/api/resource/Employee'
              '?filters=[["user_id","=","$email"]]'
              '&fields=["name"]'
            ),
            headers: {
              "Cookie": cookies.join(';'),
            },
          );
          
          final empJson = jsonDecode(empResponse.body);
          if (empJson["data"] != null && empJson["data"].isNotEmpty) {
            employeeId = empJson["data"][0]["name"];
            await prefs.setString("employeeId", employeeId!);
          }
        // ignore: empty_catches
        } catch (e) {
        }
        
        return {
          "success": true,
          "message": data["message"],
          "default_route": data["default_route"],
          "home_page": data["home_page"],
          "full_name": data["full_name"],
          "employee_id": employeeId,
          "sid": _extractSidFromCookies(),
          "email": email,
        };
      }

      if (data["exc_type"] == "AuthenticationError") {
        return {"success": false, "message": "Incorrect password", "exc_type": "AuthenticationError"};
      }

      if (data["exc_type"] == "DoesNotExistError") {
        return {"success": false, "message": "User does not exist", "exc_type": "DoesNotExistError"};
      }

      return {"success": false, "message": data["message"] ?? "Login failed"};
    } catch (e) {
      return {"success": false, "message": "Something went wrong", "error": e.toString()};
    }
  }

  Future<String> getInitialRoute() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
    final route = prefs.getString("home_page");
    if (isLoggedIn && route != null && route.isNotEmpty) {
      return route; 
    }
    return '/loginScreen';
  }

  Future<Map<String, dynamic>> logoutUser() async {
    final url = Uri.parse("$baseUrl/api/method/logout");
    try {
      await client.get(url, headers: _buildHeaders());
      cookies.clear();
      await saveCookies();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool("isLoggedIn", false);
      return {"success": true, "message": "Logged out successfully"};
    } catch (e) {
      return {"success": false, "message": "Something went wrong"};
    }
  }

  Future<String> forgotPassword(String email) async {
    const url = "$baseUrl/api/method/frappe.core.doctype.user.user.reset_password";
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {"user": email},
    );
    if (response.statusCode == 200) {
      return "A password reset link has been sent to your registered email address.";
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
        "Cookie": AuthService.cookies.join("; "),
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
        "Cookie": AuthService.cookies.join("; "),
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