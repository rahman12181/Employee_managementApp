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

  Future<void> _refreshAttendance() async {
    final employeeProvider = context.read<EmployeeProvider>();
    final attendanceProvider = context.read<AttendanceProvider>();
    
    final employeeId = employeeProvider.employeeId;
    
    if (employeeId != null) {
      await attendanceProvider.loadMonthAttendance(employeeId, _currentMonth);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshAttendance();
    });
  }


  Color _getStatusColor(AttendanceStatus status) {
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

  Widget _buildCalendarDay(int day, DateTime date, BuildContext context) {
    final attendanceProvider = context.watch<AttendanceProvider>();
    final punchProvider = context.read<PunchProvider>();
    final theme = Theme.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    Color? bgColor;
    Border? border;
    AttendanceStatus? status;

    for (final key in attendanceProvider.attendanceMap.keys) {
      if (key.year == date.year && key.month == date.month && key.day == date.day) {
        status = attendanceProvider.attendanceMap[key]!.status;
        break;
      }
    }

    if (date.isAfter(today)) {
      bgColor = Colors.transparent;
      border = Border.all(
        color: theme.dividerColor.withOpacity(0.5),
        width: 1.0,
      );
    } else if (date.isAtSameMomentAs(today)) {
      if (punchProvider.punchInTime != null) {
        status ??= AttendanceStatus.checkedIn;
        bgColor = _getStatusColor(status);
        border = Border.all(color: theme.colorScheme.primary, width: 2);
      } else {
        bgColor = Colors.grey.withOpacity(0.2);
        border = Border.all(
          color: Colors.grey.withOpacity(0.5),
          width: 1.5,
        );
      }
    } else {
      status ??= AttendanceStatus.absent;
      bgColor = _getStatusColor(status);
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.width * 0.12,
        maxWidth: MediaQuery.of(context).size.width * 0.12,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        border: border,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "$day",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: MediaQuery.of(context).size.width * 0.035,
              color: date.isAfter(today) 
                  ? theme.disabledColor 
                  : (bgColor != Colors.transparent && bgColor != Colors.grey.withOpacity(0.2) ? Colors.white : theme.colorScheme.onSurface),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            DateFormat('EEE').format(date),
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.025,
              color: date.isAfter(today) 
                  ? theme.disabledColor 
                  : (bgColor != Colors.transparent && bgColor != Colors.grey.withOpacity(0.2) ? Colors.white70 : theme.colorScheme.onSurface.withOpacity(0.6)),
            ),
          ),
        ],
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
      ),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Row(
          children: [
            Container(
              width: screenWidth * 0.13,
              height: screenWidth * 0.13,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('dd').format(log.date),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.05,
                    ),
                  ),
                  Text(
                    DateFormat('EEE').format(log.date),
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: screenWidth * 0.03,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(width: screenWidth * 0.04),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _getStatusText(log.status),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                            fontSize: screenWidth * 0.04,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isToday)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: const Text(
                            "Today",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTimeRow("In", log.formattedCheckIn),
                            const SizedBox(height: 4),
                            _buildTimeRow("Out", log.formattedCheckOut),
                          ],
                        ),
                      ),
                      
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "Total",
                            style: TextStyle(
                              fontSize: screenWidth * 0.03,
                              color: theme.hintColor,
                            ),
                          ),
                          Text(
                            log.formattedTotalHours,
                            style: TextStyle(
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRow(String label, String time) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Row(
      children: [
        SizedBox(
          width: screenWidth * 0.09,
          child: Text(
            "$label:",
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(width: screenWidth * 0.02),
        Text(
          time,
          style: TextStyle(
            fontSize: screenWidth * 0.036,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final attendanceProvider = context.watch<AttendanceProvider>();
    final now = DateTime.now();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final canGoNext = _currentMonth.year < now.year || 
                     (_currentMonth.year == now.year && _currentMonth.month < now.month);

    final daysInMonth = DateUtils.getDaysInMonth(
      _currentMonth.year,
      _currentMonth.month,
    );

    final monthlyLogs = attendanceProvider.getMonthlyLogs(_currentMonth);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshAttendance,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: () {
                              setState(() {
                                _currentMonth = DateTime(
                                  _currentMonth.year,
                                  _currentMonth.month - 1,
                                );
                              });
                              _refreshAttendance();
                            },
                            iconSize: screenWidth * 0.07,
                          ),
                          
                          Text(
                            DateFormat('MMMM yyyy').format(_currentMonth),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: screenWidth * 0.05,
                            ),
                          ),
                          
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: canGoNext ? () {
                              setState(() {
                                _currentMonth = DateTime(
                                  _currentMonth.year,
                                  _currentMonth.month + 1,
                                );
                              });
                              _refreshAttendance();
                            } : null,
                            color: canGoNext ? null : theme.disabledColor,
                            iconSize: screenWidth * 0.07,
                          ),
                        ],
                      ),
                      
                      if (attendanceProvider.isLoading)
                        const LinearProgressIndicator(),
                      
                      SizedBox(height: screenHeight * 0.02),
                      
                      if (attendanceProvider.errorMessage != null)
                        Container(
                          padding: EdgeInsets.all(screenWidth * 0.03),
                          margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, 
                                size: screenWidth * 0.05, 
                                color: Colors.red
                              ),
                              SizedBox(width: screenWidth * 0.02),
                              Expanded(
                                child: Text(
                                  attendanceProvider.errorMessage!,
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.035,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.close, size: screenWidth * 0.045),
                                onPressed: () => attendanceProvider.clearError(),
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                        ),
                      
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          crossAxisSpacing: screenWidth * 0.015,
                          mainAxisSpacing: screenWidth * 0.015,
                          childAspectRatio: 0.9,
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
                      
                      SizedBox(height: screenHeight * 0.03),
                      
                      Wrap(
                        spacing: screenWidth * 0.03,
                        runSpacing: screenWidth * 0.015,
                        children: [
                          _buildLegend(Colors.green, "Completed"),
                          _buildLegend(Colors.blue, "Overtime"),
                          _buildLegend(Colors.orange, "Shortage"),
                          _buildLegend(Colors.amber, "Checked In"),
                          _buildLegend(Colors.red, "Absent"),
                          _buildLegend(Colors.grey, "Not Checked"),
                          _buildLegendBorder(theme.colorScheme.primary, "Today"),
                        ],
                      ),
                      
                      SizedBox(height: screenHeight * 0.03),
                    ],
                  ),
                ),
              ),
              
              if (monthlyLogs.isNotEmpty)
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
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
                      },
                      childCount: monthlyLogs.length,
                    ),
                  ),
                )
              else if (!attendanceProvider.isLoading)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(screenWidth * 0.08),
                    child: Column(
                      children: [
                        Icon(
                          Icons.calendar_month,
                          size: screenWidth * 0.15,
                          color: theme.disabledColor,
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          "No attendance records",
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color: theme.hintColor,
                          ),
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
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: screenWidth * 0.025,
          height: screenWidth * 0.025,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: screenWidth * 0.015),
        Text(
          text,
          style: TextStyle(fontSize: screenWidth * 0.03),
        ),
      ],
    );
  }

  Widget _buildLegendBorder(Color color, String text) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: screenWidth * 0.025,
          height: screenWidth * 0.025,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: color, width: 1.5),
          ),
        ),
        SizedBox(width: screenWidth * 0.015),
        Text(
          text,
          style: TextStyle(fontSize: screenWidth * 0.03),
        ),
      ],
    );
  }
}