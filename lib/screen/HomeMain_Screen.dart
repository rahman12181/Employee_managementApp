import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:management_app/providers/employee_provider.dart';
import 'package:management_app/providers/profile_provider.dart';
import 'package:management_app/providers/punch_provider.dart';
import 'package:management_app/services/checkin_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

class HomemainScreen extends StatefulWidget {
  const HomemainScreen({super.key});

  @override
  State<HomemainScreen> createState() => _HomemainScreenState();
}

class _HomemainScreenState extends State<HomemainScreen> {
  String _currentTime = '';
  String _currentDate = '';
  Timer? _timer;
  String _greeting = 'Welcome,'; // Greeting variable
  Timer? _greetingTimer;

  final CheckinService _checkinService = CheckinService();

  bool isPunching = false;
  bool showSuccess = false;
  String successText = "";

  @override
  void initState() {
    super.initState();

    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());

    _greetingTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _greeting = _getTimeBasedGreeting();
        });
      }
    });

    Future.microtask(() async {
      await Provider.of<ProfileProvider>(context, listen: false).loadProfile();
      await Provider.of<EmployeeProvider>(
        context,
        listen: false,
      ).loadEmployeeIdFromLocal();
      await Provider.of<PunchProvider>(
        context,
        listen: false,
      ).loadDailyPunches();
    });
  }

  String _getTimeBasedGreeting() {
    final saudiTime = DateTime.now().toUtc().add(const Duration(hours: 3));
    final hour = saudiTime.hour;

    if (hour >= 5 && hour < 12) {
      return 'Good Morning,';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon,';
    } else if (hour >= 17 && hour < 21) {
      return 'Good Evening,';
    } else {
      return 'Good Night,';
    }
  }

  void _updateTime() {
    final now = DateTime.now();
    if (!mounted) return;
    setState(() {
      _currentTime = DateFormat('hh:mm a').format(now);
      _currentDate = DateFormat('MMM dd, yyyy • EEEE').format(now);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _greetingTimer?.cancel();
    super.dispose();
  }

  String punchText(PunchProvider punchProvider) {
    if (punchProvider.punchInTime == null) return "PUNCH IN";
    if (punchProvider.punchOutTime == null) return "PUNCH OUT";
    return "DONE";
  }

  Future<void> onPunchTap() async {
    final employeeId = Provider.of<EmployeeProvider>(
      context,
      listen: false,
    ).employeeId;
    final punchProvider = Provider.of<PunchProvider>(context, listen: false);

    if (employeeId == null || isPunching) return;

    String logType = punchProvider.punchInTime == null ? "IN" : "OUT";

    if (logType == "IN" && punchProvider.punchInTime != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade300, width: 1),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: Colors.orange.shade800,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "You have already checked in today!",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.orange.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    if (logType == "OUT" && punchProvider.punchOutTime != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You have already checked out today!")),
      );
      return;
    }

    try {
      setState(() => isPunching = true);
      HapticFeedback.lightImpact();

      await _checkinService.checkIn(employeeId: employeeId, logType: logType);

      final now = DateTime.now();

      if (logType == "IN") {
        await punchProvider.setPunchIn(now);
        successText = "Checked in at ${DateFormat('hh:mm a').format(now)}";
      } else {
        await punchProvider.setPunchOut(now);
        successText = "Checked out at ${DateFormat('hh:mm a').format(now)}";
      }

      setState(() {
        showSuccess = true;
      });

      Timer(const Duration(seconds: 2), () {
        if (mounted) setState(() => showSuccess = false);
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Punch failed: $e")));
    } finally {
      setState(() => isPunching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final punchProvider = Provider.of<PunchProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.04),

            Consumer<ProfileProvider>(
              builder: (_, provider, __) {
                final user = provider.profileData;
                return Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundImage:
                          (user?['user_image'] != null &&
                              user!['user_image'] != "")
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
                          _greeting,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                   
                        Text(
                          user?['full_name'] ?? "",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),

            SizedBox(height: screenHeight * 0.07),

            Text(
              _currentTime,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            Text(
              _currentDate,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),

            SizedBox(height: screenHeight * 0.07),

            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: screenWidth * 0.50,
                  height: screenWidth * 0.50,
                  child: CircularProgressIndicator(
                    value: punchProvider.progressValue().clamp(0.0, 1.0),
                    strokeWidth: 7,
                    color: punchProvider.punchOutTime != null
                        ? Colors.grey
                        : Colors.green,
                    backgroundColor: Colors.grey.shade300,
                  ),
                ),
                InkWell(
                  onTap: isPunching ? null : onPunchTap,
                  borderRadius: BorderRadius.circular(screenWidth * 0.45 / 2),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: screenWidth * 0.48,
                    height: screenWidth * 0.48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isPunching
                          ? Colors.grey.shade300
                          : Colors.grey.shade100,
                      boxShadow: isPunching
                          ? []
                          : const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 20,
                                offset: Offset(0, 6),
                              ),
                            ],
                    ),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 800),
                        child: showSuccess
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 60,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    successText,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.fingerprint,
                                    size: 55,
                                    color: Colors.red.shade600,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    punchText(punchProvider),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red.shade600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: screenHeight * 0.07),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _smallInfo(
                  Icons.login,
                  punchProvider.punchInTime == null
                      ? "00:00 AM"
                      : DateFormat(
                          'hh:mm a',
                        ).format(punchProvider.punchInTime!),
                  "Punch In",
                ),
                _smallInfo(
                  Icons.logout,
                  punchProvider.punchOutTime == null
                      ? "00:00 PM"
                      : DateFormat(
                          'hh:mm a',
                        ).format(punchProvider.punchOutTime!),
                  "Punch Out",
                ),
                _smallInfo(
                  Icons.av_timer,
                  punchProvider.totalHours(),
                  "Total Hours",
                ),
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
        Icon(icon, size: 27, color: Colors.red.shade600),
        const SizedBox(height: 4),
        Text(time, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }
}
