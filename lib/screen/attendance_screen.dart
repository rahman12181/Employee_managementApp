// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/attendance_provider.dart';
import '../providers/employee_provider.dart';
import '../providers/punch_provider.dart';
import '../model/attendance_model.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime _currentMonth = DateTime.now();
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshAttendance();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshAttendance() async {
    final employeeProvider = context.read<EmployeeProvider>();
    final attendanceProvider = context.read<AttendanceProvider>();

    final employeeId = employeeProvider.employeeId;

    if (employeeId != null) {
      await attendanceProvider.loadMonthAttendance(employeeId, _currentMonth);
    }
  }

  Color _getStatusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.completed:
        return Colors.green;
      case AttendanceStatus.overtime:
        return Colors.blue.shade600;
      case AttendanceStatus.shortage:
        return Colors.orange;
      case AttendanceStatus.checkedIn:
        return Colors.amber.shade600;
      case AttendanceStatus.absent:
        return Colors.red;
    }
  }

  String _getStatusText(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.completed:
        return "Completed";
      case AttendanceStatus.overtime:
        return "Overtime";
      case AttendanceStatus.shortage:
        return "Shortage";
      case AttendanceStatus.checkedIn:
        return "Checked In";
      case AttendanceStatus.absent:
        return "Absent";
    }
  }

  IconData _getStatusIcon(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.completed:
        return Icons.check_circle;
      case AttendanceStatus.overtime:
        return Icons.timer;
      case AttendanceStatus.shortage:
        return Icons.schedule;
      case AttendanceStatus.checkedIn:
        return Icons.login;
      case AttendanceStatus.absent:
        return Icons.cancel;
    }
  }

  Widget _buildCalendarDay(int day, DateTime date, BuildContext context) {
    final attendanceProvider = context.watch<AttendanceProvider>();
    final punchProvider = context.read<PunchProvider>();
    final theme = Theme.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    Color? bgColor;
    Color? textColor;
    Border? border;
    AttendanceStatus? status;
    double opacity = 1.0;

    for (final key in attendanceProvider.attendanceMap.keys) {
      if (key.year == date.year &&
          key.month == date.month &&
          key.day == date.day) {
        status = attendanceProvider.attendanceMap[key]!.status;
        break;
      }
    }

    if (date.isAfter(today)) {
      bgColor = Colors.transparent;
      textColor = theme.disabledColor;
      border = Border.all(
        color: theme.dividerColor.withOpacity(0.3),
        width: 1.0,
      );
      opacity = 0.5;
    } else if (date.isAtSameMomentAs(today)) {
      if (punchProvider.punchInTime != null) {
        status ??= AttendanceStatus.checkedIn;
        bgColor = _getStatusColor(status);
        textColor = Colors.white;
        border = Border.all(color: theme.colorScheme.primary, width: 2.5);
      } else {
        bgColor = Colors.grey.withOpacity(0.1);
        textColor = theme.disabledColor;
        border = Border.all(color: Colors.grey.withOpacity(0.4), width: 1.5);
      }
    } else {
      status ??= AttendanceStatus.absent;
      bgColor = _getStatusColor(status);
      textColor = Colors.white;
      if (status == AttendanceStatus.absent) {
        opacity = 0.9;
      }
    }

    return Opacity(
      opacity: opacity,
      child: Container(
        width: screenWidth * 0.11,
        height: screenWidth * 0.11,
        margin: EdgeInsets.all(screenWidth * 0.005),
        decoration: BoxDecoration(
          color: bgColor,
          border: border,
          borderRadius: BorderRadius.circular(8),
          boxShadow:
              date.isAtSameMomentAs(today) && punchProvider.punchInTime != null
              ? [
                  BoxShadow(
                    color: _getStatusColor(
                      status ?? AttendanceStatus.checkedIn,
                    ).withOpacity(0.3),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "$day",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: screenWidth * 0.035,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.002),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  DateFormat('EEE').format(date).substring(0, 1),
                  style: TextStyle(
                    fontSize: screenWidth * 0.022,
                    fontWeight: FontWeight.w600,
                    color: textColor.withOpacity(0.8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceLog(AttendanceLog log) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isToday = log.date.isAtSameMomentAs(today);
    final statusColor = _getStatusColor(log.status);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.015),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.035),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Badge
            Container(
              width: screenWidth * 0.14,
              height: screenWidth * 0.14,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [statusColor, statusColor.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        DateFormat('dd').format(log.date),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: screenWidth * 0.045,
                          height: 0.9,
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        DateFormat('MMM').format(log.date),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: screenWidth * 0.025,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: screenWidth * 0.035),

            // Log Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getStatusIcon(log.status),
                        color: statusColor,
                        size: screenWidth * 0.04,
                      ),
                      SizedBox(width: screenWidth * 0.015),
                      Expanded(
                        child: Text(
                          _getStatusText(log.status),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                            fontSize: screenWidth * 0.035,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isToday)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.02,
                            vertical: screenHeight * 0.004,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade400,
                                Colors.blue.shade600,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "Today",
                            style: TextStyle(
                              fontSize: screenWidth * 0.025,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),

                  SizedBox(height: screenHeight * 0.01),

                  // Time Details
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.025),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildTimeRow(
                                context,
                                "Punch In",
                                log.formattedCheckIn,
                                Icons.login_rounded,
                                Colors.blue,
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.025),
                            Expanded(
                              child: _buildTimeRow(
                                context,
                                "Punch Out",
                                log.formattedCheckOut,
                                Icons.logout_rounded,
                                Colors.red,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: screenHeight * 0.008),

                        // Total Hours
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.03,
                            vertical: screenHeight * 0.008,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade50,
                                Colors.purple.shade50,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Total: ",
                                style: TextStyle(
                                  fontSize: screenWidth * 0.03,
                                  color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.9),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                log.formattedTotalHours,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.035,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRow(
    BuildContext context,
    String label,
    String time,
    IconData icon,
    Color color,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(screenWidth * 0.02),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: color, size: screenWidth * 0.035),
        ),
        SizedBox(width: screenWidth * 0.02),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: screenWidth * 0.028,
                  color: theme.hintColor,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: screenWidth * 0.002),
              Text(
                time,
                style: TextStyle(
                  fontSize: screenWidth * 0.032,
                  fontWeight: FontWeight.w700,
                  color: theme.textTheme.bodyLarge?.color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final attendanceProvider = context.watch<AttendanceProvider>();
    final now = DateTime.now();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final canGoNext =
        _currentMonth.year < now.year ||
        (_currentMonth.year == now.year && _currentMonth.month < now.month);

    final daysInMonth = DateUtils.getDaysInMonth(
      _currentMonth.year,
      _currentMonth.month,
    );

    final monthlyLogs = attendanceProvider.getMonthlyLogs(_currentMonth);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator.adaptive(
          onRefresh: _refreshAttendance,
          color: Colors.blue,
          backgroundColor: theme.cardColor,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // App Bar
              SliverAppBar(
                backgroundColor: theme.scaffoldBackgroundColor,
                elevation: 0,
                pinned: true,
                floating: true,
                title: Text(
                  "Attendance",
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.w800,
                    color: theme.textTheme.titleLarge?.color,
                  ),
                ),
                centerTitle: false,
                actions: [
                  IconButton(
                    icon: Icon(
                      Icons.refresh_rounded,
                      size: screenWidth * 0.055,
                    ),
                    onPressed: _refreshAttendance,
                    tooltip: 'Refresh',
                  ),
                ],
              ),

              // Calendar Section
              SliverToBoxAdapter(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.035),
                  padding: EdgeInsets.all(screenWidth * 0.035),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Month Selector
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.02,
                          vertical: screenHeight * 0.008,
                        ),
                        decoration: BoxDecoration(
                          color: theme.scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.chevron_left_rounded,
                                size: screenWidth * 0.055,
                                color: theme.iconTheme.color,
                              ),
                              onPressed: () {
                                setState(() {
                                  _currentMonth = DateTime(
                                    _currentMonth.year,
                                    _currentMonth.month - 1,
                                  );
                                });
                                _refreshAttendance();
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),

                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.04,
                                vertical: screenHeight * 0.008,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isDarkMode
                                      ? [
                                          Colors.blue.shade800,
                                          Colors.green.shade800,
                                        ]
                                      : [
                                          Colors.blue.shade50,
                                          Colors.purple.shade50,
                                        ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                DateFormat('MMMM yyyy').format(_currentMonth),
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            IconButton(
                              icon: Icon(
                                Icons.chevron_right_rounded,
                                size: screenWidth * 0.055,
                                color: canGoNext
                                    ? theme.iconTheme.color
                                    : theme.disabledColor,
                              ),
                              onPressed: canGoNext
                                  ? () {
                                      setState(() {
                                        _currentMonth = DateTime(
                                          _currentMonth.year,
                                          _currentMonth.month + 1,
                                        );
                                      });
                                      _refreshAttendance();
                                    }
                                  : null,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.02),

                      // Loading Indicator
                      if (attendanceProvider.isLoading)
                        LinearProgressIndicator(
                          backgroundColor: theme.scaffoldBackgroundColor,
                          color: Colors.blue,
                          minHeight: 1.5,
                        ),

                      // Error Message
                      if (attendanceProvider.errorMessage != null)
                        Container(
                          padding: EdgeInsets.all(screenWidth * 0.03),
                          margin: EdgeInsets.only(bottom: screenHeight * 0.015),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                size: screenWidth * 0.045,
                                color: Colors.red,
                              ),
                              SizedBox(width: screenWidth * 0.02),
                              Expanded(
                                child: Text(
                                  attendanceProvider.errorMessage!,
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.032,
                                    color: Colors.red.shade700,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),

                      SizedBox(height: screenHeight * 0.015),

                      // Calendar Grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          crossAxisSpacing: screenWidth * 0.01,
                          mainAxisSpacing: screenWidth * 0.01,
                          childAspectRatio: 1,
                        ),
                        itemCount: daysInMonth,
                        itemBuilder: (context, index) {
                          final day = index + 1;
                          final date = DateTime(
                            _currentMonth.year,
                            _currentMonth.month,
                            day,
                          );
                          return _buildCalendarDay(day, date, context);
                        },
                      ),

                      SizedBox(height: screenHeight * 0.025),

                      // Legend
                      Wrap(
                        spacing: screenWidth * 0.02,
                        runSpacing: screenHeight * 0.01,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildLegend(Colors.green, "Completed"),
                          _buildLegend(Colors.blue.shade600, "Overtime"),
                          _buildLegend(Colors.orange, "Shortage"),
                          _buildLegend(Colors.amber.shade600, "Checked In"),
                          _buildLegend(Colors.red, "Absent"),
                          _buildLegend(Colors.grey.withOpacity(0.3), "Future"),
                          _buildLegendBorder(Colors.blue, "Today"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Attendance Logs Title
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    screenWidth * 0.035,
                    screenHeight * 0.025,
                    screenWidth * 0.035,
                    screenHeight * 0.015,
                  ),
                  child: Text(
                    "Attendance Logs",
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.w700,
                      color: theme.textTheme.titleLarge?.color,
                    ),
                  ),
                ),
              ),

              // Attendance Logs List
              if (monthlyLogs.isNotEmpty)
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    screenWidth * 0.035,
                    0,
                    screenWidth * 0.035,
                    screenHeight * 0.03,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final log = monthlyLogs[index];
                      final now = DateTime.now();
                      final today = DateTime(now.year, now.month, now.day);

                      if (log.date.isAtSameMomentAs(today)) {
                        final punchProvider = context.read<PunchProvider>();
                        if (punchProvider.punchInTime == null) {
                          return const SizedBox.shrink();
                        }
                      }

                      return _buildAttendanceLog(log);
                    }, childCount: monthlyLogs.length),
                  ),
                )
              else if (!attendanceProvider.isLoading)
                SliverToBoxAdapter(
                  child: Container(
                    margin: EdgeInsets.all(screenWidth * 0.035),
                    padding: EdgeInsets.all(screenWidth * 0.05),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: screenWidth * 0.12,
                          color: theme.disabledColor.withOpacity(0.5),
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        Text(
                          "No attendance records",
                          style: TextStyle(
                            fontSize: screenWidth * 0.038,
                            color: theme.hintColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.008),
                        Text(
                          "Attendance records will appear here",
                          style: TextStyle(
                            fontSize: screenWidth * 0.032,
                            color: theme.hintColor.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(Color color, String text) {
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.025,
        vertical: screenWidth * 0.012,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: screenWidth * 0.025,
            height: screenWidth * 0.025,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: screenWidth * 0.015),
          Text(
            text,
            style: TextStyle(
              fontSize: screenWidth * 0.028,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendBorder(Color color, String text) {
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.025,
        vertical: screenWidth * 0.012,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: screenWidth * 0.025,
            height: screenWidth * 0.025,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 1.5),
            ),
          ),
          SizedBox(width: screenWidth * 0.015),
          Text(
            text,
            style: TextStyle(
              fontSize: screenWidth * 0.028,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
