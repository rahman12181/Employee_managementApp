import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckuserUtils {

  static Future<void> checkUser(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    await Future.delayed(const Duration(seconds: 2));

    if (!context.mounted) return;

    final isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
    final token = prefs.getString("authToken");
    final employeeId = prefs.getString("employeeId");

    if (isLoggedIn &&
        token != null &&
        token.isNotEmpty &&
        employeeId != null &&
        employeeId.isNotEmpty) {

      Navigator.pushReplacementNamed(context, "/homeScreen");
      return;
    }
    Navigator.pushReplacementNamed(context, "/loginScreen");
  }


  // ================= SAVE LOGIN =================
  static Future<void> saveloginStatus({
    required String route,
    required String employeeId,
    String? userName,
    String? authToken,
    List<String>? cookies,
  }) async {

    final prefs = await SharedPreferences.getInstance();

    // ================= BASIC =================
    await prefs.setBool("isLoggedIn", true);
    await prefs.setString("home_page", "/homeScreen");


    // ================= EMPLOYEE =================
    final empId = employeeId.trim();

    if (empId.isEmpty) {
      throw Exception("Employee ID cannot be empty");
    }

    await prefs.setString("employeeId", empId);


    // ================= USER =================
    if (userName != null && userName.trim().isNotEmpty) {
      await prefs.setString("userName", userName.trim());
    }


    // ================= TOKEN =================
    String? finalToken = authToken;
    if ((finalToken == null || finalToken.isEmpty) &&
        cookies != null &&
        cookies.isNotEmpty) {

      try {
        final sid = cookies.firstWhere(
          (c) => c.startsWith("sid="),
        );

        finalToken = sid.replaceAll("sid=", "").trim();

      } catch (_) {}
    }


    if (finalToken != null && finalToken.isNotEmpty) {
      await prefs.setString("authToken", finalToken.trim());
    }


    // ================= COOKIES =================
    if (cookies != null && cookies.isNotEmpty) {
      await prefs.setStringList("cookies", cookies);
    }
  }


  // ================= LOGOUT =================
  static Future<void> logout(BuildContext context) async {

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!context.mounted) return;

    Navigator.pushReplacementNamed(context, "/loginScreen");
  }
}
