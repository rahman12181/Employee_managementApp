import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/attendance_provider.dart';
import '../providers/employee_provider.dart';
import '../model/attendance_model.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime currentMonth = DateTime.now();

  Future<void> _refreshAttendance() async {
    final employeeId = context.read<EmployeeProvider>().employeeId;
    if (employeeId != null) {
      await context.read<AttendanceProvider>().loadMonthAttendance(
        employeeId,
        currentMonth,
      );
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

    final daysInMonth = DateUtils.getDaysInMonth(
      currentMonth.year,
      currentMonth.month,
    );

    bool canGoNext =
        currentMonth.year < now.year ||
        (currentMonth.year == now.year && currentMonth.month < now.month);

    final monthlyLogs = provider.getMonthlyLogs(currentMonth);

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _refreshAttendance,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ================= MONTH HEADER =================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () async {
                        setState(() {
                          currentMonth = DateTime(
                            currentMonth.year,
                            currentMonth.month - 1,
                          );
                        });
                        await _refreshAttendance();
                      },
                    ),
                    Text(
                      DateFormat('MMMM yyyy').format(currentMonth),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: canGoNext
                          ? () async {
                              setState(() {
                                currentMonth = DateTime(
                                  currentMonth.year,
                                  currentMonth.month + 1,
                                );
                              });
                              await _refreshAttendance();
                            }
                          : null,
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // ================= CALENDAR =================
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: daysInMonth,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                  ),
                  itemBuilder: (_, index) {
                    final day = index + 1;
                    final date = DateTime(
                      currentMonth.year,
                      currentMonth.month,
                      day,
                    );

                    final log = provider.attendanceMap[date];
                    final today = DateTime(now.year, now.month, now.day);

                    Color bgColor = Colors.grey.shade300;

                    if (date.isBefore(today) || date.isAtSameMomentAs(today)) {
                      bgColor = Colors.red;
                      if (log != null && log.checkIn != null) {
                        bgColor = Colors.green;
                      }
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          "$day",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: monthlyLogs.length,
                  itemBuilder: (_, index) {
                    final AttendanceLog log = monthlyLogs[index];

                    Color getAttendanceColor(AttendanceLog log) {
                      switch (log.status) {
                        case AttendanceStatus.presentCheckedIn:
                          return Colors.blue; 
                        case AttendanceStatus.presentCompleted:
                          return Colors.green; 
                        case AttendanceStatus.absent:
                          return Colors.red;
                      }
                    }

                    final statusColor = getAttendanceColor(log);

                    String statusText;
                    switch (log.status) {
                      case AttendanceStatus.presentCheckedIn:
                        statusText = "Present (Checked In)";
                        break;
                      case AttendanceStatus.presentCompleted:
                        statusText = "Present (Completed)";
                        break;
                      case AttendanceStatus.absent:
                        statusText = "Absent";
                        break;
                    }

                    String formatDuration(Duration duration) {
                      final hours = duration.inHours.toString().padLeft(2, '0');
                      final minutes = (duration.inMinutes % 60)
                          .toString()
                          .padLeft(2, '0');
                      return "$hours:$minutes";
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // DATE BOX
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: statusColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      DateFormat('dd').format(log.date),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      DateFormat('EEE').format(log.date),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            // INFO
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    statusText,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: statusColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text("Punch In  : ${log.checkIn ?? '--'}"),
                                  Text("Punch Out : ${log.checkOut ?? '--'}"),
                                  Text(
                                    "Total     : ${formatDuration(log.totalHours)}",
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
