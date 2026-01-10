import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:management_app/providers/employee_provider.dart';
import 'package:management_app/providers/profile_provider.dart';
import 'package:management_app/providers/punch_provider.dart';
import 'package:management_app/providers/slide_provider.dart';
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
  bool _hasError = false;
  String _errorMessage = "";

  get hoursh => null;

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
    if (isPunching) return Colors.orange.shade600;
    if (punchProvider.punchInTime == null) return Colors.blue.shade600;
    if (punchProvider.punchOutTime == null) return Colors.red.shade600;
    return Colors.green.shade600;
  }

  String punchText(PunchProvider punchProvider) {
    if (punchProvider.punchInTime == null) return "PUNCH IN";
    if (punchProvider.punchOutTime == null) return "PUNCH OUT";
    return "DONE";
  }

  Color punchButtonColor(PunchProvider punchProvider) {
    if (punchProvider.punchInTime == null) return Colors.blue;
    if (punchProvider.punchOutTime == null) return Colors.red;
    return Colors.green;
  }

  Future<void> onPunchTap() async {
    final punchProvider = Provider.of<PunchProvider>(context, listen: false);
    final slideProvider = Provider.of<SlideProvider>(context, listen: false);

    if (_hasError) {
      setState(() {
        _hasError = false;
        _errorMessage = "";
      });
    }

    if (punchProvider.punchInTime != null &&
        punchProvider.punchOutTime != null) {
      _showError("You have already checked in & out today");
      return;
    }

    HapticFeedback.lightImpact();

    if (punchProvider.punchInTime != null &&
        punchProvider.punchOutTime == null) {
      slideProvider.showSlideButton(false, performPunch);
    } else if (punchProvider.punchInTime == null) {
      slideProvider.showSlideButton(true, performPunch);
    } else {
      _showError("You already checked in today");
    }
  }

  void _showError(String message) {
    setState(() {
      _hasError = true;
      _errorMessage = message;
    });

    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _hasError = false;
          _errorMessage = "";
        });
      }
    });
  }

  Future<void> performPunch(bool isPunchIn) async {
    final employeeId = Provider.of<EmployeeProvider>(
      context,
      listen: false,
    ).employeeId;
    final punchProvider = Provider.of<PunchProvider>(context, listen: false);

    if (employeeId == null || isPunching) return;

    final logType = isPunchIn ? "IN" : "OUT";

    try {
      setState(() {
        isPunching = true;
        showSuccess = false;
        _hasError = false;
      });

      HapticFeedback.lightImpact();

      await _checkinService.checkIn(employeeId: employeeId, logType: logType);

      final now = DateTime.now();

      if (isPunchIn) {
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

      Timer(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => isPunching = false);
      });
    } catch (e) {
      setState(() {
        isPunching = false;
        _hasError = true;
        _errorMessage = "Punch failed: ${e.toString()}";
      });

      Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _hasError = false;
            _errorMessage = "";
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final punchProvider = Provider.of<PunchProvider>(context);
    final slideProvider = Provider.of<SlideProvider>(context, listen: false);

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
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              _currentDate,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color.fromARGB(255, 112, 112, 112),
              ),
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
                    color: punchButtonColor(punchProvider),
                    backgroundColor: const Color.fromARGB(255, 199, 196, 196),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () {
                      if (!slideProvider.showSlideToPunch) {
                        onPunchTap();
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: size.width * 0.48,
                      height: size.width * 0.48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).cardColor,
                        boxShadow: [
                          BoxShadow(
                            color: punchButtonColor(
                              punchProvider,
                            ).withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(child: _buildCenterContent(punchProvider)),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: size.height * 0.07),
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
                  iconColor: Colors.blue,
                ),
                _smallInfo(
                  Icons.logout,
                  punchProvider.punchOutTime == null
                      ? "--:--"
                      : DateFormat(
                          'hh:mm a',
                        ).format(punchProvider.punchOutTime!),
                  "Punch Out",
                  iconColor: Colors.red,
                ),
                _smallInfo(
                  Icons.av_timer,
                  punchProvider.totalHours(),
                  "Total",
                  iconColor: Colors.green,
                ),
              ],
            ),

            if (_hasError)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: IntrinsicWidth(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _errorMessage,
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (punchProvider.punchInTime == null && !_hasError)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  "Tap the punch button to check in",
                  style: TextStyle(color: Colors.blue.shade600, fontSize: 14),
                ),
              ),
            if (punchProvider.punchInTime != null &&
                punchProvider.punchOutTime == null &&
                !_hasError)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  "Tap the punch button to check out",
                  style: TextStyle(color: Colors.red.shade600, fontSize: 14),
                ),
              ),
            if (punchProvider.punchInTime != null &&
                punchProvider.punchOutTime != null &&
                !_hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green.shade600,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Work Completed",
                            style: TextStyle(
                              color: Colors.green.shade800,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Your total working hours: ${punchProvider.totalHours()}",
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterContent(PunchProvider punchProvider) {
    if (showSuccess) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 60),
          const SizedBox(height: 8),
          Text(
            successText,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      );
    }

    if (isPunching) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: punchButtonColor(punchProvider),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Processing...",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: punchButtonColor(punchProvider),
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.fingerprint,
          size: 55,
          color: fingerprintColor(punchProvider),
        ),
        const SizedBox(height: 8),
        Text(
          punchText(punchProvider),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: fingerprintColor(punchProvider),
          ),
        ),
      ],
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
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
