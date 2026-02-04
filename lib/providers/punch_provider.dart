import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../model/attendance_model.dart';

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

  // ✅ NEW: Get attendance status based on current punch data
  AttendanceStatus getCurrentAttendanceStatus() {
    if (punchInTime == null) return AttendanceStatus.absent;
    if (punchOutTime == null) return AttendanceStatus.checkedIn;

    final duration = punchOutTime!.difference(punchInTime!);
    final hours = duration.inMinutes / 60;

    if (hours >= 9) return AttendanceStatus.overtime;
    if (hours >= 8) return AttendanceStatus.completed;
    return AttendanceStatus.shortage;
  }

  // ✅ NEW: Check if today has completed attendance
  bool isTodayCompleted() {
    return punchInTime != null && punchOutTime != null;
  }

  // ✅ NEW: Get total hours as Duration
  Duration getTotalDuration() {
    if (punchInTime == null) return Duration.zero;
    final end = punchOutTime ?? DateTime.now();
    return end.difference(punchInTime!);
  }
}