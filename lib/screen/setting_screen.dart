import 'package:flutter/material.dart';
import 'package:management_app/providers/profile_provider.dart';
import 'package:management_app/screen/about_us_screen.dart';
import 'package:management_app/screen/change_password_screen.dart';
import 'package:management_app/screen/feedback_screen.dart';
import 'package:management_app/screen/help_support_screen.dart';
import 'package:management_app/screen/privacy_policy_screen.dart';
import 'package:management_app/screen/profilescreen.dart';
import 'package:management_app/screen/reports_screen.dart';
import 'package:management_app/services/auth_service.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    
    
    double responsiveFontSize(double baseSize) {
      return baseSize * (screenWidth / 375); 
    }
    
    double responsiveHeight(double percentage) {
      return screenHeight * percentage;
    }
    
    double responsiveWidth(double percentage) {
      return screenWidth * percentage;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(responsiveWidth(0.053)), // 20 for 375 width
            child: Column(
              children: [
                Consumer<ProfileProvider>(
                  builder: (context, provider, child) {
                    final user = provider.profileData;

                    return Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const Profilescreen(),
                              ),
                            );
                          },
                          child: Hero(
                            tag: 'profile-hero',
                            child: CircleAvatar(
                              radius: responsiveWidth(0.067),
                              backgroundImage:
                                  (user != null &&
                                      user['user_image'] != null &&
                                      user['user_image'] != "")
                                  ? NetworkImage(
                                      "https://ppecon.erpnext.com${user['user_image']}",
                                    )
                                  : const AssetImage(
                                          "assets/images/app_icon.png",
                                        )
                                        as ImageProvider,
                            ),
                          ),
                        ),

                        SizedBox(width: responsiveWidth(0.032)),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user != null && user['full_name'] != null
                                  ? user['full_name']
                                  : "Loading...",
                              style: TextStyle(
                                fontSize: responsiveFontSize(18),
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            Text(
                              user != null && user['email'] != null
                                  ? user['email']
                                  : "",
                              style: TextStyle(
                                fontSize: responsiveFontSize(14),
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),

                SizedBox(height: responsiveHeight(0.015)), 
                const Divider(thickness: 1),

                buildMenuItem(
                  context,
                  Icons.privacy_tip_outlined,
                  "Privacy Policy",
                  const PrivacyPolicyScreen(),
                  screenWidth: screenWidth,
                ),

                buildMenuItem(
                  context,
                  Icons.info_outline,
                  "About us",
                  const AboutUsScreen(),
                  screenWidth: screenWidth,
                ),

                buildMenuItem(
                  context,
                  Icons.show_chart_outlined,
                  "Reports",
                  const ReportsScreen(),
                  screenWidth: screenWidth,
                ),

                buildMenuItem(
                  context,
                  Icons.help_outline,
                  "Help & Support",
                  const HelpSupportScreen(),
                  screenWidth: screenWidth,
                ),

                buildMenuItem(
                  context,
                  Icons.feedback_outlined,
                  "Feedback",
                  const FeedbackScreen(),
                  screenWidth: screenWidth,
                ),

                buildMenuItem(
                  context,
                  Icons.lock_outline,
                  "Change Password",
                  const ChangePasswordScreen(),
                  screenWidth: screenWidth,
                ),

                SizedBox(height: responsiveHeight(0.024)), 

                ListTile(
                  leading: Icon(
                    Icons.logout, 
                    color: Colors.red.shade400,
                    size: responsiveFontSize(28),
                  ),
                  title: Text(
                    "Logout",
                    style: TextStyle(
                      color: Colors.red.shade400,
                      fontSize: responsiveFontSize(18),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () async {
                    bool? confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              responsiveWidth(0.043)
                            ),
                          ),
                          title: Text(
                            "Confirm Logout",
                            style: TextStyle(
                              fontSize: responsiveFontSize(18),
                            ),
                          ),
                          content: Text(
                            "Are you sure you want to logout?",
                            style: TextStyle(
                              fontSize: responsiveFontSize(14),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                  fontSize: responsiveFontSize(14),
                                ),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    responsiveWidth(0.027)
                                  ),
                                ),
                              ),
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(
                                "Logout",
                                style: TextStyle(
                                  fontSize: responsiveFontSize(14),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );

                    if (confirm != true) return;

                    showGeneralDialog(
                      context: context,
                      barrierDismissible: false,
                      barrierLabel: "logout",
                      barrierColor: Colors.black.withAlpha(150),
                      transitionDuration: const Duration(milliseconds: 250),
                      pageBuilder: (_, __, ___) {
                        return Center(
                          child: Material(
                            color: Colors.transparent,
                            child: Container(
                              width: screenWidth * 0.85,
                              padding: EdgeInsets.symmetric(
                                vertical: responsiveHeight(0.034),
                                horizontal: responsiveWidth(0.064),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                  responsiveWidth(0.058)
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    height: responsiveHeight(0.027),
                                    width: responsiveHeight(0.027),
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(height: responsiveHeight(0.019)),
                                  Text(
                                    "Logging you out...",
                                    style: TextStyle(
                                      fontSize: responsiveFontSize(14),
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      transitionBuilder: (_, anim, __, child) {
                        return FadeTransition(
                          opacity: anim,
                          child: ScaleTransition(
                            scale: Tween(begin: 0.9, end: 1.0).animate(anim),
                            child: child,
                          ),
                        );
                      },
                    );

                    final auth = AuthService();
                    final result = await auth.logoutUser();

                    Navigator.pop(context);

                    showGeneralDialog(
                      context: context,
                      barrierDismissible: false,
                      barrierLabel: "logout-result",
                      barrierColor: Colors.black.withAlpha(150),
                      transitionDuration: const Duration(milliseconds: 250),
                      pageBuilder: (_, __, ___) {
                        Future.delayed(const Duration(milliseconds: 900), () {
                          if (result["success"]) {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              "/loginScreen",
                              (route) => false,
                            );
                          } else {
                            Navigator.pop(context);
                          }
                        });

                        return Center(
                          child: Material(
                            color: Colors.transparent,
                            child: Container(
                              width: screenWidth * 0.85,
                              padding: EdgeInsets.symmetric(
                                vertical: responsiveHeight(0.034),
                                horizontal: responsiveWidth(0.064),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                  responsiveWidth(0.058)
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    height: responsiveHeight(0.078),
                                    width: responsiveHeight(0.078),
                                    decoration: BoxDecoration(
                                      color:
                                          (result["success"]
                                                  ? Colors.green
                                                  : Colors.red)
                                              .withAlpha(30),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      result["success"]
                                          ? Icons.logout_rounded
                                          : Icons.error_rounded,
                                      color: result["success"]
                                          ? Colors.green
                                          : Colors.red,
                                      size: responsiveFontSize(40),
                                    ),
                                  ),
                                  SizedBox(height: responsiveHeight(0.022)),
                                  Text(
                                    result["success"]
                                        ? "Logged out"
                                        : "Logout failed",
                                    style: TextStyle(
                                      fontSize: responsiveFontSize(18),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: responsiveHeight(0.01)),
                                  Text(
                                    result["message"] ?? "",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: responsiveFontSize(14),
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      transitionBuilder: (_, anim, __, child) {
                        return FadeTransition(
                          opacity: anim,
                          child: ScaleTransition(
                            scale: Tween(begin: 0.9, end: 1.0).animate(anim),
                            child: child,
                          ),
                        );
                      },
                    );
                  },
                ),

                SizedBox(height: responsiveHeight(0.05)), // 40 for 375 height
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    Widget page, {
    required double screenWidth,
  }) {
    double responsiveFontSize(double baseSize) {
      return baseSize * (screenWidth / 375);
    }

    return ListTile(
      leading: Icon(
        icon, 
        size: responsiveFontSize(28), 
        color: Colors.black87
      ),
      title: Text(
        title, 
        style: TextStyle(
          fontSize: responsiveFontSize(18)
        )
      ),
      trailing: Icon(
        Icons.arrow_forward_ios, 
        size: responsiveFontSize(18)
      ),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
    );
  }
}