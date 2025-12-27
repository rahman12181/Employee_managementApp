import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:management_app/providers/profile_provider.dart';
import 'package:management_app/screen/profilescreen.dart';
import 'package:management_app/services/auth_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    double rf(double size) => size * (screenWidth / 375);

    return Scaffold(
      backgroundColor: const Color(0xffF4F7FA),
      body: SafeArea(
        child: Consumer<ProfileProvider>(
          builder: (context, provider, _) {
            final user = provider.profileData;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 40),
                      const Text(
                        "My Profile",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.red),
                        onPressed: () => _logout(context, rf),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
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
                      tag: "profile-hero",
                      child: CircleAvatar(
                        radius: 45,
                        backgroundImage:
                            (user != null && user['user_image'] != null)
                            ? NetworkImage(
                                "https://ppecon.erpnext.com${user['user_image']}",
                              )
                            : const AssetImage("assets/images/app_icon.png")
                                  as ImageProvider,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  Text(
                    user?['full_name'] ?? "Loading...",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 4),
                  Text(
                    user?['company_name'] ?? "",
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),

                  const SizedBox(height: 24),
                  _card([
                    _row(
                      icon: Icons.send_outlined,
                      title: "User Name",
                      subtitle: user?['email'] ?? "",
                    ),
                    _row(icon: Icons.lock_outline, title: "Change Password"),
                    _row(
                      icon: Icons.email_outlined,
                      title: "Notification E-Mail",
                      subtitle: user?['email'] ?? "",
                    ),
                    _switchRow(
                      icon: Icons.mic_none,
                      title: "Activate voice recognition",
                    ),
                    _dropdownRow(
                      icon: Icons.translate,
                      title: "Languages",
                      value: "English",
                    ),
                    _dropdownRow(
                      icon: Icons.dark_mode_outlined,
                      title: "Theme",
                      value: "Light",
                    ),
                    _switchRow(
                      icon: Icons.face_retouching_natural,
                      title: "Login by Face ID",
                      value: false,
                    ),
                  ]),

                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context, Function rf) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    /// 🔹 LOADING DIALOG
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final auth = AuthService();
    final result = await auth.logoutUser();

    Navigator.pop(context);
    showDialog(
      // ignore: use_build_context_synchronously
      context: context,
      barrierDismissible: false,
      builder: (_) {
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (result["success"] == true) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              "/loginScreen",
              (route) => false,
            );
          } else {
            // ignore: use_build_context_synchronously
            Navigator.pop(context);
          }
        });

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: (result["success"] ? Colors.green : Colors.red)
                    .withAlpha(15),
                child: Icon(
                  result["success"] ? Icons.check_circle : Icons.error,
                  color: result["success"] ? Colors.green : Colors.red,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                result["success"] ? "Logged out" : "Logout failed",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                result["message"] ?? "",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }

  Widget _row({
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    return ListTile(
      leading: _icon(icon),
      title: Text(title),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(color: Colors.grey))
          : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }

  Widget _switchRow({
    required IconData icon,
    required String title,
    bool value = true,
  }) {
    return SwitchListTile(
      secondary: _icon(icon),
      title: Text(title),
      value: value,
      onChanged: (_) {},
    );
  }

  Widget _dropdownRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      leading: _icon(icon),
      title: Text(title),
      subtitle: Text(value, style: const TextStyle(color: Colors.grey)),
      trailing: const Icon(Icons.keyboard_arrow_down),
    );
  }

  Widget _icon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Icon(icon, color: Colors.blue),
    );
  }
}
