import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class PunchProvider extends ChangeNotifier {
  DateTime? punchInTime;
  DateTime? punchOutTime;

 
  Future<void> loadDailyPunches() async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final inStr = prefs.getString("IN_$todayKey");
    final outStr = prefs.getString("OUT_$todayKey");

    punchInTime = inStr != null ? DateTime.parse(inStr) : null;
    punchOutTime = outStr != null ? DateTime.parse(outStr) : null;
    notifyListeners();
  }

 
  Future<void> setPunchIn(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    final key = DateFormat('yyyy-MM-dd').format(time);
    await prefs.setString("IN_$key", time.toIso8601String());
    punchInTime = time;
    notifyListeners();
  }


  Future<void> setPunchOut(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    final key = DateFormat('yyyy-MM-dd').format(time);
    await prefs.setString("OUT_$key", time.toIso8601String());
    punchOutTime = time;
    notifyListeners();
  }

 
  String totalHours() {
    if (punchInTime == null) return "00:00";
    final end = punchOutTime ?? DateTime.now();
    final diff = end.difference(punchInTime!);
    return "${diff.inHours.toString().padLeft(2, '0')}:${(diff.inMinutes % 60).toString().padLeft(2, '0')}";
  }

  
  double progressValue() {
    if (punchInTime == null) return 0.0;
    final end = punchOutTime ?? DateTime.now();
    
    return end.difference(punchInTime!).inSeconds / (12 * 60 * 60);
  }
}
