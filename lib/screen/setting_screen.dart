import 'package:flutter/material.dart';
import 'package:management_app/screen/about_us_screen.dart';
import 'package:management_app/screen/change_password_screen.dart';
import 'package:management_app/screen/feedback_screen.dart';
import 'package:management_app/screen/help_support_screen.dart';
import 'package:management_app/screen/privacy_policy_screen.dart';
import 'package:management_app/screen/profile_screen.dart';
import 'package:management_app/screen/reports_screen.dart';
import 'package:management_app/services/auth_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      backgroundColor: Colors.white,

      body:SafeArea(
        child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            ListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey.shade300,
                child: Image(image: AssetImage("assets/images/app_icon.png"))
              ),
              title: const Text(
                "Username",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              subtitle: const Text(
                "useremail.ppecon.com",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),

              trailing: const Icon(Icons.arrow_forward_ios, size: 18),

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
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
               /* showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    return AlertDialog(
                      content: Row(
                        children: const [
                          CircularProgressIndicator(),
                          SizedBox(width: 20),
                          Text("Logging out..."),
                        ],
                      ),
                    );
                  },
                );*/

                final auth = AuthService();
                final result = await auth.logoutUser();

                Navigator.of(context).pop();
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    Future.delayed(const Duration(seconds: 1), () {
                      Navigator.of(context).pop();
                      if (result["success"]) {
                        Navigator.pushNamedAndRemoveUntil(context,"/login",
                        (route) => false);
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
      )

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
