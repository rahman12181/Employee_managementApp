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

    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    final data = await service.fetchLogs(
      employeeId: employeeId,
      start: start,
      end: end,
    );

    attendanceMap.clear();

    for (var item in data) {
      final DateTime time = DateFormat(
        "yyyy-MM-dd HH:mm:ss",
      ).parse(item["time"], true).toLocal();

      final dateKey = DateTime(time.year, time.month, time.day);

      attendanceMap.putIfAbsent(
        dateKey,
        () => AttendanceLog(
          date: dateKey,
          totalHours: Duration.zero,
          status: AttendanceStatus.absent,
        ),
      );

      final log = attendanceMap[dateKey]!;

      if (item["log_type"] == "IN") {
        log.checkIn = _formatTime(time);
        log.status = AttendanceStatus.checkedIn;
      }

      else if (item["log_type"] == "OUT") {
        log.checkOut = _formatTime(time);

        if (log.checkIn != null) {
          final inTime = DateFormat(
            "yyyy-MM-dd HH:mm:ss",
          ).parse("${DateFormat('yyyy-MM-dd').format(dateKey)} ${log.checkIn}:00");

          log.totalHours = time.difference(inTime);

          _applyWorkingHourStatus(log);
        }
      }
    }

    isLoading = false;
    notifyListeners();
  }

  void _applyWorkingHourStatus(AttendanceLog log) {
    final hours = log.totalHours.inMinutes / 60;

    if (hours >= 9) {
      log.status = AttendanceStatus.overtime; 
    } else if (hours >= 8) {
      log.status = AttendanceStatus.completed; 
    } else {
      log.status = AttendanceStatus.shortage; 
    }
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
      } else if (date.isBefore(today) || date.isAtSameMomentAs(today)) {
        logs.add(
          AttendanceLog(
            date: date,
            totalHours: Duration.zero,
            status: AttendanceStatus.absent,
          ),
        );
      }
    }

    return logs;
  }

  String _formatTime(DateTime t) => DateFormat("HH:mm").format(t);
}
