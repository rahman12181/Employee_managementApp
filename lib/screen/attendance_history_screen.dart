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
  late DateTime _currentMonth;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      final provider = Provider.of<AttendanceHistoryProvider>(context, listen: false);
      await provider.loadAttendanceForMonth(_currentMonth);
      
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
    _loadData();
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance History'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorView()
              : Consumer<AttendanceHistoryProvider>(
                  builder: (context, provider, child) {
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          // Statistics Card
                          _buildStatisticsCard(provider),
                          
                          // Calendar
                          _buildCalendarCard(provider),
                          
                          // Attendance List
                          provider.attendanceRecords.isEmpty
                              ? _buildEmptyView()
                              : _buildAttendanceList(provider),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 64),
          const SizedBox(height: 16),
          const Text(
            'Error Loading Data',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard(AttendanceHistoryProvider provider) {
    final stats = provider.getMonthlyStatistics();
    
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
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
                  tooltip: 'Previous Month',
                ),
                Text(
                  DateFormat('MMMM yyyy').format(_currentMonth),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: _nextMonth,
                  tooltip: 'Next Month',
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Statistics Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Present
                Column(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.green, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          stats['present'].toString(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Present',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                
                // Absent
                Column(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.red, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          stats['absent'].toString(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Absent',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                
                // Average Hours
                Column(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blue, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          stats['avg_hours'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Avg Hours',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarCard(AttendanceHistoryProvider provider) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Weekday Headers
            const Row(
              children: [
                Expanded(child: Center(child: Text('Sun', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)))),
                Expanded(child: Center(child: Text('Mon', style: TextStyle(fontWeight: FontWeight.bold)))),
                Expanded(child: Center(child: Text('Tue', style: TextStyle(fontWeight: FontWeight.bold)))),
                Expanded(child: Center(child: Text('Wed', style: TextStyle(fontWeight: FontWeight.bold)))),
                Expanded(child: Center(child: Text('Thu', style: TextStyle(fontWeight: FontWeight.bold)))),
                Expanded(child: Center(child: Text('Fri', style: TextStyle(fontWeight: FontWeight.bold)))),
                Expanded(child: Center(child: Text('Sat', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)))),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Calendar Grid
            _buildCalendarGrid(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(AttendanceHistoryProvider provider) {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final startWeekday = firstDay.weekday; // 1=Monday, 7=Sunday
    
    // Calculate days before
    final daysBefore = startWeekday % 7; // Sunday=0, Monday=1
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.0,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: 42, // 6 weeks
      itemBuilder: (context, index) {
        final dayOffset = index - daysBefore + 1;
        
        if (dayOffset < 1) {
          // Previous month
          final prevMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
          final prevMonthDays = DateTime(prevMonth.year, prevMonth.month + 1, 0).day;
          final dayNumber = prevMonthDays + dayOffset;
          return _buildOtherMonthDay(dayNumber);
        } else if (dayOffset > lastDay.day) {
          // Next month
          final dayNumber = dayOffset - lastDay.day;
          return _buildOtherMonthDay(dayNumber);
        } else {
          // Current month
          final currentDate = DateTime(_currentMonth.year, _currentMonth.month, dayOffset);
          return _buildCurrentMonthDay(currentDate, provider);
        }
      },
    );
  }

  Widget _buildOtherMonthDay(int dayNumber) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          dayNumber.toString(),
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentMonthDay(DateTime date, AttendanceHistoryProvider provider) {
    final isToday = _isSameDate(date, DateTime.now());
    final attendance = provider.getAttendanceForDate(date);
    final isPresent = attendance != null && attendance['is_present'] == true;
    final isPast = date.isBefore(DateTime.now());
    
    Color bgColor = Colors.transparent;
    Color textColor = Colors.black;
    String? hoursText;
    
    if (isToday) {
      bgColor = Colors.blue.withOpacity(0.2);
      textColor = Colors.blue;
    } else if (isPresent) {
      bgColor = Colors.green;
      textColor = Colors.white;
      hoursText = attendance?['total_hours'];
    } else if (isPast && attendance == null) {
      // Past date with no attendance = Absent
      bgColor = Colors.red;
      textColor = Colors.white;
    }
    
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: isToday ? Border.all(color: Colors.blue, width: 2) : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            date.day.toString(),
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          if (hoursText != null && hoursText != '00:00')
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Text(
                hoursText!,
                style: TextStyle(
                  fontSize: 9,
                  color: textColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          Icon(
            Icons.calendar_month,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          const Text(
            'No Attendance Records',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your attendance records for this month\nwill appear here',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceList(AttendanceHistoryProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            'Daily Records',
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
        
        const SizedBox(height: 20),
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
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      elevation: 2,
      color: isPresent ? Colors.green[50] : Colors.red[50],
      child: ListTile(
        onTap: () => _showDetails(record),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isPresent ? Colors.green : Colors.red,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              date.day.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
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
                style: const TextStyle(fontSize: 13),
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
      isScrollControlled: true,
      builder: (context) {
        final isPresent = record['is_present'] as bool;
        final punches = record['punches'] as List<dynamic>;
        
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Text(
                    DateFormat('EEEE, dd MMMM yyyy').format(record['date']),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                if (isPresent) ...[
                  _buildDetailItem('Status', 'Present', Icons.check_circle, Colors.green),
                  _buildDetailItem('Punch In', _formatTime(record['punch_in']), Icons.login, Colors.blue),
                  _buildDetailItem('Punch Out', _formatTime(record['punch_out']), Icons.logout, Colors.blue),
                  _buildDetailItem('Total Hours', record['total_hours'], Icons.access_time, Colors.orange),
                  
                  const SizedBox(height: 20),
                  const Text(
                    'Punch Logs:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  
                  ...punches.map((punch) => Card(
                    margin: const EdgeInsets.only(top: 8),
                    child: ListTile(
                      leading: Icon(
                        punch['log_type'] == 'IN' ? Icons.login : Icons.logout,
                        color: punch['log_type'] == 'IN' ? Colors.green : Colors.blue,
                      ),
                      title: Text(punch['log_type'] == 'IN' ? 'Punch IN' : 'Punch OUT'),
                      subtitle: Text(DateFormat('hh:mm a').format(punch['time'])),
                    ),
                  )).toList(),
                ] else ...[
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.cancel, size: 80, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Text(
                          'ABSENT',
                          style: TextStyle(
                            fontSize: 28,
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
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(label, style: const TextStyle(color: Colors.grey)),
        trailing: Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 16,
          ),
        ),
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