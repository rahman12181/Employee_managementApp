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

  Color getStatusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.completed:
        return Colors.green;
      case AttendanceStatus.overtime:
        return Colors.blue;
      case AttendanceStatus.shortage:
        return Colors.orange;
      case AttendanceStatus.checkedIn:
        return Colors.yellow.shade700;
      case AttendanceStatus.absent:
        return Colors.red;
    }
  }

  String getStatusText(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.completed:
        return "Completed (8–9 hrs)";
      case AttendanceStatus.overtime:
        return "Overtime (9+ hrs)";
      case AttendanceStatus.shortage:
        return "Shortage (< 8 hrs)";
      case AttendanceStatus.checkedIn:
        return "Checked In";
      case AttendanceStatus.absent:
        return "Absent";
    }
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
        (currentMonth.year == now.year &&
            currentMonth.month < now.month);

    final monthlyLogs = provider.getMonthlyLogs(currentMonth);

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _refreshAttendance,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 30, 10, 10),
            child: Column(
              children: [
               
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
                      currentMonth.year,
                      currentMonth.month,
                      day,
                    );

                    final log = provider.attendanceMap[date];
                    final status =
                        log?.status ?? AttendanceStatus.absent;

                    final bgColor = getStatusColor(status);

                    return Container(
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "$day",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            DateFormat('E').format(date), // M T W
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _legend(Colors.green, "Completed"),
                    _legend(Colors.blue, "Overtime"),
                    _legend(Colors.orange, "Shortage"),
                    _legend(Colors.yellow.shade700, "Checked In"),
                    _legend(Colors.red, "Absent"),
                  ],
                ),

                const SizedBox(height: 20),
                
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: monthlyLogs.length,
                  itemBuilder: (_, index) {
                    final log = monthlyLogs[index];
                    final statusColor = getStatusColor(log.status);

                    String formatDuration(Duration duration) {
                      final h = duration.inHours.toString().padLeft(2, '0');
                      final m =
                          (duration.inMinutes % 60).toString().padLeft(2, '0');
                      return "$h:$m";
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    getStatusText(log.status),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: statusColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text("In  : ${log.checkIn ?? '--'}"),
                                  Text("Out : ${log.checkOut ?? '--'}"),
                                  Text(
                                    "Total : ${formatDuration(log.totalHours)}",
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

  Widget _legend(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
