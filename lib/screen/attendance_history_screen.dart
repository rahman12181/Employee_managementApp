import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/attendance_history_provider.dart';
import '../providers/employee_provider.dart';
import 'package:table_calendar/table_calendar.dart';

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
      final empId =
          Provider.of<EmployeeProvider>(context, listen: false).employeeId;
      Provider.of<AttendanceHistoryProvider>(context, listen: false)
          .loadHistory(empId!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AttendanceHistoryProvider>(context);
    final grouped = provider.groupedLogs();

    return Scaffold(
      appBar: AppBar(title: const Text("Attendance History")),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                TableCalendar(
                  firstDay: DateTime.utc(2023, 1, 1),
                  lastDay: DateTime.now(),
                  focusedDay: focusedDay,
                  selectedDayPredicate: (day) =>
                      isSameDay(day, selectedDay),
                  onDaySelected: (selected, focused) {
                    setState(() {
                      selectedDay = selected;
                      focusedDay = focused;
                    });
                  },
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, _) {
                      final data = grouped[date];
                      if (data == null) return null;

                      if (data["in"] != null && data["out"] != null) {
                        return _dot(Colors.green);
                      } else {
                        return _dot(Colors.orange);
                      }
                    },
                  ),
                ),

                const Divider(),

               
                Expanded(
                  child: ListView(
                    children: grouped.entries.map((entry) {
                      final date = entry.key;
                      final inTime = entry.value["in"];
                      final outTime = entry.value["out"];

                      final worked = (inTime != null && outTime != null)
                          ? outTime.difference(inTime)
                          : null;

                      return ListTile(
                        leading: const Icon(Icons.access_time),
                        title: Text(
                            DateFormat('dd MMM yyyy').format(date)),
                        subtitle: Text(
                          inTime == null
                              ? "Absent"
                              : outTime == null
                                  ? "Incomplete"
                                  : "IN ${DateFormat('hh:mm a').format(inTime)} | "
                                    "OUT ${DateFormat('hh:mm a').format(outTime)} | "
                                    "Worked ${worked!.inHours}h ${(worked.inMinutes % 60)}m",
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _dot(Color color) {
    return Container(
      width: 7,
      height: 7,
      margin: const EdgeInsets.only(top: 35),
      decoration:
          BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
