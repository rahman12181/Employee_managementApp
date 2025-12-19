import 'package:flutter/material.dart';
import '../services/checkin_history_service.dart';

class AttendanceHistoryProvider extends ChangeNotifier {
  final CheckinHistoryService _service = CheckinHistoryService();

  bool loading = false;
  List<dynamic> logs = [];

  
  DateTime? firstCheckInDate;

  Future<void> loadHistory(String employeeId) async {
    if (employeeId.isEmpty) return;

    loading = true;
    notifyListeners();

    try {
      logs = await _service.fetchLogs(employeeId);

      if (logs.isNotEmpty) {
        final dates = logs
            .where((e) => e["time"] != null)
            .map<DateTime>(
              (e) => DateTime.parse(e["time"]).toLocal(), 
            )
            .toList()
          ..sort();

        firstCheckInDate = DateTime(
          dates.first.year,
          dates.first.month,
          dates.first.day,
        );
      }
    } catch (e) {
      logs = [];
      firstCheckInDate = null;
    }

    loading = false;
    notifyListeners();
  }

 
  Map<String, Map<String, DateTime>> groupedLogs() {
    final Map<String, Map<String, DateTime>> map = {};

    for (var log in logs) {
      if (log["time"] == null || log["log_type"] == null) continue;

      final time = DateTime.parse(log["time"]).toLocal(); // 🔥 FIX
      final key =
          "${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')}";

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
