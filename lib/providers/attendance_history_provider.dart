// providers/attendance_history_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class AttendanceHistoryProvider with ChangeNotifier {
  List<Map<String, dynamic>> _attendanceRecords = [];
  bool _isLoading = false;
  DateTime _selectedMonth = DateTime.now();
  
  List<Map<String, dynamic>> get attendanceRecords => _attendanceRecords;
  bool get isLoading => _isLoading;
  DateTime get selectedMonth => _selectedMonth;
  
  Future<String?> _getEmployeeId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('employee_id');
  }
  
  Future<List<String>?> _getCookies() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('cookies');
  }
  
  String _formatDateForAPI(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
  
  Future<void> loadAttendanceForMonth(DateTime month) async {
    try {
      setState(() => _isLoading = true);
      _selectedMonth = month;
      
      final employeeId = await _getEmployeeId();
      final cookies = await _getCookies();
      
      if (employeeId == null || cookies == null || cookies.isEmpty) {
        throw Exception('User not logged in');
      }
      
      final startDate = DateTime(month.year, month.month, 1);
      final endDate = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
      
      final filters = [
        ["employee", "=", employeeId],
        ["time", ">=", startDate.toIso8601String()],
        ["time", "<=", endDate.toIso8601String()],
      ];
      

      final response = await http.get(
        Uri.parse(
          "https://ppecon.erpnext.com/api/resource/Employee Checkin?fields=[\"name\",\"employee\",\"employee_name\",\"log_type\",\"time\",\"shift\"]&filters=${jsonEncode(filters)}&order_by=time%20asc",
        ),
        headers: {
          "Content-Type": "application/json",
          "Cookie": cookies.join("; "),
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _processAttendanceData(data['data'] ?? []);
      } else {
        throw Exception('Failed to load attendance: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error loading attendance: $e');
      rethrow;
    } finally {
      setState(() => _isLoading = false);
    }
  }
  

  void _processAttendanceData(List<dynamic> rawData) {
    final Map<String, List<dynamic>> groupedByDate = {};
    
    
    for (final item in rawData) {
      final dateTime = DateTime.parse(item['time']);
      final dateKey = DateFormat('yyyy-MM-dd').format(dateTime);
      
      if (!groupedByDate.containsKey(dateKey)) {
        groupedByDate[dateKey] = [];
      }
      groupedByDate[dateKey]!.add({
        'log_type': item['log_type'],
        'time': dateTime,
        'shift': item['shift'] ?? '',
      });
    }
    

    _attendanceRecords = groupedByDate.entries.map((entry) {
      final date = DateTime.parse(entry.key);
      final punches = entry.value;
      
     
      final inPunch = punches.firstWhere(
        (p) => p['log_type'] == 'IN',
        orElse: () => null,
      );
      
      final outPunch = punches.firstWhere(
        (p) => p['log_type'] == 'OUT',
        orElse: () => null,
      );
      
      // Calculate total hours
      String totalHours = '00:00';
      if (inPunch != null && outPunch != null) {
        final duration = outPunch['time'].difference(inPunch['time']);
        totalHours = '${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}';
      }
      
      return {
        'date': date,
        'date_key': entry.key,
        'is_present': inPunch != null,
        'punch_in': inPunch?['time'],
        'punch_out': outPunch?['time'],
        'total_hours': totalHours,
        'punches': punches,
        'shift': punches.isNotEmpty ? punches.first['shift'] : '',
      };
    }).toList()
      ..sort((a, b) => b['date'].compareTo(a['date'])); // Sort by date descending
    
    notifyListeners();
  }
  
  Map<String, dynamic>? getAttendanceForDate(DateTime date) {
  final dateKey = DateFormat('yyyy-MM-dd').format(date);
  
  try {
    return _attendanceRecords.firstWhere(
      (record) => record['date_key'] == dateKey,
    );
  } catch (e) {
    return null;
  }
}
  
  
  Map<String, dynamic> getMonthlyStatistics() {
    final presentDays = _attendanceRecords.where((record) => record['is_present']).length;
    final totalDays = _getDaysInMonth(_selectedMonth);
    final absentDays = totalDays - presentDays;
    
    
    double totalHours = 0;
    int presentCount = 0;
    
    for (final record in _attendanceRecords) {
      if (record['is_present']) {
        final hours = _parseHours(record['total_hours']);
        totalHours += hours;
        presentCount++;
      }
    }
    
    final avgHours = presentCount > 0 ? totalHours / presentCount : 0;
    
    return {
      'present': presentDays,
      'absent': absentDays,
      'total_days': totalDays,
      'avg_hours': '${avgHours.floor().toString().padLeft(2, '0')}:${((avgHours - avgHours.floor()) * 60).round().toString().padLeft(2, '0')}',
    };
  }
  
  
  double _parseHours(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.length != 2) return 0.0;
    
    final hours = int.tryParse(parts[0]) ?? 0;
    final minutes = int.tryParse(parts[1]) ?? 0;
    
    return hours + (minutes / 60);
  }
  
  int _getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }
  

  void changeMonth(DateTime newMonth) {
    _selectedMonth = newMonth;
    notifyListeners();
  }
  
  void setState(Function fn) {
    fn();
    notifyListeners();
  }
}