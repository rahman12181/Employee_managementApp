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
  String _greeting = 'Welcome,';
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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await Provider.of<ProfileProvider>(
          context,
          listen: false,
        ).loadProfile();
        await Provider.of<EmployeeProvider>(
          context,
          listen: false,
        ).loadEmployeeIdFromLocal();
        await Provider.of<PunchProvider>(
          context,
          listen: false,
        ).loadDailyPunches();
      } catch (e) {
        debugPrint("Home init error: $e");
      }
    });
  }

  String _getTimeBasedGreeting() {
    final saudiTime = DateTime.now().toUtc().add(const Duration(hours: 3));
    final hour = saudiTime.hour;

    if (hour >= 5 && hour < 12) return 'Good Morning,';
    if (hour >= 12 && hour < 17) return 'Good Afternoon,';
    if (hour >= 17 && hour < 21) return 'Good Evening,';
    return 'Good Night,';
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
    _greetingTimer?.cancel();
    super.dispose();
  }

  Color fingerprintColor(PunchProvider punchProvider) {
    if (isPunching) return Colors.red.shade600;
    if (punchProvider.punchInTime == null) return Colors.blue.shade600;
    if (punchProvider.punchOutTime == null) return Colors.red.shade600;
    return Colors.blue.shade600;
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

    final logType = punchProvider.punchInTime == null ? "IN" : "OUT";

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

      setState(() => showSuccess = true);

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
    final size = MediaQuery.of(context).size;
    final punchProvider = Provider.of<PunchProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(height: size.height * 0.04),

            Consumer<ProfileProvider>(
              builder: (_, provider, __) {
                final user = provider.profileData;
                final imagePath = user?['user_image'];

                return Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundImage:
                          (imagePath != null && imagePath.isNotEmpty)
                          ? NetworkImage("https://ppecon.erpnext.com$imagePath")
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
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color?.withAlpha(60),
                          ),
                        ),
                        Text(
                          user?['full_name'] ?? "",
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),

            SizedBox(height: size.height * 0.07),

            Text(
              _currentTime,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            Text(
              _currentDate,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: const Color.fromARGB(255, 112, 112, 112)),
            ),

            SizedBox(height: size.height * 0.07),

            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: size.width * 0.50,
                  height: size.width * 0.50,
                  child: CircularProgressIndicator(
                    value: punchProvider.progressValue().clamp(0.0, 1.0),
                    strokeWidth: 7,
                    color: Colors.blue,
                    backgroundColor: const Color.fromARGB(255, 199, 196, 196),
                  ),
                ),
                InkWell(
                  onTap: isPunching ? null : onPunchTap,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: size.width * 0.48,
                    height: size.width * 0.48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).cardColor,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 20,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: showSuccess
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 60,
                                ),
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
                                  color: fingerprintColor(punchProvider),
                                ),
                                Text(
                                  punchText(punchProvider),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: fingerprintColor(punchProvider),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: size.height * 0.07),

            /// INFO ROW
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _smallInfo(
                  Icons.login,
                  punchProvider.punchInTime == null
                      ? "--:--"
                      : DateFormat(
                          'hh:mm a',
                        ).format(punchProvider.punchInTime!),
                  "Punch In",
                  iconColor: Colors.blue, // 🔵 Login
                ),
                _smallInfo(
                  Icons.logout,
                  punchProvider.punchOutTime == null
                      ? "--:--"
                      : DateFormat(
                          'hh:mm a',
                        ).format(punchProvider.punchOutTime!),
                  "Punch Out",
                  iconColor: Colors.red, // 🔴 Logout
                ),
                _smallInfo(
                  Icons.av_timer,
                  punchProvider.totalHours(),
                  "Total",
                  iconColor: Colors.green, // 🟢 Total Hours (you can change)
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallInfo(
    IconData icon,
    String value,
    String label, {
    required Color iconColor,
  }) {
    return Column(
      children: [
        Icon(icon, size: 26, color: iconColor),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
