// ignore_for_file: deprecated_member_use, empty_catches

import 'package:flutter/material.dart';
import 'package:management_app/providers/profile_provider.dart';
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
  late bool _isDarkMode;
  late AnimationController _bannerController;
  late AnimationController _greetingController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  String _greetingMessage = "";
  IconData _greetingIcon = Icons.wb_sunny;

  // Accurate Stats - Only totals, no pending
  Map<String, dynamic> _stats = {
    'leaveBalance': 0,
    'activeAdvances': 0,
    'totalLeaves': 0,
    'totalTravel': 0,
    'totalRequests': 0,
  };
  
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

  // Clean modules without any stats
  final List<Map<String, dynamic>> modules = [
    {
      'title': 'Leave Request',
      'subtitle': 'Apply for leave and manage your requests',
      'image': 'assets/images/leaverequest.png',
      'type': 'Leave_Request',
      'color': Colors.blue,
    },
    {
      'title': 'Employee Advance',
      'subtitle': 'Request salary advance and track status',
      'image': 'assets/images/leaverequest.png',
      'type': 'employee_Advance',
      'color': Colors.green,
    },
    {
      'title': 'Request Approval',
      'subtitle': 'Approve or reject pending requests',
      'image': 'assets/images/leaveapproved.png',
      'type': 'Leave_Approval',
      'color': Colors.amber,
    },
    {
      'title': 'Attendance',
      'subtitle': 'Mark attendance and request corrections',
      'image': 'assets/images/attendanceicon.png',
      'type': 'Attendance_request',
      'color': Colors.purple,
    },
    {
      'title': 'Travel Request',
      'subtitle': 'Submit and manage travel requests',
      'image': 'assets/images/travel.png',
      'type': 'Travel_request',
      'color': Colors.orange,
    },
    {
      'title': 'Leave Balance',
      'subtitle': 'Check your leave balance and history',
      'image': 'assets/images/leavebalence.png',
      'type': 'Leave_Balance',
      'color': Colors.red,
    },
    {
      'title': 'More',
      'subtitle': 'Access additional features and tools',
      'image': 'assets/images/more.png',
      'type': 'Check_More',
      'color': Colors.teal,
    },
  ];

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

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _greetingController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _greetingController, curve: Curves.easeOut));

    _updateGreeting();
    _startBannerAnimation();
    _greetingController.forward();
    
    // Load employee data and fetch stats
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
      int leaveBalance = 18; 

      // Fetch Leaves Data
      try {
        final leaves = await LeaveApprovedService.fetchLeaves();
        
        // Filter leaves for current user
        final userLeaves = leaves.where((leave) {
          return leave.employeeName.toLowerCase().contains(
                _employeeName.toLowerCase(),
              ) ||
              _employeeName.toLowerCase().contains(
                leave.employeeName.toLowerCase(),
              );
        }).toList();

        totalLeaves = userLeaves.length;
        
      } catch (e) {
       
      }

      // Fetch Travel Data
      try {
        final travels = await TravelRequestService.getMyTravelRequests(_employeeId);
        

        final userTravels = travels.where((travel) {
          final travelEmpId = travel["employee"]?.toString() ?? "";
          final travelEmpName = travel["employee_name"]?.toString() ?? "";
          return travelEmpId == _employeeId ||
              travelEmpName.toLowerCase().contains(
                _employeeName.toLowerCase(),
              ) ||
              _employeeName.toLowerCase().contains(travelEmpName.toLowerCase());
        }).toList();

        totalTravel = userTravels.length;
        
      } catch (e) {
        
      }

      // Total requests
      int totalRequests = totalLeaves + totalTravel;

      if (mounted) {
        setState(() {
          _stats = {
            'leaveBalance': leaveBalance,
            'activeAdvances': 1,
            'totalLeaves': totalLeaves,
            'totalTravel': totalTravel,
            'totalRequests': totalRequests,
          };
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      print('Error fetching stats: $e');
      if (mounted) {
        setState(() => _isLoadingStats = false);
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isDarkMode = Theme.of(context).brightness == Brightness.dark;
    _updateSystemNavigationBar();
  }

  void _updateSystemNavigationBar() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: _isDarkMode ? Colors.black : Colors.white,
        systemNavigationBarIconBrightness: _isDarkMode ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: _isDarkMode ? Brightness.light : Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bannerController.dispose();
    _greetingController.dispose();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        statusBarColor: Colors.transparent,
      ),
    );
    super.dispose();
  }

  // Get gradient colors based on theme
  List<Color> _getHeaderGradientColors() {
    return _isDarkMode
        ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
        : [const Color(0xFFE3F2FD), const Color(0xFFF3E5F5)];
  }

  Widget _buildDashboardHeader(BuildContext context, double width, double height) {
    final theme = Theme.of(context);
    final gradientColors = _getHeaderGradientColors();
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: height * 0.02,
          left: width * 0.04,
          right: width * 0.04,
          bottom: height * 0.02,
        ),
        child: Column(
          children: [
            // Top row with profile, logo and notification
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile with ripple effect
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pushNamed(context, "/settingScreen");
                    },
                    borderRadius: BorderRadius.circular(width * 0.06),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Consumer<ProfileProvider>(
                        builder: (context, provider, child) {
                          final user = provider.profileData;
                          return CircleAvatar(
                            radius: width * 0.06,
                            backgroundImage:
                                (user != null &&
                                        user['user_image'] != null &&
                                        user['user_image'] != "")
                                    ? NetworkImage(
                                        "https://ppecon.erpnext.com${user['user_image']}",
                                      )
                                    : const AssetImage("assets/images/app_icon.png")
                                        as ImageProvider,
                          );
                        },
                      ),
                    ),
                  ),
                ),
                
                // Logo with shimmer effect
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 800),
                  builder: (context, double value, child) {
                    return Opacity(
                      opacity: value,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.secondary,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(width * 0.03),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.3),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.04,
                            vertical: height * 0.01,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(width * 0.015),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(width * 0.02),
                                ),
                                child: Image.asset(
                                  "assets/images/app_icon.png",
                                  width: width * 0.08,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: width * 0.02),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "PIONEER",
                                    style: TextStyle(
                                      fontSize: width * 0.04,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 1,
                                      height: 1.0,
                                    ),
                                  ),
                                  Text(
                                    "TECH",
                                    style: TextStyle(
                                      fontSize: width * 0.04,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 1,
                                      height: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                // Notification icon without badge
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: IconButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pushNamed(context, "/notificationScreen");
                    },
                    icon: Icon(
                      Icons.notifications_none,
                      size: width * 0.07,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: height * 0.02),
            
            // Animated welcome message with greeting
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Consumer<ProfileProvider>(
                  builder: (context, provider, child) {
                    final user = provider.profileData;
                    final fullName = user != null && user['full_name'] != null
                        ? user['full_name']
                        : _employeeName.isNotEmpty ? _employeeName : 'User';
                    
                    return Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.04,
                        vertical: height * 0.015,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(width * 0.03),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Greeting Icon
                          Container(
                            padding: EdgeInsets.all(width * 0.015),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _greetingIcon,
                              color: Colors.amber,
                              size: width * 0.06,
                            ),
                          ),
                          SizedBox(width: width * 0.03),
                          
                          // Greeting Text and Full Name
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _greetingMessage,
                                  style: TextStyle(
                                    fontSize: width * 0.035,
                                    color: Colors.white.withOpacity(0.9),
                                    height: 1.2,
                                  ),
                                ),
                                Text(
                                  fullName,
                                  style: TextStyle(
                                    fontSize: width * 0.045,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    height: 1.2,
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
                              horizontal: width * 0.025,
                              vertical: height * 0.005,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(width * 0.02),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: width * 0.04,
                                  color: Colors.white,
                                ),
                                SizedBox(width: width * 0.015),
                                Text(
                                  _getFormattedDate(),
                                  style: TextStyle(
                                    fontSize: width * 0.03,
                                    color: Colors.white,
                                    height: 1.0,
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${now.day} ${months[now.month - 1]}';
  }

  Widget _buildBannerSlider(double width, double height) {
    return Container(
      width: width * 0.9,
      height: height * 0.2,
      margin: EdgeInsets.symmetric(vertical: height * 0.02),
      child: Stack(
        children: [
          // Banner Image
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 800),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 1.1, end: 1.0).animate(animation),
                  child: child,
                ),
              );
            },
            child: Container(
              key: ValueKey<int>(currentIndex),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(width * 0.05),
                image: DecorationImage(
                  image: AssetImage(bannerImages[currentIndex]),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(width * 0.05),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.4),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Page Indicators
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
                  width: currentIndex == index ? width * 0.06 : width * 0.025,
                  height: width * 0.01,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(width * 0.02),
                    color: currentIndex == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
          
          // Hint Text
          Positioned(
            bottom: height * 0.035,
            left: width * 0.05,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.03,
                vertical: height * 0.005,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(width * 0.02),
              ),
              child: Text(
                '✨ Latest Updates',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: width * 0.03,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Clean module grid WITHOUT any stats badges
  Widget _buildModuleGrid(double width, double height, BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: width * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: EdgeInsets.only(bottom: height * 0.015),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(width * 0.02),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(width * 0.02),
                      ),
                      child: Icon(
                        Icons.apps_rounded,
                        size: width * 0.05,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    SizedBox(width: width * 0.02),
                    Text(
                      "Quick Access",
                      style: TextStyle(
                        fontSize: width * 0.05,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onBackground,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.03,
                    vertical: height * 0.005,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(width * 0.02),
                  ),
                  child: Text(
                    "${modules.length} Modules",
                    style: TextStyle(
                      fontSize: width * 0.03,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Grid of Modules - NO STATS BADGES
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: modules.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.15,
              crossAxisSpacing: width * 0.03,
              mainAxisSpacing: height * 0.015,
            ),
            itemBuilder: (context, index) {
              final module = modules[index];
              final moduleColor = module['color'] as Color;
              
              return TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: Duration(milliseconds: 500 + (index * 100)),
                curve: Curves.easeOutBack,
                builder: (context, double value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(width * 0.04),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _handleModuleTap(module['type'], context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(width * 0.04),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: _isDarkMode
                                  ? [
                                      Colors.grey[850]!,
                                      Colors.grey[900]!,
                                    ]
                                  : [
                                      Colors.white,
                                      Colors.grey[50]!,
                                    ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 15,
                                spreadRadius: 2,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(width * 0.03),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Icon with gradient background - NO STATS BADGE
                                Container(
                                  width: width * 0.12,
                                  height: width * 0.12,
                                  margin: EdgeInsets.only(bottom: height * 0.01),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        moduleColor.withOpacity(0.15),
                                        moduleColor.withOpacity(0.05),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(width * 0.03),
                                    border: Border.all(
                                      color: moduleColor.withOpacity(0.2),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Center(
                                    child: Image.asset(
                                      module['image'],
                                      width: width * 0.06,
                                      height: width * 0.06,
                                      color: moduleColor,
                                    ),
                                  ),
                                ),
                                
                                // Module Title
                                Text(
                                  module['title'],
                                  style: TextStyle(
                                    fontSize: width * 0.04,
                                    fontWeight: FontWeight.w700,
                                    color: theme.colorScheme.onBackground,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                
                                SizedBox(height: height * 0.005),
                                
                                // Module Subtitle
                                Expanded(
                                  child: Text(
                                    module['subtitle'],
                                    style: TextStyle(
                                      fontSize: width * 0.03,
                                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                                      fontWeight: FontWeight.w500,
                                      height: 1.3,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                
                                // Access indicator
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                    vertical: height * 0.006,
                                  ),
                                  decoration: BoxDecoration(
                                    color: moduleColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(width * 0.015),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Tap to open',
                                      style: TextStyle(
                                        fontSize: width * 0.025,
                                        color: moduleColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // Quick Stats with only total counts (no pending)
  Widget _buildQuickStats(double width, double height, BuildContext context) {
    final theme = Theme.of(context);
    
    if (_isLoadingStats) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.04,
          vertical: height * 0.03,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics_rounded,
                  size: width * 0.05,
                  color: theme.colorScheme.primary,
                ),
                SizedBox(width: width * 0.02),
                Text(
                  "Quick Stats",
                  style: TextStyle(
                    fontSize: width * 0.045,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
              ],
            ),
            SizedBox(height: height * 0.02),
            const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ),
      );
    }
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.04,
        vertical: height * 0.02,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: height * 0.015),
            child: Row(
              children: [
                Icon(
                  Icons.analytics_rounded,
                  size: width * 0.05,
                  color: theme.colorScheme.primary,
                ),
                SizedBox(width: width * 0.02),
                Text(
                  "Quick Stats",
                  style: TextStyle(
                    fontSize: width * 0.045,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
              ],
            ),
          ),
          
          // Two rows of stats - only totals
          Row(
            children: [
              // Total Requests Card
              _buildStatCard(
                width, height,
                icon: Icons.list_alt,
                label: "Total Requests",
                value: "${_stats['totalRequests']}",
                subValue: "",
                color: Colors.blue,
              ),
              SizedBox(width: width * 0.03),
              
              // Total Leaves Card
              _buildStatCard(
                width, height,
                icon: Icons.beach_access,
                label: "Total Leaves",
                value: "${_stats['totalLeaves']}",
                subValue: "",
                color: Colors.green,
              ),
              SizedBox(width: width * 0.03),
              
              // Total Travel Card
              _buildStatCard(
                width, height,
                icon: Icons.flight_takeoff,
                label: "Total Travel",
                value: "${_stats['totalTravel']}",
                subValue: "",
                color: Colors.orange,
              ),
            ],
          ),
          
          SizedBox(height: height * 0.015),
          
          // Second Row
          Row(
            children: [
              // Leave Balance Card
              _buildStatCard(
                width, height,
                icon: Icons.balance,
                label: "Leave Balance",
                value: "${_stats['leaveBalance']}",
                subValue: "Days",
                color: Colors.purple,
              ),
              SizedBox(width: width * 0.03),
              
              // Active Advances Card
              _buildStatCard(
                width, height,
                icon: Icons.attach_money,
                label: "Active Advances",
                value: "${_stats['activeAdvances']}",
                subValue: "",
                color: Colors.teal,
              ),
              SizedBox(width: width * 0.03),
              
              // Placeholder for future stat
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(width * 0.03),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(width * 0.03),
                  ),
                  child: const SizedBox(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(double width, double height, {
    required IconData icon,
    required String label,
    required String value,
    required String subValue,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(width * 0.03),
        decoration: BoxDecoration(
          color: _isDarkMode ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(width * 0.03),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(width * 0.02),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: width * 0.05),
            ),
            SizedBox(height: height * 0.01),
            Text(
              label,
              style: TextStyle(
                fontSize: width * 0.028,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
            SizedBox(height: height * 0.005),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: width * 0.045,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                if (subValue.isNotEmpty) ...[
                  SizedBox(width: width * 0.01),
                  Text(
                    subValue,
                    style: TextStyle(
                      fontSize: width * 0.022,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleModuleTap(String type, BuildContext context) {
    switch (type) {
      case 'Leave_Request':
        Navigator.pushNamed(context, '/leaveRequest');
        break;
      case 'employee_Advance':
        Navigator.pushNamed(context, '/employeeAdvance');
        break;
      case 'Leave_Approval':
        Navigator.pushNamed(context, '/leaveApprovalScreen');
        break;
      case 'Attendance_request':
        Navigator.pushNamed(context, '/attendanceRequest');
        break;
      case 'Travel_request':
        Navigator.pushNamed(context, '/travelRequest');
        break;
      case 'Leave_Balance':
        Navigator.pushNamed(context, '/leaveBalaneceScreen');
        break;
      case 'Check_More':
        Navigator.pushNamed(context, '/checkMore');
        break;
      default:
        debugPrint('No route defined for $type');
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    _isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final gradientColors = _getHeaderGradientColors();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: _isDarkMode ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: _isDarkMode ? Colors.black : Colors.white,
        systemNavigationBarIconBrightness: _isDarkMode ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _isDarkMode ? Colors.grey[900] : const Color(0xFFF8FAFD),
        body: Column(
          children: [
            // Status bar area with gradient (fixed at top)
            Container(
              height: MediaQuery.of(context).padding.top,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                ),
              ),
            ),
            // Scrollable content with bounce effect (entire screen except status bar)
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        HapticFeedback.mediumImpact();
                        await _fetchDashboardStats(); // Refresh stats on pull
                      },
                      color: Theme.of(context).colorScheme.primary,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        child: Column(
                          children: [
                            // Header content with gradient
                            _buildDashboardHeader(context, width, height),
                            
                            // Banner Slider
                            _buildBannerSlider(width, height),
                            
                            // Quick Stats Section with only totals
                            _buildQuickStats(width, height, context),
                            
                            SizedBox(height: height * 0.02),
                            
                            // Clean modules without stats
                            _buildModuleGrid(width, height, context),
                            
                            // Bottom Info Bar
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                vertical: height * 0.02,
                                horizontal: width * 0.04,
                              ),
                              margin: EdgeInsets.only(top: height * 0.02),
                              decoration: BoxDecoration(
                                color: _isDarkMode 
                                    ? Colors.black.withOpacity(0.3) 
                                    : Colors.grey[50],
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(width * 0.05),
                                  topRight: Radius.circular(width * 0.05),
                                ),
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.1),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.security,
                                        size: width * 0.04,
                                        color: Colors.green,
                                      ),
                                      SizedBox(width: width * 0.015),
                                      Text(
                                        'Secure Connection',
                                        style: TextStyle(
                                          fontSize: width * 0.03,
                                          color: Colors.grey[600],
                                          height: 1.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.sync_rounded,
                                        size: width * 0.04,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                      SizedBox(width: width * 0.015),
                                      Text(
                                        'Last sync: ${_getFormattedTime()}',
                                        style: TextStyle(
                                          fontSize: width * 0.03,
                                          color: Colors.grey[600],
                                          height: 1.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            
                            // Extra padding at bottom for smooth scrolling
                            SizedBox(height: height * 0.02),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFormattedTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
}