import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:management_app/providers/employee_provider.dart';
import 'package:management_app/providers/profile_provider.dart';
import 'package:provider/provider.dart';

class HomemainScreen extends StatefulWidget {
  const HomemainScreen({super.key});

  @override
  State<HomemainScreen> createState() => _HomemainScreenState();
}

class _HomemainScreenState extends State<HomemainScreen> {
  String _currentTime = '';
  String _currentDate = '';
  Timer? _timer; 

  @override
  void initState() {
    super.initState();

    _updateTime();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      _updateTime();
    });

    Future.microtask(() async {
      try {
        await Provider.of<ProfileProvider>(
          context,
          listen: false,
        ).loadProfile();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }

      await Provider.of<EmployeeProvider>(
        context,
        listen: false,
      ).loadEmployeeIdFromLocal();
    });
  }

  void _updateTime() {
    if (!mounted) return;

    final now = DateTime.now();
    setState(() {
      _currentTime = DateFormat('hh:mm a').format(now);
      _currentDate = DateFormat('MMM dd, yyyy • EEEE').format(now);
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.04),

            /// 🔹 PROFILE
            Consumer<ProfileProvider>(
              builder: (context, provider, child) {
                final user = provider.profileData;

                return Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage:
                          (user != null &&
                                  user['user_image'] != null &&
                                  user['user_image'] != "")
                              ? NetworkImage(
                                  "https://ppecon.erpnext.com${user['user_image']}",
                                )
                              : const AssetImage(
                                      "assets/images/app_icon.png")
                                  as ImageProvider,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?['full_name'] ?? "Loading...",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          user?['email'] ?? "",
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

            SizedBox(height: screenHeight * 0.07),

            /// 🔹 TIME
            Text(
              _currentTime,
              style: const TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              _currentDate,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),

            SizedBox(height: screenHeight * 0.08),

            /// 🔹 PUNCH BUTTON
            GestureDetector(
              onTap: () {
                debugPrint("Punch button pressed");
              },
              child: Container(
                width: screenWidth * 0.45,
                height: screenWidth * 0.45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.grey.shade200, Colors.grey.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 20,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.fingerprint,
                      size: 55,
                      color: Colors.red.shade600,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "PUNCH IN",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: screenHeight * 0.08),

            /// 🔹 INFO
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _smallInfo(Icons.login, "00:00 AM", "Punch In"),
                _smallInfo(Icons.logout, "00:00 PM", "Punch Out"),
                _smallInfo(Icons.av_timer, "00:00", "Total Hours"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallInfo(IconData icon, String time, String label) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Colors.red.shade600),
        const SizedBox(height: 4),
        Text(time, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }
}
