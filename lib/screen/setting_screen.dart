import 'package:flutter/material.dart';
import 'package:management_app/screen/about_us_screen.dart';
import 'package:management_app/screen/change_password_screen.dart';
import 'package:management_app/screen/feedback_screen.dart';
import 'package:management_app/screen/help_support_screen.dart';
import 'package:management_app/screen/privacy_policy_screen.dart';
import 'package:management_app/screen/reports_screen.dart';
import 'package:management_app/services/auth_service.dart';
import 'package:management_app/services/profile_provider.dart';
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
                        CircleAvatar(
                          radius: 22,
                          backgroundImage:
                              (user != null &&
                                  user['user_image'] != null &&
                                  user['user_image'] != "")
                              ? NetworkImage(
                                  "https://ppecon.erpnext.com${user['user_image']}",
                                )
                              : const AssetImage("assets/images/app_icon.png")
                                    as ImageProvider,
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
                    bool? confirmLogout = await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Confirm Logout"),
                          content: const Text(
                            "Are you sure you want to logout?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("Logout"),
                            ),
                          ],
                        );
                      },
                    );

                    if (confirmLogout != true) return;

                    final auth = AuthService();
                    final result = await auth.logoutUser();

                    showDialog(
                      context: context,
                      builder: (context) {
                        Future.delayed(Duration(milliseconds: 1200),(){
                          if (result["success"]) {
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    "/loginScreen",(route) => false);
                                }
                        });
                        return AlertDialog(
                          title: Text(result["success"] ? "Success" : "Error"),
                          content: Text(result["message"]),
                          
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
