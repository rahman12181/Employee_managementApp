import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:management_app/providers/profile_provider.dart';
import 'package:management_app/screen/change_password_screen.dart';
import 'package:management_app/screen/profilescreen.dart';
import 'package:management_app/services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool voiceEnabled = false;
  bool faceIdEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<ProfileProvider>(
          builder: (context, provider, _) {
            final user = provider.profileData;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
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
                        onPressed: () => _logout(context),
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
                    child: CircleAvatar(
                      radius: 45,
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
                  ),

                  const SizedBox(height: 12),
                  Text(
                    user?['full_name'] ?? "Loading...",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 24),
                  _box(
                    _row(
                      icon: Icons.send_outlined,
                      title: "User Name",
                      subtitle: user?['email'] ?? "",
                    ),
                  ),

                  _box(
                    _row(
                      icon: Icons.lock_outline,
                      title: "Change Password",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ChangePasswordScreen(),
                          ),
                        );
                      },
                    ),
                  ),

                  _box(
                    _row(
                      icon: Icons.email_outlined,
                      title: "Notification E-Mail",
                      subtitle: user?['email'] ?? "",
                    ),
                  ),

                  _box(
                    _switchRow(
                      icon: Icons.mic_none,
                      title: "Activate voice recognition",
                      value: voiceEnabled,
                      onChanged: (v) {
                        setState(() => voiceEnabled = v);
                      },
                    ),
                  ),

                  _box(
                    _dropdownRow(
                      icon: Icons.translate,
                      title: "Languages",
                      value: "English",
                    ),
                  ),

                  _box(
                    _dropdownRow(
                      icon: Icons.dark_mode_outlined,
                      title: "Theme",
                      value: "Light",
                    ),
                  ),

                  _box(
                    _switchRow(
                      icon: Icons.face_retouching_natural,
                      title: "Login by Face ID",
                      subtitle: faceIdEnabled ? "Enable" : "Disable",
                      value: faceIdEnabled,
                      onChanged: (v) {
                        setState(() => faceIdEnabled = v);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final auth = AuthService();
    final result = await auth.logoutUser();

    Navigator.pop(context);

    showDialog(
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
              Icon(
                result["success"] ? Icons.check_circle : Icons.error,
                size: 48,
                color: result["success"] ? Colors.green : Colors.red,
              ),
              const SizedBox(height: 12),
              Text(
                result["success"] ? "Logged out" : "Logout failed",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
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

  Widget _box(Widget child) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95, 
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.lightBlue.shade100,
            width: 1, // 
          ),
        ),
        child: child,
      ),
    );
  }

  Widget _row({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: _icon(icon),
      title: Text(title),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(color: Colors.grey))
          : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _switchRow({
    required IconData icon,
    required String title,
    required bool value,
    String? subtitle,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: _icon(icon),
      title: Text(title),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(color: Colors.grey))
          : null,
      value: value,
      onChanged: onChanged,
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
