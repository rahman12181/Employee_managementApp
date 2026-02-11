// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:management_app/card_screen/leaverequest.dart';
import 'package:management_app/model/leave_approved_model.dart';
import 'package:management_app/services/leave_approved_service.dart';
import 'package:management_app/services/travel_request_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'leave_detail_screen.dart';
import 'travel_request_screen.dart';

class LeaveApprovalScreen extends StatefulWidget {
  const LeaveApprovalScreen({super.key});

  @override
  State<LeaveApprovalScreen> createState() => _LeaveApprovalScreenState();
}

class _LeaveApprovalScreenState extends State<LeaveApprovalScreen> {
  bool _isFabOpen = false;
  double _fabScale = 0.0;
  double _optionsOpacity = 0.0;
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _allRequests = [];
  List<Map<String, dynamic>> _filteredRequests = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = "";
  String _employeeId = "";
  String _employeeName = "";
  String _selectedFilter = "All";

  Timer? _refreshTimer;
  bool _isRefreshing = false;

  int _totalCount = 0;
  int _leaveCount = 0;
  int _travelCount = 0;
  int _pendingCount = 0;

  @override
  void initState() {
    super.initState();
    _loadEmployeeData().then((_) {
      if (_employeeId.isNotEmpty) {
        _fetchAllRequests(showLoading: true);
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = "Employee ID not found. Please login again.";
        });
      }
    });

    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted && !_isRefreshing && _employeeId.isNotEmpty) {
        _fetchAllRequests(showLoading: false);
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEmployeeData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final empId = prefs.getString("employeeId") ?? "";
      final empName = prefs.getString("employeeName") ?? "";

      setState(() {
        _employeeId = empId;
        _employeeName = empName;
      });
    } catch (e) {
      print("Error loading employee data: $e");
    }
  }

  Future<void> _fetchAllRequests({bool showLoading = true}) async {
    if (!mounted) return;

    if (showLoading) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    } else {
      setState(() {
        _isRefreshing = true;
      });
    }

    try {
      List<Map<String, dynamic>> allRequests = [];

      try {
        final leaves = await LeaveApprovedService.fetchLeaves();
        final userLeaves = leaves.where((leave) {
          return leave.employeeName.toLowerCase().contains(
                _employeeName.toLowerCase(),
              ) ||
              _employeeName.toLowerCase().contains(
                leave.employeeName.toLowerCase(),
              );
        }).toList();

        final leaveMaps = userLeaves.map((leave) {
          return {
            "type": "leave",
            "data": leave,
            "id":
                "${leave.employeeName}_${leave.fromDate}_${DateTime.now().millisecondsSinceEpoch}",
            "title": leave.leaveType,
            "subtitle": leave.employeeName,
            "employee": leave.employeeName,
            "from_date": leave.fromDate,
            "to_date": leave.toDate,
            "date": leave.fromDate,
            "status": leave.status,
            "status_color": _getStatusColor(leave.status),
            "status_bg_color": _getStatusBgColor(leave.status),
            "icon": Icons.beach_access,
            "icon_color": Colors.blue,
            "created_date": leave.fromDate,
            "is_logged": true,
            "last_updated": DateTime.now().toIso8601String(),
          };
        }).toList();

        allRequests.addAll(leaveMaps);
      } catch (e) {
        print("Error fetching leaves: $e");
      }

      try {
        final travels = await TravelRequestService.getMyTravelRequests(
          _employeeId,
        );
        final userTravels = travels.where((travel) {
          final travelEmpId = travel["employee"]?.toString() ?? "";
          final travelEmpName = travel["employee_name"]?.toString() ?? "";
          return travelEmpId == _employeeId ||
              travelEmpName.toLowerCase().contains(
                _employeeName.toLowerCase(),
              ) ||
              _employeeName.toLowerCase().contains(travelEmpName.toLowerCase());
        }).toList();

        final formattedTravels = userTravels.map((travel) {
          return {
            ...travel,
            "is_logged": true,
            "last_updated": DateTime.now().toIso8601String(),
            "status_color": _getStatusColor(travel["status"] ?? "Pending"),
            "status_bg_color": _getStatusBgColor(travel["status"] ?? "Pending"),
            "icon_color": Colors.orange,
          };
        }).toList();

        allRequests.addAll(formattedTravels);
      } catch (e) {
        print("Error fetching travels: $e");
      }

      _calculateStatistics(allRequests);

      allRequests.sort((a, b) {
        final dateA = a["created_date"] ?? "";
        final dateB = b["created_date"] ?? "";
        return dateB.compareTo(dateA);
      });

      if (mounted) {
        setState(() {
          _allRequests = allRequests;
          _filterRequests();
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _isRefreshing = false;
          _errorMessage = "Failed to load requests: ${e.toString()}";
        });
      }
    }
  }

  void _calculateStatistics(List<Map<String, dynamic>> requests) {
    int total = requests.length;
    int leaves = 0;
    int travels = 0;
    int pending = 0;

    for (var request in requests) {
      final type = request["type"];
      final status = (request["status"] ?? "").toString().toLowerCase();

      if (type == "leave") leaves++;
      if (type == "travel") travels++;

      if (status.contains("pending") ||
          status.contains("draft") ||
          status.contains("submitted")) {
        pending++;
      }
    }

    setState(() {
      _totalCount = total;
      _leaveCount = leaves;
      _travelCount = travels;
      _pendingCount = pending;
    });
  }

  void _filterRequests() {
    List<Map<String, dynamic>> filtered = List.from(_allRequests);

    if (_selectedFilter != "All") {
      filtered = filtered
          .where((req) => req["type"] == _selectedFilter.toLowerCase())
          .toList();
    }

    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((req) {
        final title = req["title"].toString().toLowerCase();
        final subtitle = req["subtitle"].toString().toLowerCase();
        final status = req["status"].toString().toLowerCase();
        final employee = req["employee"].toString().toLowerCase();
        final purpose =
            req["purpose_of_travel"]?.toString().toLowerCase() ?? "";
        final travelType = req["travel_type"]?.toString().toLowerCase() ?? "";

        return title.contains(query) ||
            subtitle.contains(query) ||
            status.contains(query) ||
            employee.contains(query) ||
            purpose.contains(query) ||
            travelType.contains(query);
      }).toList();
    }

    setState(() {
      _filteredRequests = filtered;
    });
  }

  void _onFilterChanged(String value) {
    setState(() {
      _selectedFilter = value;
      _filterRequests();
    });
  }

  void _onSearchChanged(String query) {
    _filterRequests();
  }

  void _clearSearch() {
    _searchController.clear();
    _filterRequests();
  }

  void _toggleFabMenu() {
    setState(() {
      _isFabOpen = !_isFabOpen;
      if (_isFabOpen) {
        _fabScale = 1.0;
        _optionsOpacity = 1.0;
      } else {
        _optionsOpacity = 0.0;
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            setState(() {
              _fabScale = 0.0;
            });
          }
        });
      }
    });
  }

  void _navigateToLeaveRequest() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LeaveRequest()),
    ).then((value) {
      _fetchAllRequests();
      _toggleFabMenu();
    });
  }

  void _navigateToTravelRequest() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TravelRequestScreen()),
    ).then((value) {
      _fetchAllRequests();
      _toggleFabMenu();
    });
  }

  Future<void> _refreshData() async {
    await _fetchAllRequests(showLoading: false);
  }

  Color _getStatusColor(String status) {
    final statusLower = status.toLowerCase();

    if (statusLower.contains("approved")) return Colors.green;
    if (statusLower.contains("rejected")) return Colors.red;
    if (statusLower.contains("cancelled")) return Colors.grey;
    if (statusLower.contains("pending") ||
        statusLower.contains("draft") ||
        statusLower.contains("submitted")) {
      return Colors.orange;
    }

    return Colors.blue;
  }

  Color _getStatusBgColor(String status) {
    final statusLower = status.toLowerCase();

    if (statusLower.contains("approved")) return Colors.green.withOpacity(0.1);
    if (statusLower.contains("rejected")) return Colors.red.withOpacity(0.1);
    if (statusLower.contains("cancelled")) return Colors.grey.withOpacity(0.1);
    if (statusLower.contains("pending") ||
        statusLower.contains("draft") ||
        statusLower.contains("submitted")) {
      return Colors.orange.withOpacity(0.1);
    }

    return Colors.blue.withOpacity(0.1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "My Requests",
              style: TextStyle(fontSize: screenWidth * 0.045),
            ),
            if (_employeeName.isNotEmpty)
              Text(
                _employeeName,
                style: TextStyle(
                  fontSize: screenWidth * 0.03,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
          ],
        ),
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: screenWidth * 0.06),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: isDark ? theme.cardColor : theme.primaryColor,
        foregroundColor: isDark ? Colors.white : Colors.white,
        elevation: 0,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(
                  _isRefreshing ? Icons.refresh : Icons.refresh,
                  size: screenWidth * 0.06,
                ),
                onPressed: _isRefreshing ? null : _refreshData,
                tooltip: "Refresh",
              ),
              if (_isRefreshing)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),

      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: "Search requests...",
                          hintStyle: TextStyle(fontSize: screenWidth * 0.035),
                          prefixIcon: Icon(
                            Icons.search,
                            size: screenWidth * 0.05,
                          ),
                          filled: true,
                          fillColor: isDark
                              ? theme.cardColor
                              : Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04,
                            vertical: screenHeight * 0.02,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    size: screenWidth * 0.05,
                                  ),
                                  onPressed: _clearSearch,
                                )
                              : null,
                        ),
                        style: TextStyle(fontSize: screenWidth * 0.04),
                      ),

                      SizedBox(height: screenHeight * 0.02),

                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Text(
                              "Filter: ",
                              style: TextStyle(
                                fontSize: screenWidth * 0.035,
                                color: theme.hintColor,
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.02),
                            Wrap(
                              spacing: screenWidth * 0.02,
                              children: ["All", "Leave", "Travel"].map((
                                filter,
                              ) {
                                final isSelected = _selectedFilter == filter;
                                return ChoiceChip(
                                  label: Text(
                                    filter,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.035,
                                      color: isSelected
                                          ? Colors.white
                                          : theme.hintColor,
                                    ),
                                  ),
                                  selected: isSelected,
                                  backgroundColor: isDark
                                      ? Colors.grey[800]
                                      : Colors.grey[200],
                                  selectedColor: theme.primaryColor,
                                  onSelected: (_) => _onFilterChanged(filter),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                if (!_isLoading && !_hasError && _allRequests.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenHeight * 0.01,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          title: "Total",
                          count: _totalCount.toString(),
                          color: Colors.blue,
                          icon: Icons.list_alt,
                          screenWidth: screenWidth,
                        ),
                        _buildStatItem(
                          title: "Leaves",
                          count: _leaveCount.toString(),
                          color: Colors.green,
                          icon: Icons.beach_access,
                          screenWidth: screenWidth,
                        ),
                        _buildStatItem(
                          title: "Travel",
                          count: _travelCount.toString(),
                          color: Colors.orange,
                          icon: Icons.flight_takeoff,
                          screenWidth: screenWidth,
                        ),
                        _buildStatItem(
                          title: "Pending",
                          count: _pendingCount.toString(),
                          color: Colors.orange,
                          icon: Icons.pending,
                          screenWidth: screenWidth,
                        ),
                      ],
                    ),
                  ),

                if (_isRefreshing)
                  LinearProgressIndicator(
                    minHeight: 2,
                    backgroundColor: theme.primaryColor.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.primaryColor,
                    ),
                  ),

                if (_employeeId.isEmpty && !_isLoading)
                  Padding(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    child: Container(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning, color: Colors.orange),
                          SizedBox(width: screenWidth * 0.03),
                          const Expanded(
                            child: Text(
                              "Employee ID not found. Showing all requests.",
                              style: TextStyle(color: Colors.orange),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                Expanded(
                  child: _buildRequestsList(
                    theme,
                    isDark,
                    screenWidth,
                    screenHeight,
                  ),
                ),
              ],
            ),

            if (_isFabOpen)
              GestureDetector(
                onTap: _toggleFabMenu,
                child: Container(
                  color: Colors.black54,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),

            Positioned(
              bottom: screenHeight * 0.15,
              right: screenWidth * 0.05,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _optionsOpacity,
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 300),
                  scale: _fabScale,
                  child: Column(
                    children: [
                      _buildFabOptionItem(
                        icon: Icons.flight_takeoff_outlined,
                        label: "Travel Request",
                        color: Colors.blue,
                        onTap: _navigateToTravelRequest,
                        theme: theme,
                        screenWidth: screenWidth,
                      ),
                      SizedBox(height: screenHeight * 0.02),

                      _buildFabOptionItem(
                        icon: Icons.beach_access_outlined,
                        label: "Create Leave",
                        color: Colors.green,
                        onTap: _navigateToLeaveRequest,
                        theme: theme,
                        screenWidth: screenWidth,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: screenHeight * 0.03,
              right: screenWidth * 0.05,
              child: GestureDetector(
                onTap: _toggleFabMenu,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: screenWidth * 0.14,
                  height: screenWidth * 0.14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.primaryColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.4 : 0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: AnimatedRotation(
                    duration: const Duration(milliseconds: 300),
                    turns: _isFabOpen ? 0.125 : 0,
                    child: Icon(
                      _isFabOpen ? Icons.close : Icons.add,
                      color: Colors.white,
                      size: screenWidth * 0.06,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String title,
    required String count,
    required Color color,
    required IconData icon,
    required double screenWidth,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(screenWidth * 0.02),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: screenWidth * 0.05),
        ),
        SizedBox(height: screenWidth * 0.01),
        Text(
          count,
          style: TextStyle(
            fontSize: screenWidth * 0.045,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: TextStyle(fontSize: screenWidth * 0.03, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildRequestsList(
    ThemeData theme,
    bool isDark,
    double screenWidth,
    double screenHeight,
  ) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: theme.primaryColor),
            SizedBox(height: screenHeight * 0.02),
            Text(
              "Loading your requests...",
              style: TextStyle(
                color: theme.hintColor,
                fontSize: screenWidth * 0.04,
              ),
            ),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: screenWidth * 0.15,
              color: Colors.red,
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              "Failed to load requests",
              style: TextStyle(
                color: Colors.red,
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
              child: Text(
                _errorMessage,
                style: TextStyle(
                  color: theme.hintColor,
                  fontSize: screenWidth * 0.035,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            ElevatedButton(
              onPressed: _refreshData,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                "Try Again",
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_filteredRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _selectedFilter == "Travel"
                  ? Icons.flight_takeoff
                  : _selectedFilter == "Leave"
                  ? Icons.beach_access
                  : Icons.inbox_outlined,
              size: screenWidth * 0.2,
              color: theme.hintColor,
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              _selectedFilter == "All"
                  ? "No requests found"
                  : "No $_selectedFilter requests",
              style: TextStyle(
                color: theme.hintColor,
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            if (_searchController.text.isNotEmpty || _selectedFilter != "All")
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  _onFilterChanged("All");
                },
                child: Text(
                  "Clear filters",
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontSize: screenWidth * 0.04,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await _fetchAllRequests(showLoading: false);
      },
      color: theme.primaryColor,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(
          bottom: screenHeight * 0.15,
          top: screenHeight * 0.01,
        ),
        itemCount: _filteredRequests.length,
        itemBuilder: (context, index) {
          final request = _filteredRequests[index];
          return _buildRequestCard(request, theme, screenWidth, screenHeight);
        },
      ),
    );
  }

  Widget _buildRequestCard(
    Map<String, dynamic> request,
    ThemeData theme,
    double screenWidth,
    double screenHeight,
  ) {
    final type = request["type"];
    final data = request["data"];
    final title = request["title"];
    final status = request["status"];
    final statusColor = request["status_color"];
    final statusBgColor = request["status_bg_color"];
    final icon = request["icon"];
    final iconColor = request["icon_color"];
    final isLogged = request["is_logged"] ?? false;
    final employeeName = request["employee_name"] ?? request["employee"] ?? "";

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenWidth * 0.015,
      ),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: theme.cardColor,
        child: InkWell(
          onTap: () {
            if (type == "leave") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      LeaveDetailScreen(leave: data as LeaveApprovedModel),
                ),
              );
            } else if (type == "travel") {
              _showTravelDetailsDialog(data, theme, screenWidth);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: screenWidth * 0.1,
                            height: screenWidth * 0.1,
                            decoration: BoxDecoration(
                              color: iconColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              icon,
                              size: screenWidth * 0.05,
                              color: iconColor,
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.03),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  type == "leave"
                                      ? "LEAVE REQUEST"
                                      : "TRAVEL REQUEST",
                                  style: TextStyle(
                                    color: theme.hintColor,
                                    fontSize: screenWidth * 0.028,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(height: screenWidth * 0.005),
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: screenWidth * 0.04,
                                    color: theme.textTheme.bodyLarge?.color,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                if (employeeName.isNotEmpty)
                                  Text(
                                    "Employee: $employeeName",
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.032,
                                      color: theme.hintColor,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.03,
                            vertical: screenWidth * 0.015,
                          ),
                          decoration: BoxDecoration(
                            color: statusBgColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: statusColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                              fontSize: screenWidth * 0.028,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        SizedBox(height: screenWidth * 0.01),
                        Row(
                          children: [
                            Icon(
                              isLogged ? Icons.cloud_done : Icons.cloud_off,
                              size: screenWidth * 0.03,
                              color: isLogged ? Colors.green : Colors.grey,
                            ),
                            SizedBox(width: screenWidth * 0.01),
                            Text(
                              isLogged ? "Logged" : "Not Logged",
                              style: TextStyle(
                                fontSize: screenWidth * 0.025,
                                color: isLogged ? Colors.green : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: screenWidth * 0.04),

                Divider(height: 1, color: theme.dividerColor.withOpacity(0.3)),

                SizedBox(height: screenWidth * 0.04),

                if (type == "leave")
                  _buildLeaveDetails(
                    data as LeaveApprovedModel,
                    theme,
                    screenWidth,
                  )
                else
                  _buildTravelDetails(request, theme, screenWidth),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTravelDetailsDialog(
    Map<String, dynamic> travelData,
    ThemeData theme,
    double screenWidth,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Travel Request Details"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(
                "Employee:",
                travelData["employee_name"] ?? travelData["employee"] ?? "N/A",
              ),
              _buildDetailRow(
                "Purpose:",
                travelData["purpose_of_travel"] ?? "N/A",
              ),
              _buildDetailRow("Type:", travelData["travel_type"] ?? "N/A"),
              _buildDetailRow(
                "Funding:",
                travelData["travel_funding"] ?? "N/A",
              ),
              _buildDetailRow(
                "Status:",
                travelData["status"] ?? travelData["workflow_state"] ?? "N/A",
              ),
              _buildDetailRow(
                "Created:",
                travelData["creation"] ?? travelData["posting_date"] ?? "N/A",
              ),
              _buildDetailRow("Document No:", travelData["name"] ?? "N/A"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey[700])),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveDetails(
    LeaveApprovedModel leave,
    ThemeData theme,
    double screenWidth,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "EMPLOYEE",
                    style: TextStyle(
                      color: theme.hintColor,
                      fontSize: screenWidth * 0.025,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.01),
                  Text(
                    leave.employeeName,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: screenWidth * 0.035,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: screenWidth * 0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "FROM DATE",
                    style: TextStyle(
                      color: theme.hintColor,
                      fontSize: screenWidth * 0.025,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.01),
                  Text(
                    leave.fromDate,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: screenWidth * 0.035,
                      color: theme.textTheme.bodyLarge?.color,
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
                  Text(
                    "TO DATE",
                    style: TextStyle(
                      color: theme.hintColor,
                      fontSize: screenWidth * 0.025,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.01),
                  Text(
                    leave.toDate,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: screenWidth * 0.035,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: screenWidth * 0.03),
        if (leave.reason.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "REASON",
                style: TextStyle(
                  color: theme.hintColor,
                  fontSize: screenWidth * 0.025,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: screenWidth * 0.01),
              Text(
                leave.reason,
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  color: theme.textTheme.bodyLarge?.color,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildTravelDetails(
    Map<String, dynamic> travel,
    ThemeData theme,
    double screenWidth,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "PURPOSE",
                    style: TextStyle(
                      color: theme.hintColor,
                      fontSize: screenWidth * 0.025,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.01),
                  Text(
                    travel["purpose_of_travel"] ?? "N/A",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: screenWidth * 0.035,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            SizedBox(width: screenWidth * 0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "TYPE",
                    style: TextStyle(
                      color: theme.hintColor,
                      fontSize: screenWidth * 0.025,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.01),
                  Text(
                    travel["travel_type"] ?? "N/A",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: screenWidth * 0.035,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: screenWidth * 0.03),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "FUNDING",
                    style: TextStyle(
                      color: theme.hintColor,
                      fontSize: screenWidth * 0.025,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.01),
                  Text(
                    travel["travel_funding"] ?? "N/A",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: screenWidth * 0.035,
                      color: theme.textTheme.bodyLarge?.color,
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
                  Text(
                    "REQUESTED ON",
                    style: TextStyle(
                      color: theme.hintColor,
                      fontSize: screenWidth * 0.025,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.01),
                  Text(
                    travel["posting_date"]?.toString().split(" ")[0] ?? "N/A",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: screenWidth * 0.035,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFabOptionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required ThemeData theme,
    required double screenWidth,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenWidth * 0.03,
        ),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: screenWidth * 0.09,
              height: screenWidth * 0.09,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: screenWidth * 0.05),
            ),
            SizedBox(width: screenWidth * 0.03),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: screenWidth * 0.038,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            SizedBox(width: screenWidth * 0.02),
          ],
        ),
      ),
    );
  }
}
