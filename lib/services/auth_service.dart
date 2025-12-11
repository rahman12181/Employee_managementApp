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

  // 🔹 Load cookies from SharedPreferences
  static Future<void> loadCookies() async {
    final prefs = await SharedPreferences.getInstance();
    cookies = prefs.getStringList('cookies') ?? [];
  }

  void _updateCookies(http.Response response) {
    String? rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      cookies = rawCookie.split(',');
      saveCookies(); // save cookies after login
    }
  }

  Map<String, String> _buildHeaders() {
    return {
      "Content-Type": "application/x-www-form-urlencoded",
      if (cookies.isNotEmpty) "Cookie": cookies.join(';')
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
        body: {
          "usr": email,
          "pwd": password,
        },
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

      return {
        "success": false,
        "message": data["message"] ?? "Login failed",
      };

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
      final response = await client.get(
        url,
        headers: _buildHeaders(), 
      );

      cookies.clear(); 

      if (response.statusCode == 200) {
        return {
          "success": true,
           "message": "Logged out successfully"
           };
      } else {
        return {
          "success": false,
           "message": "Logout failed"
           };
      }
    } catch (e) {
      return {
        "success": false,
       "message": "Something went wrong"
       };
    }
  }
}
