import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckuserUtils {
  static Future<void> checkUser(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(seconds: 2));
    if (!context.mounted) return;
    bool isFirstTime = prefs.getBool("isFirstTime") ?? true;
    bool isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
    String? savedRoute = prefs.getString("home_page");
    if (isFirstTime) {
      await prefs.setBool("isFirstTime", false);
      Navigator.pushReplacementNamed(context, "/loginScreen");
      return;
    }
    if (isLoggedIn && savedRoute != null && savedRoute.isNotEmpty) {
      switch (savedRoute) {
        case "/app/home":
        case "/app":
        case "/desk":
        case "/app/overview":
          savedRoute = "/homeScreen";
          break;
        default:
          if (savedRoute.isEmpty) savedRoute = "/homeScreen";
      }
      Navigator.pushReplacementNamed(context, savedRoute);
      return;
    }
    Navigator.pushReplacementNamed(context, "/loginScreen");
  }

  static Future<void> saveloginStatus({
    required String route,
    required String employeeId,
    String? userName,
    String? authToken,
    List<String>? cookies,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.clear();
    
    await prefs.setBool("isLoggedIn", true);
    await prefs.setString("home_page", route);
    
    if (employeeId.isEmpty) {
      throw Exception('Employee ID cannot be empty');
    }
    
    final empId = employeeId.trim();
    await prefs.setString("employeeId", empId);
    await prefs.setString("employee_id", empId);
    await prefs.setString("employee", empId);
    await prefs.setString("emp_id", empId);
    await prefs.setString("empId", empId);
    
    if (userName != null && userName.trim().isNotEmpty) {
      final name = userName.trim();
      await prefs.setString("userName", name);
      await prefs.setString("email", name);
      await prefs.setString("owner", name);
    }
    
    String? finalToken = authToken;
    if ((finalToken == null || finalToken.isEmpty) && cookies != null && cookies.isNotEmpty) {
      try {
        final sid = cookies.firstWhere((c) => c.startsWith("sid="));
        finalToken = sid.replaceAll("sid=", "").trim();
      } catch (_) {}
    }
    
    if (finalToken != null && finalToken.trim().isNotEmpty) {
      final token = finalToken.trim();
      await prefs.setString("authToken", token);
      await prefs.setString("token", token);
      await prefs.setString("sid", token);
      await prefs.setString("api_token", token);
      await prefs.setString("access_token", token);
      await prefs.setString("session_token", token);
      await prefs.setString("auth_header", "token $token");
      await prefs.setString("frappe_token", "token $token");
    }
    
    if (cookies != null && cookies.isNotEmpty) {
      await prefs.setStringList("cookies", cookies);
    }
  }
}