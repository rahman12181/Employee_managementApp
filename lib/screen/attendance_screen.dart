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
      await context.read<AttendanceProvider>()
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
        return Colors.amber;
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = context.watch<AttendanceProvider>();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final daysInMonth =
        DateUtils.getDaysInMonth(currentMonth.year, currentMonth.month);

    bool canGoNext =
        currentMonth.year < now.year ||
        (currentMonth.year == now.year &&
            currentMonth.month < now.month);

    final monthlyLogs = provider.getMonthlyLogs(currentMonth);
    
    // Get screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final padding = MediaQuery.of(context).padding;
    
    // Calculate calendar cell size to fit within 95% of screen width
    final availableWidth = screenWidth * 0.95;
    final cellSpacing = 6.0;
    final cellSize = (availableWidth - (cellSpacing * 6)) / 7;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshAttendance,
          child: SingleChildScrollView(   
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                screenWidth * 0.025, // 2.5% padding on sides
                padding.top + 20,
                screenWidth * 0.025,
                16,
              ),
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
                        style: theme.textTheme.titleMedium?.copyWith(
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

                  const SizedBox(height: 12),

                  /// CALENDAR GRID (FIXED OVERFLOW)
                  Container(
                    width: availableWidth,
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: daysInMonth,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        crossAxisSpacing: cellSpacing,
                        mainAxisSpacing: cellSpacing,
                        childAspectRatio: 0.9, // Fixed aspect ratio
                      ),
                      itemBuilder: (_, index) {
                        final day = index + 1;
                        final date = DateTime(
                          currentMonth.year,
                          currentMonth.month,
                          day,
                        );

                        Color? bgColor;
                        Border? border;

                        final log = provider.attendanceMap[date];

                        if (date.isAfter(today)) {
                          bgColor = null;
                          border = Border.all(
                            color: theme.dividerColor,
                          );
                        } else if (date == today) {
                          bgColor = log != null
                              ? getStatusColor(log.status)
                              : null;
                          border = Border.all(
                            color: theme.colorScheme.primary,
                            width: 2,
                          );
                        } else {
                          final status =
                              log?.status ?? AttendanceStatus.absent;
                          bgColor = getStatusColor(status);
                        }

                        return Container(
                          constraints: BoxConstraints(
                            maxHeight: cellSize,
                            maxWidth: cellSize,
                          ),
                          decoration: BoxDecoration(
                            color: bgColor,
                            border: border,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "$day",
                                style: TextStyle(
                                  fontSize: cellSize * 0.25, // Responsive font size
                                  color: bgColor == null
                                      ? theme.textTheme.bodyMedium?.color
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: cellSize * 0.05),
                              Text(
                                DateFormat('E').format(date),
                                style: TextStyle(
                                  fontSize: cellSize * 0.15, // Responsive font size
                                  color: bgColor == null
                                      ? theme.hintColor
                                      : Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 18),

                  /// LEGEND (Made responsive)
                  Container(
                    width: availableWidth,
                    child: Wrap(
                      spacing: screenWidth * 0.03,
                      runSpacing: 8,
                      children: [
                        _legend(Colors.green, "Completed", screenWidth),
                        _legend(Colors.blue, "Overtime", screenWidth),
                        _legend(Colors.orange, "Shortage", screenWidth),
                        _legend(Colors.amber, "Checked In", screenWidth),
                        _legend(Colors.red, "Absent", screenWidth),
                        _legendBorder("Today", screenWidth),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// ATTENDANCE LIST (Made responsive)
                  Container(
                    width: availableWidth,
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: monthlyLogs.length,
                      itemBuilder: (_, index) {
                        final log = monthlyLogs[index];
                        final statusColor = getStatusColor(log.status);

                        String formatDuration(Duration d) {
                          final h =
                              d.inHours.toString().padLeft(2, '0');
                          final m =
                              (d.inMinutes % 60).toString().padLeft(2, '0');
                          return "$h:$m";
                        }

                        return Container(
                          margin: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.008,
                          ),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: isDark
                                ? []
                                : [
                                    const BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 6,
                                      offset: Offset(0, 3),
                                    )
                                  ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(screenWidth * 0.04),
                            child: Row(
                              children: [
                                Container(
                                  width: screenWidth * 0.14,
                                  height: screenWidth * 0.14,
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    borderRadius:
                                        BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          DateFormat('dd')
                                              .format(log.date),
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.04,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: screenWidth * 0.005),
                                        Text(
                                          DateFormat('EEE')
                                              .format(log.date),
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.03,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.04),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        getStatusText(log.status),
                                        style: theme
                                            .textTheme.bodyMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: statusColor,
                                          fontSize: screenWidth * 0.035,
                                        ),
                                      ),
                                      SizedBox(height: screenHeight * 0.008),
                                      Text(
                                        "In   : ${log.checkIn ?? '--'}",
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.033,
                                        ),
                                      ),
                                      Text(
                                        "Out : ${log.checkOut ?? '--'}",
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.033,
                                        ),
                                      ),
                                      Text(
                                        "Total : ${formatDuration(log.totalHours)}",
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.033,
                                        ),
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _legend(Color color, String text, double screenWidth) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: screenWidth * 0.03,
          height: screenWidth * 0.03,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        SizedBox(width: screenWidth * 0.015),
        Text(
          text, 
          style: TextStyle(
            fontSize: screenWidth * 0.03,
          ),
        ),
      ],
    );
  }

  Widget _legendBorder(String text, double screenWidth) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: screenWidth * 0.03,
          height: screenWidth * 0.03,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.blue,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        SizedBox(width: screenWidth * 0.015),
        Text(
          text, 
          style: TextStyle(
            fontSize: screenWidth * 0.03,
          ),
        ),
      ],
    );
  }
}