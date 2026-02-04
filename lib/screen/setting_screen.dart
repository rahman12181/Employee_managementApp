// ignore_for_file: deprecated_member_use

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
  String selectedLanguage = "English";
  String selectedTheme = "Light";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Color scheme
    final backgroundColor = isDarkMode ? Colors.grey[900]! : Colors.grey[50]!;
    final textColor = isDarkMode ? Colors.white : Colors.grey[900]!;
    final subtitleColor = isDarkMode ? Colors.grey[400]! : Colors.grey[700]!;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Consumer<ProfileProvider>(
          builder: (context, provider, _) {
            final user = provider.profileData;

            return Column(
              children: [
                // Modern Header
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.02,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDarkMode
                          ? [
                              Colors.grey[850]!,
                              Colors.grey[900]!,
                            ]
                          : [
                              Colors.blue.shade50,
                              Colors.purple.shade50,
                            ],
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: isDarkMode
                            ? Colors.grey[700]!
                            : Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: textColor,
                          size: screenWidth * 0.05,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Expanded(
                        child: Text(
                          "Settings",
                          style: TextStyle(
                            fontSize: screenWidth * 0.055,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.red.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.logout_rounded,
                            color: Colors.red,
                            size: screenWidth * 0.05,
                          ),
                          onPressed: () => _showLogoutDialog(context),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.045,
                      vertical: screenHeight * 0.025,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Section
                        _buildProfileSection(
                          context,
                          user,
                          screenWidth,
                          screenHeight,
                          isDarkMode,
                          textColor,
                          subtitleColor,
                        ),

                        SizedBox(height: screenHeight * 0.03),

                        // Account Settings
                        _buildSectionTitle("Account Settings", screenWidth, textColor),
                        SizedBox(height: screenHeight * 0.015),

                        _buildSettingTile(
                          context: context,
                          icon: Icons.person_outline_rounded,
                          title: "User Profile",
                          subtitle: "View and edit your profile",
                          iconColor: Colors.blue,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const Profilescreen(),
                              ),
                            );
                          },
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                          isDarkMode: isDarkMode,
                          textColor: textColor,
                          subtitleColor: subtitleColor,
                        ),

                        _buildSettingTile(
                          context: context,
                          icon: Icons.lock_outline_rounded,
                          title: "Change Password",
                          subtitle: "Update your password",
                          iconColor: Colors.purple,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ChangePasswordScreen(),
                              ),
                            );
                          },
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                          isDarkMode: isDarkMode,
                          textColor: textColor,
                          subtitleColor: subtitleColor,
                        ),

                        _buildSettingTile(
                          context: context,
                          icon: Icons.email_outlined,
                          title: "Notification Email",
                          subtitle: user?['email'] ?? "Not set",
                          iconColor: Colors.orange,
                          onTap: () {},
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                          isDarkMode: isDarkMode,
                          textColor: textColor,
                          subtitleColor: subtitleColor,
                        ),

                        SizedBox(height: screenHeight * 0.03),

                        // App Settings
                        _buildSectionTitle("App Settings", screenWidth, textColor),
                        SizedBox(height: screenHeight * 0.015),

                        _buildToggleTile(
                          icon: Icons.mic_none_outlined,
                          title: "Voice Recognition",
                          subtitle: "Enable voice commands",
                          value: voiceEnabled,
                          iconColor: Colors.green,
                          onChanged: (value) {
                            setState(() => voiceEnabled = value);
                          },
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                          isDarkMode: isDarkMode,
                          textColor: textColor,
                          subtitleColor: subtitleColor,
                        ),

                        _buildDropdownTile(
                          icon: Icons.language_rounded,
                          title: "Language",
                          value: selectedLanguage,
                          options: const ["English", "Arabic", "Hindi", "Spanish"],
                          iconColor: Colors.blue,
                          onChanged: (value) {
                            setState(() => selectedLanguage = value!);
                          },
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                          isDarkMode: isDarkMode,
                          textColor: textColor,
                          subtitleColor: subtitleColor,
                        ),

                        _buildDropdownTile(
                          icon: Icons.brightness_6_outlined,
                          title: "Theme",
                          value: selectedTheme,
                          options: const ["Light", "Dark", "System"],
                          iconColor: Colors.amber,
                          onChanged: (value) {
                            setState(() => selectedTheme = value!);
                          },
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                          isDarkMode: isDarkMode,
                          textColor: textColor,
                          subtitleColor: subtitleColor,
                        ),

                        _buildToggleTile(
                          icon: Icons.face_retouching_natural,
                          title: "Face ID Login",
                          subtitle: "Biometric authentication",
                          value: faceIdEnabled,
                          iconColor: Colors.pink,
                          onChanged: (value) {
                            setState(() => faceIdEnabled = value);
                          },
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                          isDarkMode: isDarkMode,
                          textColor: textColor,
                          subtitleColor: subtitleColor,
                        ),

                        SizedBox(height: screenHeight * 0.05),

                        // App Info
                        Center(
                          child: Column(
                            children: [
                              Text(
                                "Version 1.0.0",
                                style: TextStyle(
                                  fontSize: screenWidth * 0.032,
                                  color: subtitleColor,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.005),
                              Text(
                                "© 2024 Management App",
                                style: TextStyle(
                                  fontSize: screenWidth * 0.03,
                                  color: subtitleColor.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.02),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileSection(
    BuildContext context,
    Map<String, dynamic>? user,
    double screenWidth,
    double screenHeight,
    bool isDarkMode,
    Color textColor,
    Color subtitleColor,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const Profilescreen(),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.04),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[800]! : Colors.white,
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: screenWidth * 0.18,
              height: screenWidth * 0.18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.blue.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                backgroundColor: Colors.blue.shade50,
                backgroundImage: (user != null &&
                        user['user_image'] != null &&
                        user['user_image'] != "")
                    ? NetworkImage(
                        "https://ppecon.erpnext.com${user['user_image']}",
                      )
                    : const AssetImage("assets/images/app_icon.png")
                        as ImageProvider,
              ),
            ),
            SizedBox(width: screenWidth * 0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?['full_name'] ?? "Loading...",
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  Text(
                    user?['email'] ?? "",
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: subtitleColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.03,
                      vertical: screenHeight * 0.005,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          color: Colors.blue,
                          size: screenWidth * 0.035,
                        ),
                        SizedBox(width: screenWidth * 0.01),
                        Text(
                          "Verified Account",
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: subtitleColor,
              size: screenWidth * 0.04,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, double screenWidth, Color textColor) {
    return Text(
      title,
      style: TextStyle(
        fontSize: screenWidth * 0.04,
        fontWeight: FontWeight.w700,
        color: textColor,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSettingTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    required Color iconColor,
    required VoidCallback? onTap,
    required double screenWidth,
    required double screenHeight,
    required bool isDarkMode,
    required Color textColor,
    required Color subtitleColor,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.01),
      child: Material(
        color: isDarkMode ? Colors.grey[800]! : Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenHeight * 0.018,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(screenWidth * 0.03),
              border: Border.all(
                color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.025),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: screenWidth * 0.05,
                  ),
                ),
                SizedBox(width: screenWidth * 0.04),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: screenHeight * 0.003),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: screenWidth * 0.032,
                            color: subtitleColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: subtitleColor,
                  size: screenWidth * 0.04,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required Color iconColor,
    required ValueChanged<bool> onChanged,
    required double screenWidth,
    required double screenHeight,
    required bool isDarkMode,
    required Color textColor,
    required Color subtitleColor,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.01),
      child: Material(
        color: isDarkMode ? Colors.grey[800]! : Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenHeight * 0.018,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(screenWidth * 0.03),
            border: Border.all(
              color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(screenWidth * 0.025),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: screenWidth * 0.05,
                ),
              ),
              SizedBox(width: screenWidth * 0.04),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: screenHeight * 0.003),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: screenWidth * 0.032,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Switch.adaptive(
                value: value,
                onChanged: onChanged,
                activeColor: iconColor,
                activeTrackColor: iconColor.withOpacity(0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String value,
    required List<String> options,
    required Color iconColor,
    required ValueChanged<String?> onChanged,
    required double screenWidth,
    required double screenHeight,
    required bool isDarkMode,
    required Color textColor,
    required Color subtitleColor,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.01),
      child: Material(
        color: isDarkMode ? Colors.grey[800]! : Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenHeight * 0.018,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(screenWidth * 0.03),
            border: Border.all(
              color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(screenWidth * 0.025),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: screenWidth * 0.05,
                ),
              ),
              SizedBox(width: screenWidth * 0.04),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.003),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: screenWidth * 0.032,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: onChanged,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                ),
                itemBuilder: (BuildContext context) {
                  return options.map((String option) {
                    return PopupMenuItem<String>(
                      value: option,
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: screenWidth * 0.038,
                          color: textColor,
                        ),
                      ),
                    );
                  }).toList();
                },
                child: Container(
                  padding: EdgeInsets.all(screenWidth * 0.015),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: screenWidth * 0.032,
                          color: subtitleColor,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.01),
                      Icon(
                        Icons.arrow_drop_down_rounded,
                        color: subtitleColor,
                        size: screenWidth * 0.045,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
        ),
        backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
        title: Row(
          children: [
            Icon(
              Icons.logout_rounded,
              color: Colors.red,
              size: screenWidth * 0.06,
            ),
            SizedBox(width: screenWidth * 0.03),
            Text(
              "Logout",
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.w700,
                color: isDarkMode ? Colors.white : Colors.grey[900],
              ),
            ),
          ],
        ),
        content: Text(
          "Are you sure you want to logout from your account?",
          style: TextStyle(
            fontSize: screenWidth * 0.038,
            color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: isDarkMode ? Colors.grey[300] : Colors.grey[700],
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenWidth * 0.025,
              ),
            ),
            child: Text(
              "Cancel",
              style: TextStyle(fontSize: screenWidth * 0.038),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performLogout(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenWidth * 0.025,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.03),
              ),
            ),
            child: Text(
              "Logout",
              style: TextStyle(fontSize: screenWidth * 0.038),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout(BuildContext context) async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: EdgeInsets.all(screenWidth * 0.05),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[800]! : Colors.white,
            borderRadius: BorderRadius.circular(screenWidth * 0.04),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: Colors.blue,
                strokeWidth: 3,
              ),
              SizedBox(height: screenWidth * 0.04),
              Text(
                "Logging out...",
                style: TextStyle(
                  fontSize: screenWidth * 0.038,
                  color: isDarkMode ? Colors.white : Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final auth = AuthService();
    final result = await auth.logoutUser();

    Navigator.pop(context); // Close loading dialog

    // Show result dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pop(context);
          if (result["success"] == true) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              "/loginScreen",
              (route) => false,
            );
          }
        });

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.04),
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
              SizedBox(height: screenWidth * 0.04),
              Text(
                result["success"] ? "Logged Out!" : "Logout Failed",
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? Colors.white : Colors.grey[900],
                ),
              ),
              SizedBox(height: screenWidth * 0.02),
              Text(
                result["message"] ?? "",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}