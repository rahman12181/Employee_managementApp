import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:management_app/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileProvider extends ChangeNotifier {
  Map<String, dynamic>? profileData;

  final String baseUrl = "https://ppecon.erpnext.com";

  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    String? cachedProfile = prefs.getString('profileData');
    if (cachedProfile != null) {
      profileData = jsonDecode(cachedProfile);
      notifyListeners();
    }
    try {
      final loggedUserResponse = await AuthService.client.get(
        Uri.parse("$baseUrl/api/method/frappe.auth.get_logged_user"),
        headers: {"Cookie": AuthService.cookies.join(';')},
      );

      if (loggedUserResponse.statusCode != 200) {
        throw Exception("Failed to get logged in user.");
      }

      final loggedUserEmail = jsonDecode(loggedUserResponse.body)["message"];

      if (loggedUserEmail == null || loggedUserEmail == "") {
        throw Exception("User email not found.");
      }

      final profileResponse = await AuthService.client.get(
        Uri.parse("$baseUrl/api/resource/User/$loggedUserEmail"),
        headers: {"Cookie": AuthService.cookies.join(';')},
      );

      if (profileResponse.statusCode != 200) {
        throw Exception("Unable to fetch user profile.");
      }

      final profileJson = jsonDecode(profileResponse.body);

      profileData = {
        "full_name": profileJson["data"]["full_name"] ?? "",
        "email": profileJson["data"]["email"] ?? "",
        "user_image": profileJson["data"]["user_image"] ?? "",
      };

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profileData', jsonEncode(profileData));

      notifyListeners();
    } catch (e) {
      throw Exception("Network error: $e");
    }
  }
}
