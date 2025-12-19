import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../providers/attendance_history_provider.dart';
import '../providers/employee_provider.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  DateTime focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final empId =
          Provider.of<EmployeeProvider>(context, listen: false).employeeId;
      if (empId == null || empId.isEmpty) return;

      Provider.of<AttendanceHistoryProvider>(context, listen: false)
          .loadHistory(empId);
    });
  }

 
  Color? _getCalendarColor(
    DateTime date,
    Map<String, Map<String, DateTime>> grouped,
    DateTime? startDate,
  ) {
    if (startDate == null) return null;

    final today = DateTime.now();
    final dayOnly = DateTime(date.year, date.month, date.day);
    final todayOnly = DateTime(today.year, today.month, today.day);

    if (dayOnly.isBefore(startDate) || dayOnly.isAfter(todayOnly)) {
      return null;
    }

    final key =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    final data = grouped[key];

    if (data == null) return Colors.red;
    if (data["in"] != null && data["out"] != null) return Colors.green;
    return Colors.orange;
  }

 
  Map<String, int> calculateMonthlySummary(
    DateTime month,
    Map<String, Map<String, DateTime>> grouped,
    DateTime? startDate,
  ) {
    int present = 0;
    int absent = 0;
    int incomplete = 0;

    if (startDate == null) {
      return {"present": 0, "absent": 0, "incomplete": 0};
    }

    final today = DateTime.now();
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);

    for (DateTime day = firstDay;
        !day.isAfter(lastDay);
        day = day.add(const Duration(days: 1))) {
      final dayOnly = DateTime(day.year, day.month, day.day);
      final todayOnly =
          DateTime(today.year, today.month, today.day);

      if (dayOnly.isBefore(startDate) || dayOnly.isAfter(todayOnly)) continue;

      final key =
          "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";

      final data = grouped[key];

      if (data == null) {
        absent++;
      } else if (data["in"] != null && data["out"] != null) {
        present++;
      } else {
        incomplete++;
      }
    }

    return {
      "present": present,
      "absent": absent,
      "incomplete": incomplete,
    };
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AttendanceHistoryProvider>(context);
    final grouped = provider.groupedLogs();
    final startDate = provider.firstCheckInDate;

    final summary =
        calculateMonthlySummary(focusedDay, grouped, startDate);

    return Scaffold(
      
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
               
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 40, 10, 10),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _summary("Present", summary["present"]!, Colors.green),
                          _summary("Absent", summary["absent"]!, Colors.red),
                          _summary(
                              "Incomplete",
                              summary["incomplete"]!,
                              Colors.orange),
                        ],
                      ),
                    ),
                  ),
                ),

             
                TableCalendar(
                  firstDay: DateTime.utc(2023, 1, 1),
                  lastDay: DateTime.now(),
                  focusedDay: focusedDay,
                  onPageChanged: (d) => setState(() => focusedDay = d),
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, _) {
                      final color =
                          _getCalendarColor(day, grouped, startDate);
                      if (color == null) return null;

                      return Container(
                        margin: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color.withAlpha(50),
                        ),
                        child: Center(
                          child: Text(
                            "${day.day}",
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const Divider(),

                Expanded(
                  child: ListView(
                    children: grouped.entries.map((entry) {
                      final parts = entry.key.split("-");
                      final date = DateTime(
                        int.parse(parts[0]),
                        int.parse(parts[1]),
                        int.parse(parts[2]),
                      );

                      final inTime = entry.value["in"];
                      final outTime = entry.value["out"];

                      final worked = (inTime != null && outTime != null)
                          ? outTime.difference(inTime)
                          : null;

                      return ListTile(
                        leading: const Icon(Icons.access_time),
                        title: Text(
                          DateFormat('dd MMM yyyy (EEE)').format(date),
                        ),
                        subtitle: Text(
                          inTime == null
                              ? "Absent"
                              : outTime == null
                                  ? "Incomplete (No checkout)"
                                  : "IN ${DateFormat('hh:mm a').format(inTime)} | "
                                    "OUT ${DateFormat('hh:mm a').format(outTime)} | "
                                    "Worked ${worked!.inHours}h ${worked.inMinutes % 60}m",
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _summary(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          "$value",
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: color),
        ),
        Text(label),
      ],
    );
  }
}
