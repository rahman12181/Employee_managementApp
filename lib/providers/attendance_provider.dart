import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/attendance_service.dart';
import '../model/attendance_model.dart';

class AttendanceProvider extends ChangeNotifier {
  final AttendanceService service = AttendanceService();

  Map<DateTime, AttendanceLog> attendanceMap = {};
  bool isLoading = false;

  Future<void> loadMonthAttendance(
      String employeeId, DateTime month) async {
    isLoading = true;
    notifyListeners();

    final start = DateTime(month.year, month.month, 1, 0, 0, 0);
    final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    final data = await service.fetchLogs(
      employeeId: employeeId,
      start: start,
      end: end,
    );

    attendanceMap.clear();

    for (var item in data) {
      final time = DateTime.parse(item["time"]);
      final dateKey = DateTime(time.year, time.month, time.day);

      attendanceMap.putIfAbsent(
        dateKey,
        () => AttendanceLog(date: dateKey),
      );

      if (item["log_type"] == "IN") {
        attendanceMap[dateKey]!.checkIn = _formatTime(time);
      } else {
        attendanceMap[dateKey]!.checkOut = _formatTime(time);

        final inStr = attendanceMap[dateKey]!.checkIn;
        if (inStr != null) {
          final inTime = DateFormat("yyyy-MM-dd HH:mm:ss").parse(
            "${DateFormat('yyyy-MM-dd').format(dateKey)} $inStr:00",
          );

          attendanceMap[dateKey]!.totalHours =
              time.difference(inTime);
        }
      }
    }

    isLoading = false;
    notifyListeners();
  }

  String _formatTime(DateTime t) =>
      DateFormat("HH:mm").format(t);
}
