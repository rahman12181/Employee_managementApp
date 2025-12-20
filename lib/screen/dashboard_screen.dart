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
    'assets/images/banner1.png',
    'assets/images/banner2.png',
    'assets/images/banner3.png',
    'assets/images/banner4.png',
    'assets/images/banner5.png',
    'assets/images/banner6.png',
    'assets/images/banner7.png',
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
      'subtitle': 'Admin..',
      'image': 'assets/images/leaveapproved.png',
      'type': 'Leave_Approval',
    },
    {
      'title': 'Attendance Regularization',
      'subtitle': 'your logs..',
      'image': 'assets/images/attendanceicon.png',
      'type': 'Attendance_Redularization',
    },
    {
      'title': 'Regularization Approval',
      'subtitle': 'Check your Approval',
      'image': 'assets/images/regapproval.png',
      'type': 'Regularization_Approval',
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

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
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
                            : const AssetImage(
                                "assets/images/app_icon.png",
                              ) as ImageProvider,
                  );
                },
              ),
            ),
            Row(
              children: [
                Image.asset(
                  "assets/images/app_icon.png",
                  width: w * 0.10,
                ),
                SizedBox(width: w * 0.015),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "PIONEER\n",
                        style: TextStyle(
                          height: 1,
                          fontSize: w * 0.045,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: "TECH",
                        style: TextStyle(
                          height: 1,
                          fontSize: w * 0.045,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
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
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : SingleChildScrollView(
              child: SafeArea(
                child: Column(
                  children: [
                    SizedBox(height: h * 0.015),
                    Container(
                      width: w * 0.90,
                      height: h * 0.20,
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(w * 0.06),
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
                      padding: EdgeInsets.symmetric(horizontal: w * 0.03),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: modules.length,
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.9,
                          crossAxisSpacing: w * 0.03,
                          mainAxisSpacing: w * 0.03,
                        ),
                        itemBuilder: (context, index) {
                          final module = modules[index];
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(w * 0.04),
                            ),
                            elevation: 3,
                            child: Padding(
                              padding: EdgeInsets.all(w * 0.03),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    module['image'],
                                    height: h * 0.06,
                                  ),
                                  SizedBox(height: h * 0.01),
                                  Text(
                                    module['title'],
                                    style: TextStyle(
                                      fontSize: w * 0.032,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: h * 0.005),
                                  Text(
                                    module['subtitle'],
                                    style: TextStyle(
                                      fontSize: w * 0.025,
                                      color: Colors.grey[600],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
