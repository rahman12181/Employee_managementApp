import 'package:flutter/material.dart';
import 'package:management_app/services/checkin_history_service.dart';

class AttendanceHistoryProvider extends ChangeNotifier {
  final CheckinHistoryService _service = CheckinHistoryService();

  bool loading = false;
  List<dynamic> logs = [];

  Future<void> loadHistory(String employeeId) async {
    loading = true;
    notifyListeners();

    try {
      logs = await _service.fetchLogs(employeeId);
    } catch (e) {
      logs = [];
    }

    loading = false;
    notifyListeners();
  }

  Map<DateTime, Map<String, DateTime>> groupedLogs() {
    final Map<DateTime, Map<String, DateTime>> map = {};

    for (var log in logs) {
      final time = DateTime.parse(log["time"]);
      final date = DateTime(time.year, time.month, time.day);

      map.putIfAbsent(date, () => {});

      if (log["log_type"] == "IN") {
        map[date]!["in"] ??= time;
      } else {
        map[date]!["out"] = time;
      }
    }
    return map;
  }
}
