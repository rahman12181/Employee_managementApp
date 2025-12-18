import 'package:flutter/material.dart';
import '../services/checkin_history_service.dart';

class AttendanceHistoryProvider extends ChangeNotifier {
  final CheckinHistoryService _service = CheckinHistoryService();

  bool loading = false;
  List<dynamic> logs = [];

  Future<void> loadHistory(String employeeId) async {
    if (employeeId.isEmpty) return;

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

  /// DATE KEY = yyyy-mm-dd (SAFE)
  Map<String, Map<String, DateTime>> groupedLogs() {
    final Map<String, Map<String, DateTime>> map = {};

    for (var log in logs) {
      if (log["time"] == null || log["log_type"] == null) continue;

      final time = DateTime.parse(log["time"]);
      final key = "${time.year}-${time.month}-${time.day}";

      map.putIfAbsent(key, () => {});

      if (log["log_type"] == "IN") {
        map[key]!["in"] ??= time;
      } else {
        map[key]!["out"] = time;
      }
    }
    return map;
  }
}
