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

    if (isLoggedIn && savedRoute != null) {
      Navigator.pushReplacementNamed(context, savedRoute);
      return;
    }

    Navigator.pushReplacementNamed(context, "/loginScreen");
  }

  static Future<void> saveloginStatus({
  required String route,
  String? employeeId,
  String? userName,
  String? authToken,
  List<String>? cookies,
}) async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setBool("isLoggedIn", true);
  await prefs.setString("home_page", route);

  if (employeeId != null) {
    await prefs.setString("employeeId", employeeId);
  }

  if (userName != null) {
    await prefs.setString("userName", userName);
  }

  if (authToken != null) {
    await prefs.setString("authToken", authToken);
  }

  if (cookies != null) {
    await prefs.setStringList("cookies", cookies);
  }
}


}
