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
  DateTime? selectedDay;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final empProvider = Provider.of<EmployeeProvider>(context, listen: false);

      final empId = empProvider.employeeId;
      if (empId == null || empId.isEmpty) return;

      Provider.of<AttendanceHistoryProvider>(
        context,
        listen: false,
      ).loadHistory(empId);
    });
  }

  //this function returns color for calendar day based on attendance status
  Color? _getCalendarColor(
    DateTime date,
    Map<String, Map<String, DateTime>> grouped,
  ) {
    final today = DateTime.now();
    final dayOnly = DateTime(date.year, date.month, date.day);
    final todayOnly = DateTime(today.year, today.month, today.day);

    if (dayOnly.isAfter(todayOnly)) return null;

    final key = "${date.year}-${date.month}-${date.day}";
    final data = grouped[key];

    if (data == null) return Colors.red;

    if (data["in"] != null && data["out"] != null) {
      return Colors.green;
    }

    return Colors.orange;
  }
  
  //this function calculates monthly summary of attendance
  Map<String, int> calculateMonthlySummary(
    DateTime month,
    Map<String, Map<String, DateTime>> grouped,
  ) {
    int present = 0;
    int absent = 0;
    int incomplete = 0;

    final today = DateTime.now();
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);

    for (
      DateTime day = firstDay;
      !day.isAfter(lastDay);
      day = day.add(const Duration(days: 1))
    ) {
      final dayOnly = DateTime(day.year, day.month, day.day);
      final todayOnly = DateTime(today.year, today.month, today.day);

      if (dayOnly.isAfter(todayOnly)) continue;

      final key = "${day.year}-${day.month}-${day.day}";
      final data = grouped[key];

      if (data == null) {
        absent++;
      } else if (data["in"] != null && data["out"] != null) {
        present++;
      } else {
        incomplete++;
      }
    }

    return {"present": present, "absent": absent, "incomplete": incomplete};
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AttendanceHistoryProvider>(context);
    final grouped = provider.groupedLogs();
    final summary = calculateMonthlySummary(focusedDay, grouped);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Attendance History",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('MMMM yyyy').format(focusedDay),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _summaryItem(
                                label: "Present",
                                count: summary["present"]!,
                                color: Colors.green,
                              ),
                              _summaryItem(
                                label: "Absent",
                                count: summary["absent"]!,
                                color: Colors.red,
                              ),
                              _summaryItem(
                                label: "Incomplete",
                                count: summary["incomplete"]!,
                                color: Colors.orange,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                TableCalendar(
                  firstDay: DateTime.utc(2023, 1, 1),
                  lastDay: DateTime.now(),
                  focusedDay: focusedDay,
                  selectedDayPredicate: (day) => isSameDay(day, selectedDay),
                  onDaySelected: (selected, focused) {
                    setState(() {
                      selectedDay = selected;
                      focusedDay = focused;
                    });
                  },
                  onPageChanged: (focused) {
                    setState(() {
                      focusedDay = focused;
                    });
                  },
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, _) {
                      final color = _getCalendarColor(day, grouped);
                      if (color == null) return null;

                      return Container(
                        margin: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color.withAlpha(60),
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
                      final date = DateTime.parse("${entry.key} 00:00:00");

                      final inTime = entry.value["in"];
                      final outTime = entry.value["out"];

                      final worked = (inTime != null && outTime != null)
                          ? outTime.difference(inTime)
                          : null;

                      return ListTile(
                        leading: const Icon(Icons.access_time),
                        title: Text(DateFormat('dd MMM yyyy').format(date)),
                        subtitle: Text(
                          inTime == null
                              ? "Absent"
                              : outTime == null
                              ? "Incomplete (No checkout)"
                              : "IN ${DateFormat('hh:mm a').format(inTime)} | "
                                    "OUT ${DateFormat('hh:mm a').format(outTime)} | "
                                    "Worked ${worked!.inHours}h "
                                    "${worked.inMinutes % 60}m",
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _summaryItem({
    required String label,
    required int count,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          "$count",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}
