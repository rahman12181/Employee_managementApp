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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final padding = MediaQuery.of(context).padding;

    double responsiveFontSize(double baseSize) {
      return baseSize * (screenWidth / 375);
    }

    double responsiveWidth(double percentage) {
      return screenWidth * percentage;
    }

    double responsiveHeight(double percentage) {
      return screenHeight * percentage;
    }

    final backgroundColor = isDarkMode ? Colors.grey[900]! : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subtitleColor = isDarkMode ? Colors.grey[400]! : Colors.grey;
    final borderColor = isDarkMode ? Colors.grey[700]! : Colors.lightBlue.shade100;
    final iconContainerColor = isDarkMode ? Colors.grey[800]! : Colors.blue.shade50;
    final iconColor = isDarkMode ? Colors.blue[300]! : Colors.blue;
    final boxColor = isDarkMode ? Colors.grey[800]! : Colors.white;
    final logoutIconColor = isDarkMode ? Colors.red[300]! : Colors.red;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Consumer<ProfileProvider>(
          builder: (context, provider, _) {
            final user = provider.profileData;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                responsiveWidth(0.04),
                padding.top + responsiveHeight(0.01),
                responsiveWidth(0.04),
                responsiveHeight(0.02),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: responsiveWidth(0.1)),
                      Text(
                        "My Profile",
                        style: TextStyle(
                          fontSize: responsiveFontSize(20),
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.logout, color: logoutIconColor),
                        onPressed: () => _logout(context),
                      ),
                    ],
                  ),

                  SizedBox(height: responsiveHeight(0.02)),
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
                      radius: responsiveWidth(0.12),
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

                  SizedBox(height: responsiveHeight(0.012)),
                  Text(
                    user?['full_name'] ?? "Loading...",
                    style: TextStyle(
                      fontSize: responsiveFontSize(18),
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),

                  SizedBox(height: responsiveHeight(0.024)),
                  _box(
                    context,
                    _row(
                      icon: Icons.send_outlined,
                      title: "User Name",
                      subtitle: user?['email'] ?? "",
                      textColor: textColor,
                      subtitleColor: subtitleColor,
                      iconColor: iconColor,
                      iconContainerColor: iconContainerColor,
                    ),
                    screenWidth: screenWidth,
                    boxColor: boxColor,
                    borderColor: borderColor,
                  ),

                  _box(
                    context,
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
                      textColor: textColor,
                      iconColor: iconColor,
                      iconContainerColor: iconContainerColor,
                    ),
                    screenWidth: screenWidth,
                    boxColor: boxColor,
                    borderColor: borderColor,
                  ),

                  _box(
                    context,
                    _row(
                      icon: Icons.email_outlined,
                      title: "Notification E-Mail",
                      subtitle: user?['email'] ?? "",
                      textColor: textColor,
                      subtitleColor: subtitleColor,
                      iconColor: iconColor,
                      iconContainerColor: iconContainerColor,
                    ),
                    screenWidth: screenWidth,
                    boxColor: boxColor,
                    borderColor: borderColor,
                  ),

                  _box(
                    context,
                    _switchRow(
                      icon: Icons.mic_none,
                      title: "Activate voice recognition",
                      value: voiceEnabled,
                      onChanged: (v) {
                        setState(() => voiceEnabled = v);
                      },
                      textColor: textColor,
                      iconColor: iconColor,
                      iconContainerColor: iconContainerColor,
                    ),
                    screenWidth: screenWidth,
                    boxColor: boxColor,
                    borderColor: borderColor,
                  ),

                  _box(
                    context,
                    _dropdownRow(
                      icon: Icons.translate,
                      title: "Languages",
                      value: "English",
                      textColor: textColor,
                      subtitleColor: subtitleColor,
                      iconColor: iconColor,
                      iconContainerColor: iconContainerColor,
                    ),
                    screenWidth: screenWidth,
                    boxColor: boxColor,
                    borderColor: borderColor,
                  ),

                  _box(
                    context,
                    _dropdownRow(
                      icon: Icons.dark_mode_outlined,
                      title: "Theme",
                      value: "Light",
                      textColor: textColor,
                      subtitleColor: subtitleColor,
                      iconColor: iconColor,
                      iconContainerColor: iconContainerColor,
                    ),
                    screenWidth: screenWidth,
                    boxColor: boxColor,
                    borderColor: borderColor,
                  ),

                  _box(
                    context,
                    _switchRow(
                      icon: Icons.face_retouching_natural,
                      title: "Login by Face ID",
                      subtitle: faceIdEnabled ? "Enable" : "Disable",
                      value: faceIdEnabled,
                      onChanged: (v) {
                        setState(() => faceIdEnabled = v);
                      },
                      textColor: textColor,
                      subtitleColor: subtitleColor,
                      iconColor: iconColor,
                      iconContainerColor: iconContainerColor,
                    ),
                    screenWidth: screenWidth,
                    boxColor: boxColor,
                    borderColor: borderColor,
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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
        title: Text(
          "Confirm Logout",
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        content: Text(
          "Are you sure you want to logout?",
          style: TextStyle(
            color: isDarkMode ? Colors.grey[300] : Colors.black,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              "Cancel",
              style: TextStyle(
                color: isDarkMode ? Colors.blue[300] : Colors.blue,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDarkMode ? Colors.red[700]! : Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Logout",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: CircularProgressIndicator(
          color: isDarkMode ? Colors.blue[300] : Colors.blue,
        ),
      ),
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
          backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                result["success"] ? Icons.check_circle : Icons.error,
                size: screenWidth * 0.12,
                color: result["success"] ? Colors.green : Colors.red,
              ),
              SizedBox(height: screenWidth * 0.03),
              Text(
                result["success"] ? "Logged out" : "Logout failed",
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(height: screenWidth * 0.015),
              Text(
                result["message"] ?? "",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[300] : Colors.grey,
                  fontSize: screenWidth * 0.035,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _box(
    BuildContext context,
    Widget child, {
    required double screenWidth,
    required Color boxColor,
    required Color borderColor,
  }) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: screenWidth * 0.92,
        margin: EdgeInsets.only(bottom: screenWidth * 0.03),
        decoration: BoxDecoration(
          color: boxColor,
          borderRadius: BorderRadius.circular(screenWidth * 0.035),
          border: Border.all(
            color: borderColor,
            width: 1,
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
    required Color textColor,
    Color? subtitleColor,
    required Color iconColor,
    required Color iconContainerColor,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return ListTile(
      leading: _icon(icon, iconColor, iconContainerColor, screenWidth),
      title: Text(
        title,
        style: TextStyle(
          fontSize: screenWidth * 0.04,
          color: textColor,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: subtitleColor,
              ),
            )
          : null,
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: screenWidth * 0.04,
        color: isDarkMode ? Colors.grey[400] : Colors.grey,
      ),
      onTap: onTap,
    );
  }

  Widget _switchRow({
    required IconData icon,
    required String title,
    required bool value,
    String? subtitle,
    required ValueChanged<bool> onChanged,
    required Color textColor,
    Color? subtitleColor,
    required Color iconColor,
    required Color iconContainerColor,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return SwitchListTile(
      secondary: _icon(icon, iconColor, iconContainerColor, screenWidth),
      title: Text(
        title,
        style: TextStyle(
          fontSize: screenWidth * 0.04,
          color: textColor,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: subtitleColor,
              ),
            )
          : null,
      value: value,
      activeColor: isDarkMode ? Colors.blue[300] : Colors.blue,
      onChanged: onChanged,
    );
  }

  Widget _dropdownRow({
    required IconData icon,
    required String title,
    required String value,
    required Color textColor,
    required Color subtitleColor,
    required Color iconColor,
    required Color iconContainerColor,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return ListTile(
      leading: _icon(icon, iconColor, iconContainerColor, screenWidth),
      title: Text(
        title,
        style: TextStyle(
          fontSize: screenWidth * 0.04,
          color: textColor,
        ),
      ),
      subtitle: Text(
        value,
        style: TextStyle(
          fontSize: screenWidth * 0.035,
          color: subtitleColor,
        ),
      ),
      trailing: Icon(
        Icons.keyboard_arrow_down,
        color: isDarkMode ? Colors.grey[400] : Colors.grey,
      ),
    );
  }

  bool get isDarkMode {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark;
  }

  Widget _icon(IconData icon, Color iconColor, Color containerColor, double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.02),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        color: containerColor,
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: screenWidth * 0.05,
      ),
    );
  }
}