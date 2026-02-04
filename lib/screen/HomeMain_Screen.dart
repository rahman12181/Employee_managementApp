// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:management_app/providers/employee_provider.dart';
import 'package:management_app/providers/profile_provider.dart';
import 'package:management_app/providers/punch_provider.dart';
import 'package:management_app/providers/slide_provider.dart';
import 'package:management_app/providers/attendance_provider.dart';
import 'package:management_app/services/checkin_service.dart';
import 'package:provider/provider.dart';

class HomemainScreen extends StatefulWidget {
  const HomemainScreen({super.key});

  @override
  State<HomemainScreen> createState() => _HomemainScreenState();
}

class _HomemainScreenState extends State<HomemainScreen>
    with SingleTickerProviderStateMixin {
  String _currentTime = '';
  String _currentDate = '';
  Timer? _timer;
  String _greeting = 'Welcome,';
  Timer? _greetingTimer;

  final CheckinService _checkinService = CheckinService();

  bool _isPunching = false;
  bool _showSuccess = false;
  String _successText = "";
  bool _hasError = false;
  String _errorMessage = "";

  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());

    _greetingTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _greeting = _getTimeBasedGreeting();
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeData());
  }

  Future<void> _initializeData() async {
    try {
      await Future.wait([
        Provider.of<ProfileProvider>(context, listen: false).loadProfile(),
        Provider.of<EmployeeProvider>(
          context,
          listen: false,
        ).loadEmployeeIdFromLocal(),
        Provider.of<PunchProvider>(context, listen: false).loadDailyPunches(),
      ]);

      final employeeId = Provider.of<EmployeeProvider>(
        context,
        listen: false,
      ).employeeId;
      if (employeeId != null) {
        await Provider.of<AttendanceProvider>(
          context,
          listen: false,
        ).loadMonthAttendance(employeeId, DateTime.now());
      }
    } catch (_) {}
  }

  String _getTimeBasedGreeting() {
    final riyadhTime = DateTime.now().toUtc().add(const Duration(hours: 3));
    final hour = riyadhTime.hour;

    if (hour >= 5 && hour < 12) return 'Good Morning,';
    if (hour >= 12 && hour < 17) return 'Good Afternoon,';
    if (hour >= 17 && hour < 21) return 'Good Evening,';
    return 'Good Night,';
  }

  void _updateTime() {
    if (!mounted) return;

    final utcNow = DateTime.now().toUtc();
    final riyadhTime = utcNow.add(const Duration(hours: 3));

    setState(() {
      _currentTime = DateFormat('hh:mm a').format(riyadhTime);
      _currentDate = DateFormat('MMM dd, yyyy • EEEE').format(riyadhTime);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _greetingTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Color _fingerprintColor(PunchProvider punchProvider) {
    if (_isPunching) return Colors.orange.shade600;
    if (punchProvider.punchInTime == null) return Colors.blue.shade600;
    if (punchProvider.punchOutTime == null) return Colors.red.shade600;
    return Colors.green.shade600;
  }

  String _punchText(PunchProvider punchProvider) {
    if (punchProvider.punchInTime == null) return "PUNCH IN";
    if (punchProvider.punchOutTime == null) return "PUNCH OUT";
    return "COMPLETED";
  }

  Color _punchButtonColor(PunchProvider punchProvider) {
    if (punchProvider.punchInTime == null) return Colors.blue;
    if (punchProvider.punchOutTime == null) return Colors.red;
    return Colors.green;
  }

  List<BoxShadow> _getButtonShadows(PunchProvider punchProvider) {
    final color = _punchButtonColor(punchProvider);

    if (punchProvider.punchInTime != null &&
        punchProvider.punchOutTime == null) {
      return [
        BoxShadow(
          color: color.withOpacity(0.4),
          blurRadius: 25,
          spreadRadius: 3,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: color.withOpacity(0.2),
          blurRadius: 40,
          spreadRadius: 5,
          offset: const Offset(0, 12),
        ),
      ];
    } else if (punchProvider.punchInTime == null) {
      return [
        BoxShadow(
          color: color.withOpacity(0.3),
          blurRadius: 20,
          spreadRadius: 2,
          offset: const Offset(0, 6),
        ),
      ];
    }

    return [
      BoxShadow(
        color: color.withOpacity(0.3),
        blurRadius: 20,
        spreadRadius: 2,
        offset: const Offset(0, 6),
      ),
    ];
  }

  Future<void> _onPunchTap() async {
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
      _showError("You have already completed work today");
      return;
    }

    HapticFeedback.lightImpact();

    if (punchProvider.punchInTime != null &&
        punchProvider.punchOutTime == null) {
      slideProvider.showSlideButton(false, _performPunch);
    } else if (punchProvider.punchInTime == null) {
      slideProvider.showSlideButton(true, _performPunch);
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

  Future<void> _performPunch(bool isPunchIn) async {
    final employeeId = Provider.of<EmployeeProvider>(
      context,
      listen: false,
    ).employeeId;
    final punchProvider = Provider.of<PunchProvider>(context, listen: false);
    final attendanceProvider = Provider.of<AttendanceProvider>(
      context,
      listen: false,
    );

    if (employeeId == null || _isPunching) return;

    final logType = isPunchIn ? "IN" : "OUT";

    try {
      setState(() {
        _isPunching = true;
        _showSuccess = false;
        _hasError = false;
      });

      HapticFeedback.mediumImpact();

      await _checkinService.checkIn(employeeId: employeeId, logType: logType);

      final utcNow = DateTime.now().toUtc();
      final riyadhNow = utcNow.add(const Duration(hours: 3));

      if (isPunchIn) {
        await punchProvider.setPunchIn(utcNow);
        _successText =
            "Checked in at ${DateFormat('hh:mm a').format(riyadhNow)}";
      } else {
        await punchProvider.setPunchOut(utcNow);
        _successText =
            "Checked out at ${DateFormat('hh:mm a').format(riyadhNow)}";
      }

      final currentMonth = DateTime(utcNow.year, utcNow.month);
      await attendanceProvider.loadMonthAttendance(employeeId, currentMonth);

      setState(() => _showSuccess = true);

      Timer(const Duration(seconds: 2), () {
        if (mounted) setState(() => _showSuccess = false);
      });

      Timer(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _isPunching = false);
      });
    } catch (_) {
      setState(() {
        _isPunching = false;
        _hasError = true;
        _errorMessage = "Punch failed. Check connection";
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

  Widget _buildTimeWidget(String time, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Text(
            time,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressWidget(PunchProvider punchProvider) {
    if (punchProvider.punchInTime == null) {
      return Column(
        children: [
          Text(
            "Ready to start?",
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Tap to begin your workday",
            style: TextStyle(fontSize: 12, color: Colors.blue.shade400),
          ),
        ],
      );
    }

    if (punchProvider.punchOutTime == null) {
      return Column(
        children: [
          Text(
            "Time to wrap up!",
            style: TextStyle(
              fontSize: 14,
              color: Colors.red.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Tap to end your shift",
            style: TextStyle(fontSize: 12, color: Colors.red.shade400),
          ),
        ],
      );
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: Colors.green.shade600,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              "Shift completed",
              style: TextStyle(
                fontSize: 14,
                color: Colors.green.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          "Great work today!",
          style: TextStyle(fontSize: 12, color: Colors.green.shade500),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height - mediaQuery.padding.top;
    final screenWidth = mediaQuery.size.width;
    final isSmallScreen = screenHeight < 600;
    final punchProvider = Provider.of<PunchProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: screenHeight),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: screenHeight * 0.02,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: isSmallScreen ? 10 : 20),

                  Consumer<ProfileProvider>(
                    builder: (_, provider, __) {
                      final user = provider.profileData;
                      final imagePath = user?['user_image'];
                      return Row(
                        children: [
                          GestureDetector(
                            onTap: () =>
                                Navigator.pushNamed(context, '/settingScreen'),
                            child: CircleAvatar(
                              radius: isSmallScreen ? 20 : 22,
                              backgroundColor: Colors.blue.shade50,
                              child: CircleAvatar(
                                radius: isSmallScreen ? 18 : 20,
                                backgroundImage:
                                    (imagePath != null && imagePath.isNotEmpty)
                                    ? NetworkImage(
                                        "https://ppecon.erpnext.com$imagePath",
                                      )
                                    : const AssetImage(
                                            "assets/images/app_icon.png",
                                          )
                                          as ImageProvider,
                              ),
                            ),
                          ),
                          SizedBox(width: isSmallScreen ? 8 : 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _greeting,
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 11 : 12,
                                    color: theme.textTheme.bodyMedium?.color
                                        ?.withOpacity(0.6),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  user?['full_name'] ?? "Employee",
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    fontSize: isSmallScreen ? 13 : 16,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  SizedBox(height: isSmallScreen ? 25 : 35),

                  Column(
                    children: [
                      Text(
                        _currentTime,
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.07,
                          fontWeight: FontWeight.w800,
                          color: theme.brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01,
                      ),
                      Text(
                        _currentDate,
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.032,
                          color: theme.brightness == Brightness.dark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isSmallScreen ? 25 : 35),

                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: screenWidth * (isSmallScreen ? 0.65 : 0.58),
                        height: screenWidth * (isSmallScreen ? 0.65 : 0.58),
                        child: CircularProgressIndicator(
                          value: punchProvider.progressValue().clamp(0.0, 1.0),
                          strokeWidth: isSmallScreen ? 6 : 8,
                          color: _punchButtonColor(punchProvider),
                          backgroundColor: Colors.grey.shade200,
                        ),
                      ),

                      if (punchProvider.punchInTime != null &&
                          punchProvider.punchOutTime == null)
                        ScaleTransition(
                          scale: _pulseAnimation,
                          child: Container(
                            width: screenWidth * (isSmallScreen ? 0.63 : 0.56),
                            height: screenWidth * (isSmallScreen ? 0.63 : 0.56),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.transparent,
                              border: Border.all(
                                color: Colors.red.withOpacity(0.3),
                                width: isSmallScreen ? 2 : 3,
                              ),
                            ),
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
                            final slideProvider = Provider.of<SlideProvider>(
                              context,
                              listen: false,
                            );
                            if (!slideProvider.showSlideToPunch) {
                              _onPunchTap();
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: screenWidth * (isSmallScreen ? 0.55 : 0.48),
                            height: screenWidth * (isSmallScreen ? 0.55 : 0.48),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.cardColor,
                              boxShadow: _getButtonShadows(punchProvider),
                            ),
                            child: Center(
                              child: _buildCenterContent(
                                punchProvider,
                                theme,
                                isSmallScreen,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: isSmallScreen ? 20 : 30),

                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildTimeWidget(
                          punchProvider.punchInTime == null
                              ? "--:--"
                              : DateFormat('hh:mm a').format(
                                  punchProvider.punchInTime!.add(
                                    const Duration(hours: 3),
                                  ),
                                ),
                          "Punch In",
                          Colors.blue,
                        ),
                        _buildTimeWidget(
                          punchProvider.punchOutTime == null
                              ? "--:--"
                              : DateFormat('hh:mm a').format(
                                  punchProvider.punchOutTime!.add(
                                    const Duration(hours: 3),
                                  ),
                                ),
                          "Punch Out",
                          Colors.red,
                        ),
                        _buildTimeWidget(
                          punchProvider.totalHours(),
                          "Total",
                          Colors.green,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 15 : 25),

                  _buildProgressWidget(punchProvider),

                  if (_hasError)
                    Padding(
                      padding: EdgeInsets.only(top: isSmallScreen ? 15 : 20),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 12 : 16,
                          vertical: isSmallScreen ? 8 : 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              color: Colors.red.shade600,
                              size: isSmallScreen ? 18 : 20,
                            ),
                            SizedBox(width: isSmallScreen ? 6 : 10),
                            Flexible(
                              child: Text(
                                _errorMessage,
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: isSmallScreen ? 12 : 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  SizedBox(height: mediaQuery.viewInsets.bottom > 0 ? 20 : 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCenterContent(
    PunchProvider punchProvider,
    ThemeData theme,
    bool isSmallScreen,
  ) {
    if (_showSuccess) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: Colors.green,
            size: isSmallScreen ? 40 : 48,
          ),
          SizedBox(height: isSmallScreen ? 6 : 8),
          Text(
            _successText,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: isSmallScreen ? 12 : 13,
              color: Colors.green,
            ),
          ),
        ],
      );
    }

    if (_isPunching) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: isSmallScreen ? 32 : 40,
            height: isSmallScreen ? 32 : 40,
            child: CircularProgressIndicator(
              strokeWidth: isSmallScreen ? 2.5 : 3,
              color: _punchButtonColor(punchProvider),
            ),
          ),
          SizedBox(height: isSmallScreen ? 8 : 10),
          Text(
            "Processing...",
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 13,
              fontWeight: FontWeight.w600,
              color: _punchButtonColor(punchProvider),
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (punchProvider.punchInTime != null &&
            punchProvider.punchOutTime == null)
          ScaleTransition(
            scale: _pulseAnimation,
            child: Icon(
              Icons.fingerprint_rounded,
              size: isSmallScreen ? 48 : 56,
              color: _fingerprintColor(punchProvider),
            ),
          )
        else
          Icon(
            Icons.fingerprint_rounded,
            size: isSmallScreen ? 44 : 52,
            color: _fingerprintColor(punchProvider),
          ),

        SizedBox(height: isSmallScreen ? 7 : 9),

        if (punchProvider.punchInTime != null &&
            punchProvider.punchOutTime == null)
          ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                colors: [
                  Colors.red.shade400,
                  Colors.red.shade600,
                  Colors.red.shade400,
                ],
                stops: const [0.0, 0.5, 1.0],
                tileMode: TileMode.mirror,
              ).createShader(bounds);
            },
            child: Text(
              _punchText(punchProvider),
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: isSmallScreen ? 14 : 16,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          )
        else
          Text(
            _punchText(punchProvider),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: isSmallScreen ? 14 : 15,
              color: _fingerprintColor(punchProvider),
              letterSpacing: 0.5,
            ),
          ),

        SizedBox(height: isSmallScreen ? 5 : 6),

        if (punchProvider.punchInTime == null)
          Text(
            "Start your day",
            style: TextStyle(
              fontSize: isSmallScreen ? 10 : 11,
              color: Colors.blue.shade400,
              fontWeight: FontWeight.w500,
            ),
          )
        else if (punchProvider.punchOutTime == null)
          Text(
            "End your shift",
            style: TextStyle(
              fontSize: isSmallScreen ? 10 : 11,
              color: Colors.red.shade400,
              fontWeight: FontWeight.w500,
            ),
          )
        else
          Text(
            "Work completed",
            style: TextStyle(
              fontSize: isSmallScreen ? 10 : 11,
              color: Colors.green.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }
}
