import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../model/attendance_model.dart';

class PunchProvider extends ChangeNotifier {
  DateTime? _punchInTime; // Store as UTC
  DateTime? _punchOutTime; // Store as UTC

  DateTime? get punchInTime => _punchInTime;
  DateTime? get punchOutTime => _punchOutTime;

  // Riyadh timezone offset (+3 hours from UTC)
  static const Duration riyadhOffset = Duration(hours: 3);

  // Helper methods for Riyadh time
  DateTime toRiyadhTime(DateTime utcTime) => utcTime.add(riyadhOffset);
  DateTime get todayInRiyadh => toRiyadhTime(DateTime.now().toUtc());

  Future<void> loadDailyPunches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get today's date in Riyadh for key (consistent with server)
      final todayRiyadh = todayInRiyadh;
      final todayKey = DateFormat('yyyy-MM-dd').format(todayRiyadh);
      
      final inStr = prefs.getString("IN_$todayKey");
      final outStr = prefs.getString("OUT_$todayKey");
      
      // Load as UTC times
      _punchInTime = inStr != null ? DateTime.parse(inStr) : null;
      _punchOutTime = outStr != null ? DateTime.parse(outStr) : null;
      
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setPunchIn(DateTime utcTime) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Use Riyadh date for key (to match server date)
      final riyadhTime = toRiyadhTime(utcTime);
      final key = DateFormat('yyyy-MM-dd').format(riyadhTime);
      
      await prefs.setString("IN_$key", utcTime.toUtc().toIso8601String());
      
      // Store UTC time in provider
      _punchInTime = utcTime;
      
      // Clear punch out for today
      await prefs.remove("OUT_$key");
      _punchOutTime = null;
      
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setPunchOut(DateTime utcTime) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Use Riyadh date for key
      final riyadhTime = toRiyadhTime(utcTime);
      final key = DateFormat('yyyy-MM-dd').format(riyadhTime);
      
      await prefs.setString("OUT_$key", utcTime.toUtc().toIso8601String());
      
      // Store UTC time in provider
      _punchOutTime = utcTime;
      
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Get times in Riyadh for display
  DateTime? get punchInTimeRiyadh => _punchInTime?.add(riyadhOffset);
  DateTime? get punchOutTimeRiyadh => _punchOutTime?.add(riyadhOffset);

  String totalHours() {
    if (_punchInTime == null) return "00:00";
    final end = _punchOutTime ?? DateTime.now().toUtc();
    final diff = end.difference(_punchInTime!);
    return "${diff.inHours.toString().padLeft(2, '0')}:${(diff.inMinutes % 60).toString().padLeft(2, '0')}";
  }

  double progressValue() {
    if (_punchInTime == null) return 0.0;
    final end = _punchOutTime ?? DateTime.now().toUtc();
    return end.difference(_punchInTime!).inSeconds / (12 * 60 * 60);
  }

  bool canPunchInToday() => _punchInTime == null;
  bool canPunchOutToday() => _punchInTime != null && _punchOutTime == null;
  bool isTodayCompleted() => _punchInTime != null && _punchOutTime != null;

  Future<void> clearTodayPunches() async {
    final prefs = await SharedPreferences.getInstance();
    final todayRiyadh = todayInRiyadh;
    final todayKey = DateFormat('yyyy-MM-dd').format(todayRiyadh);
    
    await prefs.remove("IN_$todayKey");
    await prefs.remove("OUT_$todayKey");
    
    _punchInTime = null;
    _punchOutTime = null;
    
    notifyListeners();
  }

  AttendanceStatus getCurrentAttendanceStatus() {
    if (_punchInTime == null) return AttendanceStatus.absent;
    if (_punchOutTime == null) return AttendanceStatus.checkedIn;

    final duration = _punchOutTime!.difference(_punchInTime!);
    final hours = duration.inMinutes / 60;

    if (hours >= 9) return AttendanceStatus.overtime;
    if (hours >= 8) return AttendanceStatus.completed;
    return AttendanceStatus.shortage;
  }

  Duration getTotalDuration() {
    if (_punchInTime == null) return Duration.zero;
    final end = _punchOutTime ?? DateTime.now().toUtc();
    return end.difference(_punchInTime!);
  }
}