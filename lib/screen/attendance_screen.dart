import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/attendance_provider.dart';
import '../providers/employee_provider.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime currentMonth = DateTime.now();
  DateTime? selectedDate;

  Future<void> _refreshAttendance() async {
    final employeeId =
        context.read<EmployeeProvider>().employeeId;
    if (employeeId != null) {
      await context
          .read<AttendanceProvider>()
          .loadMonthAttendance(employeeId, currentMonth);
    }
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _refreshAttendance());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AttendanceProvider>();
    final now = DateTime.now();

    final daysInMonth =
        DateUtils.getDaysInMonth(currentMonth.year, currentMonth.month);

    bool canGoNext =
        currentMonth.year < now.year ||
        (currentMonth.year == now.year &&
            currentMonth.month < now.month);

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _refreshAttendance, // 🔴 PULL TO REFRESH
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Month Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () async {
                        setState(() {
                          currentMonth = DateTime(
                              currentMonth.year, currentMonth.month - 1);
                        });
                        await _refreshAttendance();
                      },
                    ),
                    Text(
                      DateFormat('MMMM yyyy').format(currentMonth),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: canGoNext
                          ? () async {
                              setState(() {
                                currentMonth = DateTime(
                                    currentMonth.year,
                                    currentMonth.month + 1);
                              });
                              await _refreshAttendance();
                            }
                          : null,
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Day Names
                Row(
                  children: List.generate(7, (i) {
                    final day = DateFormat.E()
                        .format(DateTime(2020, 1, i + 5));
                    return Expanded(
                      child: Center(
                        child: Text(day,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black54)),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 6),

                // Calendar Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: daysInMonth,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                  ),
                  itemBuilder: (_, index) {
                    final day = index + 1;
                    final date = DateTime(
                        currentMonth.year, currentMonth.month, day);

                    final log = provider.attendanceMap[date];
                    final today = DateTime(now.year, now.month, now.day);

                    Color bgColor = Colors.grey.shade300;

                    if (date.isBefore(today) ||
                        date.isAtSameMomentAs(today)) {
                      bgColor = Colors.red;
                      if (log != null && log.checkIn != null) {
                        bgColor = Colors.green;
                      }
                    }

                    return GestureDetector(
                      onTap: () => setState(() => selectedDate = date),
                      child: Container(
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(10),
                          border: selectedDate == date
                              ? Border.all(color: Colors.black, width: 2)
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            "$day",
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Logs
                _buildLogs(provider),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogs(AttendanceProvider provider) {
    if (selectedDate == null) {
      return const Padding(
        padding: EdgeInsets.only(top: 40),
        child: Text("Pull down or tap a date to see logs",
            style: TextStyle(color: Colors.grey)),
      );
    }

    final log = provider.attendanceMap[selectedDate!];
    if (log == null) {
      return const Padding(
        padding: EdgeInsets.only(top: 20),
        child: Text("Absent on this day"),
      );
    }

    return Card(
      margin: const EdgeInsets.only(top: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('dd MMM yyyy').format(selectedDate!),
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text("Check In : ${log.checkIn ?? '--'}"),
            Text("Check Out : ${log.checkOut ?? '--'}"),
            Text("Total Hours : ${log.totalHours}"),
          ],
        ),
      ),
    );
  }
}
