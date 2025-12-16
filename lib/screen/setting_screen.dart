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
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
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
                                builder: (_) => Profilescreen(),
                              ),
                            );
                          },
                          child: Hero(
                            tag: 'profile-hero',
                            child: CircleAvatar(
                              radius: 25,
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

                        const SizedBox(width: 12),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user != null && user['full_name'] != null
                                  ? user['full_name']
                                  : "Loading...",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            Text(
                              user != null && user['email'] != null
                                  ? user['email']
                                  : "",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),

                const Divider(thickness: 1),

                buildMenuItem(
                  context,
                  Icons.privacy_tip_outlined,
                  "Privacy Policy",
                  const PrivacyPolicyScreen(),
                ),

                buildMenuItem(
                  context,
                  Icons.info_outline,
                  "About us",
                  const AboutUsScreen(),
                ),

                buildMenuItem(
                  context,
                  Icons.show_chart_outlined,
                  "Reports",
                  const ReportsScreen(),
                ),

                buildMenuItem(
                  context,
                  Icons.help_outline,
                  "Help & Support",
                  const HelpSupportScreen(),
                ),

                buildMenuItem(
                  context,
                  Icons.feedback_outlined,
                  "Feedback",
                  const FeedbackScreen(),
                ),

                buildMenuItem(
                  context,
                  Icons.lock_outline,
                  "Change Password",
                  const ChangePasswordScreen(),
                ),

                const SizedBox(height: 20),

                ListTile(
                  leading: Icon(Icons.logout, color: Colors.red.shade400),
                  title: Text(
                    "Logout",
                    style: TextStyle(
                      color: Colors.red.shade400,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () async {
                    bool? confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: const Text("Confirm Logout"),
                          content: const Text(
                            "Are you sure you want to logout?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("Logout"),
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
                              width: MediaQuery.of(context).size.width * 0.85,
                              padding: const EdgeInsets.symmetric(
                                vertical: 28,
                                horizontal: 24,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    "Logging you out...",
                                    style: TextStyle(
                                      fontSize: 14,
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
                              width: MediaQuery.of(context).size.width * 0.85,
                              padding: const EdgeInsets.symmetric(
                                vertical: 28,
                                horizontal: 24,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    height: 64,
                                    width: 64,
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
                                      size: 40,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  Text(
                                    result["success"]
                                        ? "Logged out"
                                        : "Logout failed",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    result["message"] ?? "",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 14,
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

                const SizedBox(height: 40),
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
    Widget page,
  ) {
    return ListTile(
      leading: Icon(icon, size: 28, color: Colors.black87),

      title: Text(title, style: const TextStyle(fontSize: 18)),

      trailing: const Icon(Icons.arrow_forward_ios, size: 18),

      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
    );
  }
}
