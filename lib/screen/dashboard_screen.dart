// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:management_app/providers/profile_provider.dart';
import 'package:provider/provider.dart';

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
      'subtitle': 'Manage your request',
      'image': 'assets/images/leaverequest.png',
      'type': 'Leave_Request',
    },
    {
      'title': 'Leave Request Detail',
      'subtitle': 'about leave..',
      'image': 'assets/images/leaverequestdetail.png',
      'type': 'Leave_requestDetail',
    },
    {
      'title': 'Leave Approval',
      'subtitle': 'your approved leave..',
      'image': 'assets/images/leaveapproved.png',
      'type': 'Leave_Approval',
    },
    {
      'title': 'Attendance Request',
      'subtitle': 'your logs..',
      'image': 'assets/images/attendanceicon.png',
      'type': 'Attendance_request',
    },
    {
      'title': 'Travel Request',
      'subtitle': 'manage your request',
      'image': 'assets/images/travel.png',
      'type': 'Travel_request',
    },
    {
      'title': 'Regularization Listing',     
      'subtitle': 'Reg..list',
      'image': 'assets/images/regularizationlisting.png',
      'type': 'Regularization_Listing',
    },
    {
      'title': 'More',
      'subtitle': 'check more info..',
      'image': 'assets/images/more.png',
      'type': 'Check_More',
    },
  ];

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
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
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, 
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: theme.appBarTheme.elevation ?? 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, "/settingScreen");
              },
              child: Consumer<ProfileProvider>(
                builder: (context, provider, child) {
                  final user = provider.profileData;
                  return CircleAvatar(
                    radius: w * 0.055,
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
            Row(
              children: [
                Image.asset("assets/images/app_icon.png", width: w * 0.10),
                SizedBox(width: w * 0.015),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "PIONEER\n",
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontSize: w * 0.045,
                        ),
                      ),
                      TextSpan(
                        text: "TECH",
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontSize: w * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: () {
                Navigator.pushNamed(context, "/notificationScreen");
              },
              child: Padding(
                padding: EdgeInsets.all(w * 0.02),
                child: Icon(
                  Icons.notifications_none,
                  size: w * 0.08,
                  color: theme.iconTheme.color,
                ),
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.primary,
              ),
            )
          : SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: h * 0.015),
                    Container(
                      width: w * 0.95,
                      height: h * 0.20,
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(w * 0.06),
                        color: theme.cardColor,
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 1500),
                        child: Image.asset(
                          bannerImages[currentIndex],
                          key: ValueKey(currentIndex),
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),
                    SizedBox(height: h * 0.025),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Modules",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: w * 0.05,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: h * 0.010),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: w * 0.01),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: modules.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.85, // Original ratio
                          crossAxisSpacing: w * 0.03,
                          mainAxisSpacing: w * 0.03,
                        ),
                        itemBuilder: (context, index) {
                          final module = modules[index];
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(w * 0.04),
                              onTap: () {
                                switch (module['type']) {
                                  case 'Leave_Request':
                                    Navigator.pushNamed(context, '/leaveRequest');
                                    break;
                                  case 'Leave_requestDetail':
                                    Navigator.pushNamed(
                                        context, '/leaveRequestDetail');
                                    break;
                                  case 'Leave_Approval':
                                    Navigator.pushNamed(context, '/leaveApprovalScreen');
                                    break;
                                  case 'Attendance_request':
                                    Navigator.pushNamed(
                                        context, '/attendanceRequest');
                                    break;
                                  case 'Travel_request':
                                    Navigator.pushNamed(context, '/travelRequest');
                                    break;
                                  case 'Regularization_Listing':
                                    Navigator.pushNamed(
                                        context, '/regularizationListing');
                                    break;
                                  case 'Check_More':
                                    Navigator.pushNamed(context, '/checkMore');
                                    break;
                                  default:
                                    debugPrint(
                                        'No route defined for ${module['type']}');
                                }
                              },
                              child: Container(
                                margin: EdgeInsets.all(w * 0.01),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(w * 0.04),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      theme.colorScheme.primary.withOpacity(0.05),
                                      theme.colorScheme.primary.withOpacity(0.02),
                                      theme.cardColor,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      blurRadius: 5,
                                      spreadRadius: 1,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(w * 0.04),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: w * 0.14,
                                        height: w * 0.14,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(w * 0.03),
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              theme.colorScheme.primary.withOpacity(0.2),
                                              theme.colorScheme.primary.withOpacity(0.1),
                                            ],
                                          ),
                                        ),
                                        child: Center(
                                          child: Image.asset(
                                            module['image'],
                                            height: h * 0.035,
                                            width: w * 0.08,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                      
                                      SizedBox(height: h * 0.015),
                                      
                                      SizedBox(
                                        height: h * 0.045, 
                                        child: Text(
                                          module['title'],
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            fontSize: w * 0.036,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      
                                      SizedBox(height: h * 0.005),
                                      
                                      // Subtitle with fixed height
                                      SizedBox(
                                        height: h * 0.025, // Fixed height for subtitle
                                        child: Text(
                                          module['subtitle'],
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            fontSize: w * 0.028,
                                            color: theme.textTheme.bodySmall?.color
                                                ?.withOpacity(0.7),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
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
                    ),
                  ],
                ),
              ),
            );
  }
}