// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:management_app/providers/profile_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final bool _isLoading = false;

  final List<String> bannerImages = [
    'assets/images/banner1.jpg',
    'assets/images/banner2.jpg',
    'assets/images/banner3.jpg',
    'assets/images/banner4.jpg',
    'assets/images/banner5.jpg',
    'assets/images/banner6.jpg',
    'assets/images/banner7.jpg',
  ];

  final List<Map<String, dynamic>> modules = [
    {
      'title': 'Leave Request',
      'subtitle': 'Apply & manage leaves',
      'image': 'assets/images/leaverequest.png',
      'type': 'Leave_Request',
      'color': Colors.blue,
    },
    {
      'title': 'Leave Details',
      'subtitle': 'View leave history',
      'image': 'assets/images/leaverequestdetail.png',
      'type': 'Leave_requestDetail',
      'color': Colors.green,
    },
    {
      'title': 'Leave Approval',
      'subtitle': 'Approve pending leaves',
      'image': 'assets/images/leaveapproved.png',
      'type': 'Leave_Approval',
      'color': Colors.amber,
    },
    {
      'title': 'Attendance',
      'subtitle': 'Submit attendance requests',
      'image': 'assets/images/attendanceicon.png',
      'type': 'Attendance_request',
      'color': Colors.purple,
    },
    {
      'title': 'Travel Request',
      'subtitle': 'Manage travel requests',
      'image': 'assets/images/travel.png',
      'type': 'Travel_request',
      'color': Colors.orange,
    },
    {
      'title': 'Regularization',     
      'subtitle': 'Regularization listing',
      'image': 'assets/images/regularizationlisting.png',
      'type': 'Regularization_Listing',
      'color': Colors.red,
    },
    {
      'title': 'More',
      'subtitle': 'Additional features',
      'image': 'assets/images/more.png',
      'type': 'Check_More',
      'color': Colors.teal,
    },
  ];

  int currentIndex = 0;
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    // Auto slide banner - FIXED ANIMATION
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 7));
      if (!mounted) return false;
      setState(() {
        currentIndex = (currentIndex + 1) % bannerImages.length;
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
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        statusBarColor: Colors.transparent,
      ),
    );
    super.dispose();
  }

  Widget _buildDashboardHeader(BuildContext context, double width, double height) {
    final theme = Theme.of(context);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.04, 
        vertical: height * 0.02,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _isDarkMode
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFFE3F2FD), const Color(0xFFF3E5F5)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(width * 0.06),
          bottomRight: Radius.circular(width * 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top row with profile, logo and notification
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, "/settingScreen");
                },
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
              
              // Logo with gradient
              Container(
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
              
              // Notification with badge
              Stack(
                children: [
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
                        Navigator.pushNamed(context, "/notificationScreen");
                      },
                      icon: Icon(
                        Icons.notifications_none,
                        size: width * 0.07,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    right: width * 0.01,
                    top: width * 0.01,
                    child: Container(
                      width: width * 0.04,
                      height: width * 0.04,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          '3',
                          style: TextStyle(
                            fontSize: width * 0.025,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          SizedBox(height: height * 0.02),
          
          // Welcome message
          Consumer<ProfileProvider>(
            builder: (context, provider, child) {
              final user = provider.profileData;
              final userName = user != null && user['full_name'] != null
                  ? user['full_name']
                  : 'User';
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
                    Icon(
                      Icons.waving_hand,
                      color: Colors.amber,
                      size: width * 0.06,
                    ),
                    SizedBox(width: width * 0.03),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back,',
                            style: TextStyle(
                              fontSize: width * 0.035,
                              color: Colors.white.withOpacity(0.8),
                              height: 1.0,
                            ),
                          ),
                          Text(
                            userName,
                            style: TextStyle(
                              fontSize: width * 0.045,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                            '${DateTime.now().day}/${DateTime.now().month}',
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
        ],
      ),
    );
  }

  Widget _buildBannerSlider(double width, double height) {
    return Container(
      width: width * 0.9,
      height: height * 0.2,
      margin: EdgeInsets.symmetric(vertical: height * 0.02),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(width * 0.05),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 25,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(width * 0.05),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 1500),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: Container(
            key: ValueKey<int>(currentIndex),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(bannerImages[currentIndex]),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModuleGrid(double width, double height, BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: width * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: height * 0.015),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Quick Access",
                  style: TextStyle(
                    fontSize: width * 0.045,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onBackground,
                    letterSpacing: 0.5,
                    height: 1.0,
                  ),
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
                      height: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.only(bottom: height * 0.02),
            itemCount: modules.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.9,
              crossAxisSpacing: width * 0.03,
              mainAxisSpacing: height * 0.015,
            ),
            itemBuilder: (context, index) {
              final module = modules[index];
              final moduleColor = module['color'] as Color;
              
              return Material(
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
                      padding: EdgeInsets.all(width * 0.04),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // Icon with gradient background
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
                          SizedBox(
                            height: height * 0.045,
                            child: Text(
                              module['title'],
                              style: TextStyle(
                                fontSize: width * 0.036,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onBackground,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          
                          SizedBox(height: height * 0.005),
                          
                          // Module Subtitle
                          SizedBox(
                            height: height * 0.02,
                            child: Text(
                              module['subtitle'],
                              style: TextStyle(
                                fontSize: width * 0.03,
                                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          
                          Spacer(),
                          
                          // Access indicator
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              vertical: height * 0.005,
                            ),
                            decoration: BoxDecoration(
                              color: moduleColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(width * 0.015),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: width * 0.03,
                                  color: moduleColor,
                                ),
                                SizedBox(width: width * 0.01),
                                Text(
                                  'Tap to access',
                                  style: TextStyle(
                                    fontSize: width * 0.025,
                                    color: moduleColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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

  void _handleModuleTap(String type, BuildContext context) {
    switch (type) {
      case 'Leave_Request':
        Navigator.pushNamed(context, '/leaveRequest');
        break;
      case 'Leave_requestDetail':
        Navigator.pushNamed(context, '/leaveRequestDetail');
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
      case 'Regularization_Listing':
        Navigator.pushNamed(context, '/regularizationListing');
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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: _isDarkMode ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: _isDarkMode ? Colors.black : Colors.white,
        systemNavigationBarIconBrightness: _isDarkMode ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _isDarkMode ? Colors.grey[900] : const Color(0xFFF8FAFD),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.primary,
                ),
              )
            : SafeArea(
              minimum: EdgeInsets.zero,
                child: Container(
                  color: _isDarkMode ? Colors.grey[900] : const Color(0xFFF8FAFD),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        // Header section with background color
                        Container(
                          color: _isDarkMode ? Colors.grey[900] : const Color(0xFFF8FAFD),
                          child: _buildDashboardHeader(context, width, height),
                        ),
                        
                        // Main content with background color
                        Container(
                          color: _isDarkMode ? Colors.grey[900] : const Color(0xFFF8FAFD),
                          child: Column(
                            children: [
                              // Banner Slider
                              _buildBannerSlider(width, height),
                              
                              // Modules Grid
                              _buildModuleGrid(width, height, context),
                              
                              // Footer
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                  vertical: height * 0.015,
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
                                          'Secure',
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
                                          Icons.update,
                                          size: width * 0.04,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                        SizedBox(width: width * 0.015),
                                        Text(
                                          '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
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
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}