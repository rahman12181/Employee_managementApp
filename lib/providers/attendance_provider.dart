import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/attendance_service.dart';
import '../model/attendance_model.dart';

class AttendanceProvider extends ChangeNotifier {
  final AttendanceService service = AttendanceService();

  Map<DateTime, AttendanceLog> attendanceMap = {};
  bool isLoading = false;

  Future<void> loadMonthAttendance(String employeeId, DateTime month) async {
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

      final dateOnly = item["time"].toString().substring(0, 10);
      final dateKey = DateTime.parse(dateOnly);

      attendanceMap.putIfAbsent(dateKey, () => AttendanceLog(date: dateKey));

      if (item["log_type"] == "IN") {
        attendanceMap[dateKey]!.checkIn = _formatTime(time);
        attendanceMap[dateKey]!.status = AttendanceStatus.presentCheckedIn;
      } else {
        attendanceMap[dateKey]!.checkOut = _formatTime(time);

        final inStr = attendanceMap[dateKey]!.checkIn;
        if (inStr != null) {
          final inTime = DateFormat(
            "yyyy-MM-dd HH:mm:ss",
          ).parse("$dateOnly $inStr:00");

          attendanceMap[dateKey]!.totalHours = time.difference(inTime);
        }

        attendanceMap[dateKey]!.status = AttendanceStatus.presentCompleted;
      }
    }

    isLoading = false;
    notifyListeners();
  }

  List<AttendanceLog> getMonthlyLogs(DateTime month) {
    final List<AttendanceLog> logs = [];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final isCurrentMonth =
        month.year == today.year && month.month == today.month;

    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);

    final int maxDay = isCurrentMonth ? today.day : lastDayOfMonth.day;

    for (int day = 1; day <= maxDay; day++) {
      final date = DateTime(month.year, month.month, day);

      if (attendanceMap.containsKey(date)) {
        logs.add(attendanceMap[date]!);
      } else {
        if (date.isBefore(today) || date.isAtSameMomentAs(today)) {
          logs.add(
            AttendanceLog(
              date: date,
              checkIn: null,
              checkOut: null,
              totalHours: Duration.zero,
              status: AttendanceStatus.absent,
            ),
          );
        }
      }
    }

    return logs;
  }

  String _formatTime(DateTime t) => DateFormat("HH:mm").format(t);
}
