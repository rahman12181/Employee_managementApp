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
  
  // Get attendance for specific date
  Map<String, dynamic>? getAttendanceForDate(DateTime date) {
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    
    for (final record in _attendanceRecords) {
      if (record['date_key'] == dateKey) {
        return record;
      }
    }
    return null;
  }
  
  // Get employee ID
  Future<String?> _getEmployeeId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('employee_id');
  }
  
  // Get cookies
  Future<List<String>?> _getCookies() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('cookies');
  }
  
  // Load attendance for month
  Future<void> loadAttendanceForMonth(DateTime month) async {
    try {
      setState(() => _isLoading = true);
      _selectedMonth = month;
      
      final employeeId = await _getEmployeeId();
      final cookies = await _getCookies();
      
      if (employeeId == null) {
        throw Exception('Employee ID not found. Please login again.');
      }
      
      if (cookies == null || cookies.isEmpty) {
        throw Exception('Session expired. Please login again.');
      }
      
      // Calculate dates
      final startDate = DateTime(month.year, month.month, 1);
      final endDate = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
      
      // Build filters
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
        throw Exception('Failed to load attendance');
      }
    } catch (e) {
      debugPrint('Error loading attendance: $e');
      rethrow;
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  // Process data
  void _processAttendanceData(List<dynamic> rawData) {
    final Map<String, List<dynamic>> groupedByDate = {};
    
    // Group by date
    for (final item in rawData) {
      try {
        final dateTime = DateTime.parse(item['time'].toString());
        final dateKey = DateFormat('yyyy-MM-dd').format(dateTime);
        
        if (!groupedByDate.containsKey(dateKey)) {
          groupedByDate[dateKey] = [];
        }
        
        groupedByDate[dateKey]!.add({
          'log_type': item['log_type'] ?? '',
          'time': dateTime,
          'shift': item['shift'] ?? '',
        });
      } catch (e) {
        debugPrint('Error parsing item: $e');
      }
    }
    
    // Create records
    _attendanceRecords = [];
    
    for (final entry in groupedByDate.entries) {
      try {
        final date = DateTime.parse(entry.key);
        final punches = entry.value;
        
        // Find IN and OUT
        Map<String, dynamic>? inPunch;
        Map<String, dynamic>? outPunch;
        
        for (final punch in punches) {
          if (punch['log_type'] == 'IN') {
            inPunch = punch;
          } else if (punch['log_type'] == 'OUT') {
            outPunch = punch;
          }
        }
        
        // Calculate hours
        String totalHours = '00:00';
        if (inPunch != null && outPunch != null) {
          final duration = outPunch['time'].difference(inPunch['time']);
          final hours = duration.inHours;
          final minutes = duration.inMinutes % 60;
          totalHours = '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
        }
        
        _attendanceRecords.add({
          'date': date,
          'date_key': entry.key,
          'is_present': inPunch != null,
          'punch_in': inPunch?['time'],
          'punch_out': outPunch?['time'],
          'total_hours': totalHours,
          'punches': punches,
        });
      } catch (e) {
        debugPrint('Error creating record: $e');
      }
    }
    
    // Sort by date
    _attendanceRecords.sort((a, b) => b['date'].compareTo(a['date']));
    
    notifyListeners();
  }
  
  // Get statistics
  Map<String, dynamic> getMonthlyStatistics() {
    final presentDays = _attendanceRecords.where((r) => r['is_present'] == true).length;
    final totalDays = _getDaysInMonth(_selectedMonth);
    final absentDays = totalDays > presentDays ? totalDays - presentDays : 0;
    
    // Calculate average hours
    double totalHours = 0;
    int count = 0;
    
    for (final record in _attendanceRecords) {
      if (record['is_present'] == true) {
        final hours = _parseHours(record['total_hours']);
        totalHours += hours;
        count++;
      }
    }
    
    final avg = count > 0 ? totalHours / count : 0;
    final avgStr = '${avg.floor().toString().padLeft(2, '0')}:${((avg - avg.floor()) * 60).round().toString().padLeft(2, '0')}';
    
    return {
      'present': presentDays,
      'absent': absentDays,
      'total_days': totalDays,
      'avg_hours': avgStr,
    };
  }
  
  // Helper methods
  double _parseHours(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length != 2) return 0.0;
      final hours = int.tryParse(parts[0]) ?? 0;
      final minutes = int.tryParse(parts[1]) ?? 0;
      return hours + (minutes / 60);
    } catch (e) {
      return 0.0;
    }
  }
  
  int _getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }
  
  void setState(Function fn) {
    fn();
    notifyListeners();
  }
}