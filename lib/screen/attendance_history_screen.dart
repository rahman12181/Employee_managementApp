// screens/attendance_history_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:management_app/providers/attendance_history_provider.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  late DateTime _currentDisplayMonth;

  @override
  void initState() {
    super.initState();
    _currentDisplayMonth = DateTime.now();
    _loadAttendanceData();
  }

  Future<void> _loadAttendanceData() async {
    final provider = Provider.of<AttendanceHistoryProvider>(context, listen: false);
    await provider.loadAttendanceForMonth(_currentDisplayMonth);
  }

  void _previousMonth() {
    setState(() {
      _currentDisplayMonth = DateTime(_currentDisplayMonth.year, _currentDisplayMonth.month - 1);
    });
    _loadAttendanceData();
  }

  void _nextMonth() {
    setState(() {
      _currentDisplayMonth = DateTime(_currentDisplayMonth.year, _currentDisplayMonth.month + 1);
    });
    _loadAttendanceData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAttendanceData,
          ),
        ],
      ),
      body: Consumer<AttendanceHistoryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Month Selector with Statistics
                _buildMonthSelector(provider),
                
                // Calendar View
                _buildCalendarView(provider),
                
                // Attendance List
                _buildAttendanceList(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMonthSelector(AttendanceHistoryProvider provider) {
    final stats = provider.getMonthlyStatistics();
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Month Navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: _previousMonth,
                ),
                Text(
                  DateFormat('MMMM yyyy').format(_currentDisplayMonth),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: _nextMonth,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Statistics
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Present', stats['present'].toString(), Colors.green),
                _buildStatItem('Absent', stats['absent'].toString(), Colors.red),
                _buildStatItem('Avg Hours', stats['avg_hours'], Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            title == 'Present' ? Icons.check_circle :
            title == 'Absent' ? Icons.cancel :
            Icons.access_time,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarView(AttendanceHistoryProvider provider) {
    final firstDay = DateTime(_currentDisplayMonth.year, _currentDisplayMonth.month, 1);
    final lastDay = DateTime(_currentDisplayMonth.year, _currentDisplayMonth.month + 1, 0);
    final startWeekday = firstDay.weekday;
    final totalDays = lastDay.day;
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Weekday Headers
            const Row(
              children: [
                Expanded(child: Center(child: Text('Sun', style: TextStyle(fontWeight: FontWeight.bold)))),
                Expanded(child: Center(child: Text('Mon', style: TextStyle(fontWeight: FontWeight.bold)))),
                Expanded(child: Center(child: Text('Tue', style: TextStyle(fontWeight: FontWeight.bold)))),
                Expanded(child: Center(child: Text('Wed', style: TextStyle(fontWeight: FontWeight.bold)))),
                Expanded(child: Center(child: Text('Thu', style: TextStyle(fontWeight: FontWeight.bold)))),
                Expanded(child: Center(child: Text('Fri', style: TextStyle(fontWeight: FontWeight.bold)))),
                Expanded(child: Center(child: Text('Sat', style: TextStyle(fontWeight: FontWeight.bold)))),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Calendar Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1.0,
              ),
              itemCount: 42, // 6 weeks
              itemBuilder: (context, index) {
                final dayOffset = index - startWeekday;
                final currentDate = firstDay.add(Duration(days: dayOffset));
                
                return _buildCalendarDay(currentDate, provider);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarDay(DateTime date, AttendanceHistoryProvider provider) {
    final isCurrentMonth = date.month == _currentDisplayMonth.month;
    final isToday = _isSameDate(date, DateTime.now());
    
    // Get attendance for this date
    final attendance = provider.getAttendanceForDate(date);
    final isPresent = attendance != null && attendance['is_present'] == true;
    
    // Calculate colors
    Color bgColor = Colors.transparent;
    Color textColor = isCurrentMonth ? Colors.black : Colors.grey[300]!;
    
    if (isToday) {
      bgColor = Colors.blue.withOpacity(0.1);
    } else if (isPresent) {
      bgColor = Colors.green;
      textColor = Colors.white;
    } else if (isCurrentMonth && date.isBefore(DateTime.now())) {
      // Past date with no attendance = Absent
      bgColor = Colors.red;
      textColor = Colors.white;
    }
    
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: isToday ? Border.all(color: Colors.blue, width: 2) : null,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              date.day.toString(),
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (attendance != null && attendance['is_present'] && attendance['total_hours'] != '00:00')
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Text(
                  attendance['total_hours'],
                  style: TextStyle(
                    fontSize: 9,
                    color: textColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceList(AttendanceHistoryProvider provider) {
    if (provider.attendanceRecords.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'No attendance records found for this month',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
          child: Text(
            'Daily Attendance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.attendanceRecords.length,
          itemBuilder: (context, index) {
            final record = provider.attendanceRecords[index];
            return _buildAttendanceListItem(record);
          },
        ),
      ],
    );
  }

  Widget _buildAttendanceListItem(Map<String, dynamic> record) {
    final date = record['date'] as DateTime;
    final isPresent = record['is_present'] as bool;
    final punchIn = record['punch_in'];
    final punchOut = record['punch_out'];
    final totalHours = record['total_hours'] as String;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: isPresent ? Colors.green[50] : Colors.red[50],
      child: ListTile(
        onTap: () => _showDetails(record),
        leading: CircleAvatar(
          backgroundColor: isPresent ? Colors.green : Colors.red,
          child: Text(
            date.day.toString(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          DateFormat('EEEE, dd MMM yyyy').format(date),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isPresent ? Colors.green[800] : Colors.red[800],
          ),
        ),
        subtitle: isPresent
            ? Text(
                '${_formatTime(punchIn)} - ${_formatTime(punchOut)}',
                style: const TextStyle(fontSize: 12),
              )
            : const Text('Absent'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              totalHours,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isPresent ? Colors.green : Colors.red,
                fontSize: 16,
              ),
            ),
            Text(
              isPresent ? 'Present' : 'Absent',
              style: TextStyle(
                fontSize: 11,
                color: isPresent ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetails(Map<String, dynamic> record) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final isPresent = record['is_present'] as bool;
        final punches = record['punches'] as List<dynamic>;
        
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                DateFormat('EEEE, dd MMMM yyyy').format(record['date']),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              if (isPresent) ...[
                _buildDetailRow('Status', 'Present', Colors.green),
                _buildDetailRow('Punch In', _formatTime(record['punch_in']), Colors.black),
                _buildDetailRow('Punch Out', _formatTime(record['punch_out']), Colors.black),
                _buildDetailRow('Total Hours', record['total_hours'], Colors.blue),
                
                const SizedBox(height: 16),
                const Text(
                  'Punch Logs:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                
                ...punches.map((punch) => ListTile(
                  leading: Icon(
                    punch['log_type'] == 'IN' ? Icons.login : Icons.logout,
                    color: punch['log_type'] == 'IN' ? Colors.green : Colors.blue,
                  ),
                  title: Text(punch['log_type'] == 'IN' ? 'Checked IN' : 'Checked OUT'),
                  subtitle: Text(DateFormat('hh:mm a').format(punch['time'])),
                )).toList(),
              ] else ...[
                Center(
                  child: Column(
                    children: [
                      const Icon(Icons.cancel, size: 60, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'ABSENT',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('No punches recorded for this day'),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(dynamic time) {
    if (time == null) return '--:--';
    if (time is DateTime) {
      return DateFormat('hh:mm a').format(time);
    }
    return '--:--';
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}