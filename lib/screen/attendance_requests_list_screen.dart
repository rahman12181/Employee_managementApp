// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:management_app/services/attendance_request_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'attendance_request_details_screen.dart';

class AttendanceRequestsListScreen extends StatefulWidget {
  const AttendanceRequestsListScreen({super.key});

  @override
  State<AttendanceRequestsListScreen> createState() => _AttendanceRequestsListScreenState();
}

class _AttendanceRequestsListScreenState extends State<AttendanceRequestsListScreen> {
  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _employeeName = '';
  bool _isRefreshing = false;
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadAttendanceRequests();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString("employeeName") ?? 'User';
      setState(() => _employeeName = name);
    } catch (e) {
      debugPrint("Error loading user data: $e");
    }
  }

  Future<void> _loadAttendanceRequests() async {
    if (mounted && !_isRefreshing) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
    }

    try {
      final requests = await AttendanceRequestService().getMyAttendanceRequests();
      if (mounted) {
        setState(() {
          _requests = requests;
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _refreshData() async {
    if (mounted) setState(() => _isRefreshing = true);
    await _loadAttendanceRequests();
  }

  String _formatDate(String dateString) {
    try {
      if (dateString.isEmpty || dateString == "N/A") return "N/A";
      DateTime? date = DateTime.tryParse(dateString.contains("T") ? dateString : "$dateString 00:00:00");
      return date != null ? DateFormat('dd MMM yyyy').format(date) : dateString;
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildRequestItem(Map<String, dynamic> request, int index) {
    return Container(
      margin: EdgeInsets.fromLTRB(16, index == 0 ? 16 : 8, 16, index == _requests.length - 1 ? 16 : 8),
      decoration: BoxDecoration(
        color: _isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_isDarkMode ? 0.3 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AttendanceRequestDetailsScreen(
                  requestId: request["id"],
                  requestData: request,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: request["color"].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.calendar_today,
                        color: request["color"],
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  request["title"] ?? "Attendance Request",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: _isDarkMode ? Colors.white : Colors.grey[900],
                                    height: 1.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: request["color"].withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: request["color"], width: 1),
                                ),
                                child: Text(
                                  request["status"],
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: request["color"],
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _formatDate(request["date"]),
                            style: TextStyle(
                              fontSize: 13,
                              color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if ((request["reason"] ?? "").isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Reason",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        request["reason"] ?? "",
                        style: TextStyle(
                          fontSize: 14,
                          color: _isDarkMode ? Colors.grey[300] : Colors.grey[700],
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Request ID: ${request["id"]}",
                        style: TextStyle(
                          fontSize: 11,
                          color: _isDarkMode ? Colors.grey[500] : Colors.grey[600],
                          fontFamily: 'RobotoMono',
                          letterSpacing: 0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _isDarkMode ? Colors.grey[700] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Text(
                            "View Details",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _isDarkMode ? Colors.blue[300] : Colors.blue[600],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 10,
                            color: _isDarkMode ? Colors.blue[300] : Colors.blue[600],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: _isDarkMode ? Colors.grey[800] : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_today,
                size: 48,
                color: _isDarkMode ? Colors.grey[600] : Colors.grey[400],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              "No Attendance Requests",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: _isDarkMode ? Colors.white : Colors.grey[900],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "You haven't submitted any attendance requests yet. Create your first request to get started.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.add, size: 20),
              label: const Text("Create New Request", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isDarkMode ? Colors.blue[600]! : Colors.blue[600]!,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Unable to Load Requests",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isDarkMode ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _errorMessage.length > 150 ? "${_errorMessage.substring(0, 150)}..." : _errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: _isDarkMode ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _refreshData,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text("Try Again"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, size: 18),
                  label: const Text("Go Back"),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: _isDarkMode ? Colors.grey[600]! : Colors.grey[400]!),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      decoration: BoxDecoration(
        color: _isDarkMode ? Colors.grey[900] : Colors.white,
        border: Border(
          bottom: BorderSide(color: _isDarkMode ? Colors.grey[800]! : Colors.grey[200]!, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isDarkMode 
                        ? [Colors.blue[800]!, Colors.blue[600]!]
                        : [Colors.blue[600]!, Colors.blue[400]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.list_alt, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "My Attendance Requests",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: _isDarkMode ? Colors.white : Colors.grey[900],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Track and manage all your attendance requests",
                      style: TextStyle(
                        fontSize: 13,
                        color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _isDarkMode ? Colors.grey[800] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 14,
                      color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _employeeName,
                      style: TextStyle(
                        fontSize: 13,
                        color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _isDarkMode ? Colors.grey[800] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.format_list_numbered,
                      size: 14,
                      color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "${_requests.length} Requests",
                      style: TextStyle(
                        fontSize: 13,
                        color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: _isDarkMode ? Colors.grey[900] : Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: _isDarkMode ? Colors.grey[900] : Colors.white,
                border: Border(
                  bottom: BorderSide(color: _isDarkMode ? Colors.grey[800]! : Colors.grey[200]!, width: 1),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: _isDarkMode ? Colors.white : Colors.grey[900]),
                      onPressed: () => Navigator.pop(context),
                      splashRadius: 24,
                    ),
                    Text(
                      "Attendance History",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: _isDarkMode ? Colors.white : Colors.grey[900],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _isRefreshing ? Icons.refresh : Icons.refresh,
                        color: _isDarkMode ? Colors.white : Colors.grey[900],
                      ),
                      onPressed: _isRefreshing ? null : _refreshData,
                      splashRadius: 24,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: _isDarkMode ? Colors.blue[400] : Colors.blue[600],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Loading your requests...",
                            style: TextStyle(
                              fontSize: 16,
                              color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : _errorMessage.isNotEmpty
                      ? _buildErrorState()
                      : _requests.isEmpty
                          ? _buildEmptyState()
                          : RefreshIndicator(
                              onRefresh: _refreshData,
                              color: _isDarkMode ? Colors.blue[400]! : Colors.blue[600]!,
                              backgroundColor: _isDarkMode ? Colors.grey[900] : Colors.white,
                              displacement: 40,
                              child: CustomScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                slivers: [
                                  SliverToBoxAdapter(child: _buildHeader()),
                                  SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) => _buildRequestItem(_requests[index], index),
                                      childCount: _requests.length,
                                    ),
                                  ),
                                  const SliverToBoxAdapter(child: SizedBox(height: 30)),
                                ],
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}