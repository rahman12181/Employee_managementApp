// ignore_for_file: deprecated_member_use, empty_catches

import 'package:flutter/material.dart';
import 'package:management_app/providers/profile_provider.dart';
import 'package:management_app/services/auth_service.dart';
import 'package:management_app/services/leave_balance_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:management_app/services/leave_approved_service.dart';
import 'package:management_app/services/travel_request_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final bool _isLoading = false;
  int currentIndex = 0;
  late AnimationController _bannerController;
  late AnimationController _greetingController;
  late AnimationController _statsAnimationController;

  // For button press feedback
  int _pressedModuleIndex = -1;

  String _greetingMessage = "";
  IconData _greetingIcon = Icons.wb_sunny;

  Map<String, dynamic> _stats = {
    'leaveBalance': 0,
    'activeAdvances': 0,
    'totalLeaves': 0,
    'totalTravel': 0,
    'totalRequests': 0,
    'pendingRequests': 0,
    'approvedRequests': 0,
  };

  // ✅ New variables for leave balance details
  Map<String, dynamic> _leaveDetails = {};
  double _totalAllocated = 0;
  double _totalTaken = 0;
  double _totalRemaining = 0;

  bool _isLoadingStats = true;
  String _employeeId = "";
  String _employeeName = "";

  final List<String> bannerImages = [
    'assets/images/banner1.jpg',
    'assets/images/banner2.jpg',
    'assets/images/banner3.jpg',
    'assets/images/banner4.jpg',
    'assets/images/banner5.jpg',
    'assets/images/banner6.jpg',
    'assets/images/banner7.jpg',
  ];

  // Sky Blue Color Palette - Fresh and Professional
  static const Color skyBlue = Color(0xFF87CEEB); // Sky blue primary
  static const Color lightSky = Color(0xFFE0F2FE); // Very light sky
  static const Color mediumSky = Color(0xFF7EC8E0); // Medium sky
  static const Color deepSky = Color(0xFF00A5E0); // Deep sky for accents
  static const Color offWhite = Color(0xFFF8FAFC);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color charcoal = Color(0xFF1E293B);
  static const Color slate = Color(0xFF334155);

  // ✅ Updated Quick Stats Cards - SCREENSHOT STYLE with BORDERS
  final List<Map<String, dynamic>> quickStatsCards = [
    {
      'title': 'Total\nRequests',
      'value': '0',
      'icon': Icons.assignment_rounded,
      'subtitle': 'All requests',
      'color': skyBlue,
      'bgColor': Colors.blue.shade50,
      'borderColor': skyBlue,
    },
    {
      'title': 'Leave\nRequests',
      'value': '0',
      'icon': Icons.beach_access_rounded,
      'subtitle': 'Total leaves',
      'color': Colors.green,
      'bgColor': Colors.green.shade50,
      'borderColor': Colors.green,
    },
    {
      'title': 'Travel\nRequests',
      'value': '0',
      'icon': Icons.flight_rounded,
      'subtitle': 'Total travels',
      'color': Colors.orange,
      'bgColor': Colors.orange.shade50,
      'borderColor': Colors.orange,
    },
    {
      'title': 'Pending\nApproval',
      'value': '0',
      'icon': Icons.pending_actions_rounded,
      'subtitle': 'Awaiting review',
      'color': Colors.purple,
      'bgColor': Colors.purple.shade50,
      'borderColor': Colors.purple,
    },
    {
      'title': 'Approved\nRequests',
      'value': '0',
      'icon': Icons.check_circle_rounded,
      'subtitle': 'Completed',
      'color': Colors.teal,
      'bgColor': Colors.teal.shade50,
      'borderColor': Colors.teal,
    },
  ];

  // ✅ Quick Access Modules with bgPattern (FIXED)
  final List<Map<String, dynamic>> modules = [
    {
      'title': 'Leave Request',
      'subtitle': 'Apply for leave',
      'icon': Icons.beach_access_rounded,
      'bgPattern': Icons.waves_rounded,
      'type': 'Leave_Request',
      'route': '/leaveRequest',
    },
    {
      'title': 'Employee Advance',
      'subtitle': 'Request advance',
      'icon': Icons.attach_money_rounded,
      'bgPattern': Icons.trending_up_rounded,
      'type': 'employee_Advance',
      'route': '/employeeAdvance',
    },
    {
      'title': 'Request Approval',
      'subtitle': 'Approve requests',
      'icon': Icons.approval_rounded,
      'bgPattern': Icons.how_to_reg_rounded,
      'type': 'Leave_Approval',
      'route': '/leaveApprovalScreen',
    },
    {
      'title': 'Attendance',
      'subtitle': 'Mark attendance',
      'icon': Icons.fingerprint_rounded,
      'bgPattern': Icons.schedule_rounded,
      'type': 'Attendance_request',
      'route': '/attendanceRequest',
    },
    {
      'title': 'Travel Request',
      'subtitle': 'Plan travel',
      'icon': Icons.flight_rounded,
      'bgPattern': Icons.explore_rounded,
      'type': 'Travel_request',
      'route': '/travelRequest',
    },
    {
      'title': 'Leave Balance',
      'subtitle': 'Check balance',
      'icon': Icons.account_balance_wallet_rounded,
      'bgPattern': Icons.timer_rounded,
      'type': 'Leave_Balance',
      'route': '/leaveBalaneceScreen',
    },
    {
      'title': 'More',
      'subtitle': 'Additional features',
      'icon': Icons.apps_rounded,
      'bgPattern': Icons.more_horiz_rounded,
      'type': 'Check_More',
      'route': '/checkMore',
    },
  ];

  // Theme-aware colors with sky blue
  Color _getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? charcoal
        : offWhite;
  }

  Color _getSurfaceColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? slate : pureWhite;
  }

  Color _getTextPrimaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? pureWhite
        : charcoal;
  }

  Color _getTextSecondaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
  }

  Color _getBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _bannerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _greetingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _statsAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _updateGreeting();
    _startBannerAnimation();
    _greetingController.forward();

    _loadEmployeeData().then((_) {
      if (_employeeId.isNotEmpty) {
        _fetchDashboardStats();
      }
    });
  }

  Future<void> _loadEmployeeData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _employeeId = prefs.getString("employeeId") ?? "";
        _employeeName = prefs.getString("employeeName") ?? "";
      });
    } catch (e) {
      print("Error loading employee data: $e");
    }
  }

  Future<void> _fetchDashboardStats() async {
    setState(() => _isLoadingStats = true);

    try {
      int totalLeaves = 0;
      int totalTravel = 0;

      // ✅ Variables for leave status
      int leavePending = 0;
      int leaveApproved = 0;

      // ✅ Variables for travel status
      int travelPending = 0;
      int travelApproved = 0;

      _totalAllocated = 0;
      _totalTaken = 0;
      _totalRemaining = 0;

      // ✅ Fetch and process leaves
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

        totalLeaves = userLeaves.length;

        // ✅ Count leave pending and approved
        leavePending = userLeaves
            .where(
              (l) =>
                  l.status != null &&
                  (l.status.toLowerCase() == 'pending' ||
                      l.status.toLowerCase() == 'open' ||
                      l.status.toLowerCase() == 'draft'),
            )
            .length;

        leaveApproved = userLeaves
            .where(
              (l) =>
                  l.status != null &&
                  (l.status.toLowerCase() == 'approved' ||
                      l.status.toLowerCase() == 'completed'),
            )
            .length;

        print(
          "📊 Leaves - Total: $totalLeaves, Pending: $leavePending, Approved: $leaveApproved",
        );
      } catch (e) {
        print("Error fetching leaves: $e");
      }

      // ✅ Fetch and process travels
      try {
        final travels = await TravelRequestService.getMyTravelRequests(
          _employeeId,
        );
        totalTravel = travels.length;

        // ✅ Count travel pending and approved
        travelPending = travels.where((t) {
          final status = (t["status"] ?? "").toString().toLowerCase();
          return status.contains('pending') ||
              status.contains('draft') ||
              status.contains('open');
        }).length;

        travelApproved = travels.where((t) {
          final status = (t["status"] ?? "").toString().toLowerCase();
          return status.contains('approved') || status.contains('completed');
        }).length;

        print(
          "📊 Travels - Total: $totalTravel, Pending: $travelPending, Approved: $travelApproved",
        );
      } catch (e) {
        print("Error fetching travels: $e");
      }

      // ✅ Calculate combined totals
      int totalRequests = totalLeaves + totalTravel;
      int totalPending = leavePending + travelPending;
      int totalApproved = leaveApproved + travelApproved;

      print(
        "✅ COMBINED - Total Requests: $totalRequests, Pending: $totalPending, Approved: $totalApproved",
      );

      // ✅ Fetch leave balance
      try {
        final leaveService = LeaveBalanceService();
        final result = await leaveService.fetchLeaveBalances();

        if (result['success'] == true) {
          _leaveDetails = result['leaveDetails'] ?? {};
          final totals = result['totals'] ?? {};
          _totalAllocated = totals['allocated'] ?? 0;
          _totalTaken = totals['taken'] ?? 0;
          _totalRemaining = totals['remaining'] ?? 0;

          print(
            "✅ Leave Balance - Allocated: $_totalAllocated, Taken: $_totalTaken, Remaining: $_totalRemaining",
          );
        }
      } catch (e) {
        print("❌ Error fetching leave balance: $e");
      }

      if (mounted) {
        setState(() {
          _stats = {
            'leaveBalance': _totalRemaining,
            'activeAdvances': 1,
            'totalLeaves': totalLeaves,
            'totalTravel': totalTravel,
            'totalRequests': totalRequests,
            'pendingRequests': totalPending,
            'approvedRequests': totalApproved,
          };

          // Update quick stats cards with real values
          quickStatsCards[0]['value'] = totalRequests.toString();
          quickStatsCards[1]['value'] = totalLeaves.toString();
          quickStatsCards[2]['value'] = totalTravel.toString();
          quickStatsCards[3]['value'] = totalPending.toString();
          quickStatsCards[4]['value'] = totalApproved.toString();

          _isLoadingStats = false;
          _statsAnimationController.forward(from: 0.0);
        });
      }
    } catch (e) {
      print("❌ Error in _fetchDashboardStats: $e");
      if (mounted) {
        setState(() => _isLoadingStats = false);
        _statsAnimationController.forward(from: 0.0);
      }
    }
  }

  void _updateGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      _greetingMessage = "Good Morning";
      _greetingIcon = Icons.wb_sunny;
    } else if (hour < 17) {
      _greetingMessage = "Good Afternoon";
      _greetingIcon = Icons.wb_cloudy;
    } else {
      _greetingMessage = "Good Evening";
      _greetingIcon = Icons.nightlight_round;
    }
  }

  void _startBannerAnimation() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 5));
      if (!mounted) return false;

      _bannerController.forward().then((_) {
        setState(() {
          currentIndex = (currentIndex + 1) % bannerImages.length;
        });
        _bannerController.reverse();
      });

      return true;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bannerController.dispose();
    _greetingController.dispose();
    _statsAnimationController.dispose();
    super.dispose();
  }

  // Responsive sizing
  double _getResponsiveFontSize(double baseSize, double width) {
    if (width < 360) return baseSize * 0.9;
    if (width > 600) return baseSize * 1.2;
    if (width > 900) return baseSize * 1.4;
    return baseSize;
  }

  // Button-like press navigation
  void _handlePress(int index, String routeName) {
    setState(() {
      _pressedModuleIndex = index;
    });

    HapticFeedback.lightImpact();

    Future.delayed(const Duration(milliseconds: 80), () {
      if (mounted) {
        Navigator.pushNamed(context, routeName).then((_) {
          if (mounted) {
            setState(() {
              _pressedModuleIndex = -1;
            });
          }
        });
      }
    });
  }

  void _handlePressCancel() {
    setState(() {
      _pressedModuleIndex = -1;
    });
  }

  // Elegant Header
  Widget _buildDashboardHeader(
    BuildContext context,
    double width,
    double height,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = _getSurfaceColor(context);
    final textPrimary = _getTextPrimaryColor(context);
    final textSecondary = _getTextSecondaryColor(context);
    final borderColor = _getBorderColor(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: height * 0.02,
        left: width * 0.04,
        right: width * 0.04,
        bottom: height * 0.03,
      ),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: skyBlue.withOpacity(isDark ? 0.2 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Profile
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pushNamed(context, "/settingScreen");
                  },
                  borderRadius: BorderRadius.circular(width * 0.08),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: skyBlue.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Consumer<ProfileProvider>(
                      builder: (context, provider, child) {
                        final user = provider.profileData;
                        return CircleAvatar(
                          radius: width * 0.06,
                          backgroundColor: lightSky,
                          child: ClipOval(
                            child:
                                (user != null &&
                                    user['user_image'] != null &&
                                    user['user_image'].toString().isNotEmpty)
                                ? Image.network(
                                    "https://ppecon.erpnext.com${user['user_image']}",
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                    headers: {
                                      "Cookie": AuthService.cookies.join("; "),
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        "assets/images/app_icon.png",
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  )
                                : Image.asset(
                                    "assets/images/app_icon.png",
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Logo
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(width * 0.02),
                    decoration: BoxDecoration(
                      color: skyBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.asset(
                      "assets/images/app_icon.png",
                      width: width * 0.05,
                      height: width * 0.05,
                      color: skyBlue,
                    ),
                  ),
                  SizedBox(width: width * 0.02),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "PIONEER",
                        style: TextStyle(
                          fontSize: _getResponsiveFontSize(
                            width * 0.045,
                            width,
                          ),
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        "TECH",
                        style: TextStyle(
                          fontSize: _getResponsiveFontSize(
                            width * 0.035,
                            width,
                          ),
                          fontWeight: FontWeight.w400,
                          color: textSecondary,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Notification
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: skyBlue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pushNamed(context, "/notificationScreen");
                      },
                      icon: Icon(
                        Icons.notifications_none_rounded,
                        size: width * 0.06,
                        color: skyBlue,
                      ),
                    ),
                  ),
                  Positioned(
                    top: height * 0.005,
                    right: width * 0.01,
                    child: Container(
                      width: width * 0.02,
                      height: width * 0.02,
                      decoration: BoxDecoration(
                        color: skyBlue,
                        shape: BoxShape.circle,
                        border: Border.all(color: surfaceColor, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: height * 0.02),

          // Welcome Card
          Consumer<ProfileProvider>(
            builder: (context, provider, child) {
              final user = provider.profileData;
              final fullName = user != null && user['full_name'] != null
                  ? user['full_name']
                  : _employeeName.isNotEmpty
                  ? _employeeName
                  : 'User';

              return Container(
                width: double.infinity,
                padding: EdgeInsets.all(width * 0.04),
                decoration: BoxDecoration(
                  color: skyBlue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: skyBlue.withOpacity(0.2), width: 1),
                ),
                child: Row(
                  children: [
                    // Greeting Icon
                    Container(
                      padding: EdgeInsets.all(width * 0.025),
                      decoration: BoxDecoration(
                        color: skyBlue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _greetingIcon,
                        color: skyBlue,
                        size: width * 0.06,
                      ),
                    ),
                    SizedBox(width: width * 0.03),

                    // Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _greetingMessage,
                            style: TextStyle(
                              fontSize: _getResponsiveFontSize(
                                width * 0.035,
                                width,
                              ),
                              color: textSecondary,
                            ),
                          ),
                          Text(
                            fullName,
                            style: TextStyle(
                              fontSize: _getResponsiveFontSize(
                                width * 0.04,
                                width,
                              ),
                              fontWeight: FontWeight.w600,
                              color: textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Date
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.035,
                        vertical: height * 0.01,
                      ),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderColor, width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: width * 0.03,
                            color: skyBlue,
                          ),
                          SizedBox(width: width * 0.01),
                          Text(
                            _getFormattedDate(),
                            style: TextStyle(
                              fontSize: _getResponsiveFontSize(
                                width * 0.03,
                                width,
                              ),
                              color: textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${now.day} ${months[now.month - 1]}';
  }

  // Banner Slider
  Widget _buildBannerSlider(double width, double height) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width * 0.92,
      height: height * 0.18,
      margin: EdgeInsets.symmetric(vertical: height * 0.02),
      child: Stack(
        children: [
          // Banner
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 800),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: Container(
              key: ValueKey<int>(currentIndex),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: AssetImage(bannerImages[currentIndex]),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: skyBlue.withOpacity(isDark ? 0.2 : 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
            ),
          ),

          // Indicators
          Positioned(
            bottom: height * 0.015,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                bannerImages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: width * 0.01),
                  width: currentIndex == index ? width * 0.08 : width * 0.025,
                  height: width * 0.012,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(width * 0.02),
                    color: currentIndex == index
                        ? skyBlue
                        : Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Quick Stats with SCREENSHOT STYLE DESIGN
  // ✅ Quick Stats with SCREENSHOT STYLE DESIGN - NO OVERFLOW
  Widget _buildQuickStats(double width, double height, BuildContext context) {
    if (_isLoadingStats) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: width * 0.04),
        child: Column(
          children: [
            _buildSectionHeader(context, width, height, "Quick Stats"),
            SizedBox(height: height * 0.02),
            const Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(skyBlue),
              ),
            ),
          ],
        ),
      );
    }

    // Responsive grid - 5 cards with PROPER ASPECT RATIO
    int crossAxisCount = width < 400
        ? 2
        : (width < 600 ? 2 : (width < 900 ? 3 : 5));

    // ✅ FIXED: Better aspect ratio calculation
    double cardHeight = width < 400 ? height * 0.14 : height * 0.12;
    double cardWidth =
        (width - (crossAxisCount + 1) * width * 0.02) / crossAxisCount;
    double aspectRatio = cardWidth / cardHeight;

    double spacing = width * 0.02;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: width * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, width, height, "Quick Stats"),
          SizedBox(height: height * 0.02),

          // Stats Grid with Bounce Animation
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: quickStatsCards.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: aspectRatio,
              crossAxisSpacing: spacing,
              mainAxisSpacing: height * 0.01, // ✅ Reduced spacing
            ),
            itemBuilder: (context, index) {
              final card = quickStatsCards[index];
              return AnimatedBuilder(
                animation: _statsAnimationController,
                builder: (context, child) {
                  double delay = index * 0.08;
                  double animationValue =
                      (_statsAnimationController.value - delay).clamp(0.0, 1.0);

                  return Transform.scale(
                    scale: Curves.elasticOut.transform(animationValue),
                    child: Opacity(
                      opacity: animationValue,
                      child: _buildStatCardScreenshotStyle(
                        context,
                        width,
                        height,
                        card,
                      ),
                    ),
                  );
                },
              );
            },
          ),

          // Leave breakdown section
          if (_leaveDetails.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: height * 0.02),
              child: _buildLeaveBreakdown(width, height, context),
            ),
        ],
      ),
    );
  }

  // ✅ SCREENSHOT STYLE stat card - with colored background, border, and reduced height
  Widget _buildStatCardScreenshotStyle(
    BuildContext context,
    double width,
    double height,
    Map<String, dynamic> card,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = _getTextPrimaryColor(context);
    final textSecondary = _getTextSecondaryColor(context);

    final Color cardColor = card['color'] ?? skyBlue;
    final Color borderColor = card['borderColor'] ?? cardColor;
    final Color bgColor = isDark
        ? cardColor.withOpacity(0.15)
        : (card['bgColor'] ?? cardColor.withOpacity(0.1));

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12), // ✅ Smaller radius
        border: Border.all(color: borderColor.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: cardColor.withOpacity(isDark ? 0.2 : 0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(width * 0.015), // ✅ Reduced padding
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon with background circle
            Container(
              padding: EdgeInsets.all(width * 0.01), // ✅ Smaller padding
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: cardColor.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Icon(
                card['icon'] as IconData,
                color: cardColor,
                size: width * 0.04, // ✅ Smaller icon
              ),
            ),

            SizedBox(height: height * 0.006), // ✅ Reduced spacing
            // Title - with line breaks
            Text(
              card['title'] as String,
              style: TextStyle(
                fontSize: _getResponsiveFontSize(
                  width * 0.024,
                  width,
                ), // ✅ Smaller font
                fontWeight: FontWeight.w600,
                color: textPrimary,
                height: 1.1,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(height: height * 0.003), // ✅ Reduced spacing
            // Value
            Text(
              card['value'] as String,
              style: TextStyle(
                fontSize: _getResponsiveFontSize(
                  width * 0.036,
                  width,
                ), // ✅ Smaller font
                fontWeight: FontWeight.w800,
                color: cardColor,
              ),
              textAlign: TextAlign.center,
            ),

            // Subtitle
            Text(
              card['subtitle'] as String,
              style: TextStyle(
                fontSize: _getResponsiveFontSize(
                  width * 0.018,
                  width,
                ), // ✅ Smaller font
                color: textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Leave breakdown widget
  Widget _buildLeaveBreakdown(
    double width,
    double height,
    BuildContext context,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = _getSurfaceColor(context);
    final textPrimary = _getTextPrimaryColor(context);
    final borderColor = _getBorderColor(context);

    if (_leaveDetails.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: skyBlue.withOpacity(isDark ? 0.1 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pie_chart_rounded, color: skyBlue, size: width * 0.05),
              SizedBox(width: width * 0.02),
              Text(
                'Leave Breakdown',
                style: TextStyle(
                  fontSize: _getResponsiveFontSize(width * 0.04, width),
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: height * 0.015),
          ..._leaveDetails.entries.map((entry) {
            final leaveType = entry.key;
            final details = entry.value as Map<String, double>;
            final allocated = details['allocated'] ?? 0;
            final taken = details['taken'] ?? 0;
            final remaining = details['remaining'] ?? 0;

            Color progressColor;
            if (leaveType.toLowerCase().contains('sick')) {
              progressColor = Colors.orange;
            } else if (leaveType.toLowerCase().contains('annual')) {
              progressColor = Colors.green;
            } else {
              progressColor = skyBlue;
            }

            return Padding(
              padding: EdgeInsets.only(bottom: height * 0.012),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          leaveType,
                          style: TextStyle(
                            fontSize: _getResponsiveFontSize(
                              width * 0.032,
                              width,
                            ),
                            fontWeight: FontWeight.w500,
                            color: textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${remaining.toStringAsFixed(1)} / ${allocated.toStringAsFixed(1)} days',
                        style: TextStyle(
                          fontSize: _getResponsiveFontSize(width * 0.03, width),
                          color: progressColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: height * 0.004),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: allocated > 0
                          ? (taken / allocated).clamp(0.0, 1.0)
                          : 0,
                      backgroundColor: borderColor,
                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                      minHeight: height * 0.006,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: height * 0.002),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Taken: ${taken.toStringAsFixed(1)}',
                          style: TextStyle(
                            fontSize: _getResponsiveFontSize(
                              width * 0.024,
                              width,
                            ),
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          'Remaining: ${remaining.toStringAsFixed(1)}',
                          style: TextStyle(
                            fontSize: _getResponsiveFontSize(
                              width * 0.024,
                              width,
                            ),
                            color: progressColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // ✅ Module Grid with bgPattern (FIXED)
  Widget _buildModuleGrid(double width, double height, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = _getSurfaceColor(context);
    final textPrimary = _getTextPrimaryColor(context);
    final textSecondary = _getTextSecondaryColor(context);
    final borderColor = _getBorderColor(context);

    // Responsive grid
    int crossAxisCount = width < 400
        ? 2
        : (width < 600 ? 2 : (width < 900 ? 3 : 4));
    double cardHeight = width < 400 ? height * 0.16 : height * 0.15;
    double spacing = width * 0.03;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: width * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, width, height, "Quick Access"),
          SizedBox(height: height * 0.02),

          // Module Grid with Button Press Effect
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: modules.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: width / (cardHeight * crossAxisCount),
              crossAxisSpacing: spacing,
              mainAxisSpacing: height * 0.015,
            ),
            itemBuilder: (context, index) {
              final module = modules[index];
              final isPressed = _pressedModuleIndex == index;

              return GestureDetector(
                onTapDown: (_) {
                  setState(() {
                    _pressedModuleIndex = index;
                  });
                },
                onTapUp: (_) {
                  _handlePress(index, module['route']);
                },
                onTapCancel: () {
                  _handlePressCancel();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 50),
                  curve: Curves.easeOut,
                  transform: isPressed
                      ? Matrix4.diagonal3Values(0.95, 0.95, 1.0)
                      : Matrix4.identity(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isPressed
                          ? skyBlue.withOpacity(0.1)
                          : surfaceColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isPressed ? skyBlue : borderColor,
                        width: isPressed ? 2 : 1,
                      ),
                      boxShadow: [
                        if (isPressed)
                          BoxShadow(
                            color: skyBlue.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          )
                        else
                          BoxShadow(
                            color: skyBlue.withOpacity(isDark ? 0.1 : 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Background Pattern (KEEP for modules)
                        Positioned.fill(
                          child: Opacity(
                            opacity: isPressed ? 0.3 : 0.2,
                            child: Icon(
                              module['bgPattern'] as IconData,
                              size: width * 0.3,
                              color: skyBlue,
                            ),
                          ),
                        ),

                        // Content
                        Padding(
                          padding: EdgeInsets.all(width * 0.035),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Icon with press effect
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 50),
                                padding: EdgeInsets.all(
                                  isPressed ? width * 0.03 : width * 0.025,
                                ),
                                decoration: BoxDecoration(
                                  color: isPressed
                                      ? skyBlue
                                      : skyBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    if (isPressed)
                                      BoxShadow(
                                        color: skyBlue.withOpacity(0.5),
                                        blurRadius: 10,
                                      ),
                                  ],
                                ),
                                child: Icon(
                                  module['icon'] as IconData,
                                  color: isPressed ? Colors.white : skyBlue,
                                  size: isPressed
                                      ? width * 0.055
                                      : width * 0.05,
                                ),
                              ),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title
                                  Text(
                                    module['title'],
                                    style: TextStyle(
                                      fontSize: _getResponsiveFontSize(
                                        width * 0.035,
                                        width,
                                      ),
                                      fontWeight: isPressed
                                          ? FontWeight.w700
                                          : FontWeight.w600,
                                      color: isPressed ? skyBlue : textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  SizedBox(height: height * 0.004),

                                  // Subtitle
                                  Text(
                                    module['subtitle'],
                                    style: TextStyle(
                                      fontSize: _getResponsiveFontSize(
                                        width * 0.024,
                                        width,
                                      ),
                                      color: isPressed
                                          ? skyBlue.withOpacity(0.8)
                                          : textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Section Header
  Widget _buildSectionHeader(
    BuildContext context,
    double width,
    double height,
    String title,
  ) {
    final textPrimary = _getTextPrimaryColor(context);
    final textSecondary = _getTextSecondaryColor(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: _getResponsiveFontSize(width * 0.05, width),
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.03,
            vertical: height * 0.005,
          ),
          decoration: BoxDecoration(
            color: skyBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            title == "Quick Stats"
                ? "${quickStatsCards.length} Items"
                : "${modules.length} Modules",
            style: TextStyle(
              fontSize: _getResponsiveFontSize(width * 0.026, width),
              color: skyBlue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final backgroundColor = _getBackgroundColor(context);
    final surfaceColor = _getSurfaceColor(context);
    final textSecondary = _getTextSecondaryColor(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: backgroundColor,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: const AlwaysStoppedAnimation<Color>(skyBlue),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    HapticFeedback.mediumImpact();
                    await _fetchDashboardStats();
                    _statsAnimationController.forward(from: 0.0);
                  },
                  color: skyBlue,
                  backgroundColor: surfaceColor,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    child: Column(
                      children: [
                        // Header
                        _buildDashboardHeader(context, width, height),

                        // Banner
                        _buildBannerSlider(width, height),

                        // Quick Stats with SCREENSHOT STYLE
                        _buildQuickStats(width, height, context),

                        SizedBox(height: height * 0.02),

                        // Modules with Button Press Feel
                        _buildModuleGrid(width, height, context),

                        SizedBox(height: height * 0.03),

                        // Bottom Info
                        Container(
                          padding: EdgeInsets.symmetric(
                            vertical: height * 0.018,
                            horizontal: width * 0.04,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.security_rounded,
                                    size: width * 0.04,
                                    color: skyBlue.withOpacity(0.7),
                                  ),
                                  SizedBox(width: width * 0.015),
                                  Text(
                                    'Secure',
                                    style: TextStyle(
                                      fontSize: _getResponsiveFontSize(
                                        width * 0.028,
                                        width,
                                      ),
                                      color: textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.sync_rounded,
                                    size: width * 0.04,
                                    color: skyBlue.withOpacity(0.7),
                                  ),
                                  SizedBox(width: width * 0.015),
                                  Text(
                                    'Synced',
                                    style: TextStyle(
                                      fontSize: _getResponsiveFontSize(
                                        width * 0.028,
                                        width,
                                      ),
                                      color: textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: height * 0.02),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
