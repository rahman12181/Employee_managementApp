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
      final employeeProvider = Provider.of<EmployeeProvider>(
        context,
        listen: false,
      );
      
      await employeeProvider.loadEmployeeIdFromLocal();
      await Provider.of<ProfileProvider>(context, listen: false).loadProfile();
      await Provider.of<PunchProvider>(context, listen: false).loadDailyPunches();

      final employeeId = employeeProvider.employeeId;
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
          color: color.withOpacity(0.3),
          blurRadius: 15,
          spreadRadius: 2,
          offset: const Offset(0, 6),
        ),
      ];
    } else if (punchProvider.punchInTime == null) {
      return [
        BoxShadow(
          color: color.withOpacity(0.2),
          blurRadius: 10,
          spreadRadius: 1,
          offset: const Offset(0, 4),
        ),
      ];
    }

    return [
      BoxShadow(
        color: color.withOpacity(0.2),
        blurRadius: 8,
        spreadRadius: 1,
        offset: const Offset(0, 3),
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

      final utcNow = DateTime.now().toUtc();
      final riyadhNow = utcNow.add(const Duration(hours: 3));

      // ✅ Save locally first
      if (isPunchIn) {
        await punchProvider.setPunchIn(utcNow);
        _successText =
            "Checked in at ${DateFormat('hh:mm a').format(riyadhNow)}";
      } else {
        await punchProvider.setPunchOut(utcNow);
        _successText =
            "Checked out at ${DateFormat('hh:mm a').format(riyadhNow)}";
      }

      // ✅ Send to server
      await _checkinService.checkIn(employeeId: employeeId, logType: logType);

      // Reload attendance
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
        _errorMessage = "Punch saved locally. Check connection";
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

  Widget _buildTimeWidget(String time, String label, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.02,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: MediaQuery.of(context).size.width * 0.05),
          SizedBox(height: MediaQuery.of(context).size.height * 0.005),
          Text(
            time,
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.035,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.002),
          Text(
            label,
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.028,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressWidget(PunchProvider punchProvider) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (punchProvider.punchInTime == null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Ready to start your day?",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              color: Colors.blue.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.005),
          Text(
            "Tap the fingerprint to begin",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: screenWidth * 0.032,
              color: Colors.blue.shade400,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    if (punchProvider.punchOutTime == null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Time to wrap up!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              color: Colors.red.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.005),
          Text(
            "Tap to end your productive shift",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: screenWidth * 0.032,
              color: Colors.red.shade400,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: MediaQuery.of(context).size.height * 0.01,
          ),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.green.shade100),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: Colors.green.shade600,
                size: screenWidth * 0.045,
              ),
              SizedBox(width: screenWidth * 0.02),
              Text(
                "Shift completed",
                style: TextStyle(
                  fontSize: screenWidth * 0.038,
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.008),
        Text(
          "Great work today!",
          style: TextStyle(
            fontSize: screenWidth * 0.032,
            color: Colors.green.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final isPortrait = screenHeight > screenWidth;
  
    final buttonSize = isPortrait 
        ? screenWidth * 0.45 
        : screenHeight * 0.45; 
    
    final progressSize = buttonSize * 1.15;
    final glowSize = buttonSize * 1.25;
    
    final punchProvider = Provider.of<PunchProvider>(context);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: screenHeight - mediaQuery.padding.top - mediaQuery.padding.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                              Colors.grey.shade900,
                              Colors.grey.shade800,
                            ]
                          : [
                              Colors.blue.shade50,
                              Colors.purple.shade50,
                            ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                      
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Consumer<ProfileProvider>(
                        builder: (_, provider, __) {
                          final user = provider.profileData;
                          final imagePath = user?['user_image'];
                          return Row(
                            children: [
                              GestureDetector(
                                onTap: () =>
                                    Navigator.pushNamed(context, '/settingScreen'),
                                child: Container(
                                  width: screenWidth * 0.12,
                                  height: screenWidth * 0.12,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    backgroundColor: Colors.blue.shade50,
                                    backgroundImage: (imagePath != null &&
                                            imagePath.isNotEmpty)
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
                              SizedBox(width: screenWidth * 0.03),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _greeting,
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.03,
                                        color: isDarkMode
                                            ? Colors.grey.shade300
                                            : Colors.grey.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.003),
                                    Text(
                                      user?['full_name'] ?? "Employee",
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.045,
                                        fontWeight: FontWeight.w700,
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.grey.shade900,
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
                      SizedBox(height: screenHeight * 0.025),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentTime,
                            style: TextStyle(
                              fontSize: screenWidth * 0.13,
                              fontWeight: FontWeight.w900,
                              color: isDarkMode
                                  ? Colors.white
                                  : Colors.grey.shade900,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.005),
                          Text(
                            _currentDate,
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              color: isDarkMode
                                  ? Colors.grey.shade300
                                  : Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.02),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.025,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          
                          Container(
                            width: glowSize,
                            height: glowSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  _punchButtonColor(punchProvider)
                                      .withOpacity(0.08),
                                  Colors.transparent,
                                ],
                                radius: 0.8,
                              ),
                            ),
                          ),
                          
                         
                          SizedBox(
                            width: progressSize,
                            height: progressSize,
                            child: CircularProgressIndicator(
                              value: punchProvider.progressValue().clamp(0.0, 1.0),
                              strokeWidth: screenWidth * 0.015,
                              color: _punchButtonColor(punchProvider),
                              backgroundColor: Colors.grey.shade200,
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                          
                        
                          if (punchProvider.punchInTime != null &&
                              punchProvider.punchOutTime == null)
                            ScaleTransition(
                              scale: _pulseAnimation,
                              child: Container(
                                width: progressSize * 0.95,
                                height: progressSize * 0.95,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.transparent,
                                  border: Border.all(
                                    color: Colors.red.withOpacity(0.25),
                                    width: screenWidth * 0.008,
                                  ),
                                ),
                              ),
                            ),
                          
                          
                          Material(
                            color: Colors.transparent,
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              borderRadius: BorderRadius.circular(buttonSize),
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
                                width: buttonSize,
                                height: buttonSize,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: theme.cardColor,
                                  boxShadow: _getButtonShadows(punchProvider),
                                  border: Border.all(
                                    color: _punchButtonColor(punchProvider)
                                        .withOpacity(0.15),
                                    width: screenWidth * 0.005,
                                  ),
                                ),
                                child: Center(
                                  child: _buildCenterContent(
                                    punchProvider,
                                    theme,
                                    buttonSize,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: screenHeight * 0.03),
                      
                     
                      Container(
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                          border: Border.all(
                            color: theme.dividerColor.withOpacity(0.1),
                          ),
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
                              Icons.login_rounded,
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
                              Icons.logout_rounded,
                            ),
                            _buildTimeWidget(
                              punchProvider.totalHours(),
                              "Total",
                              Colors.green,
                              Icons.timer_rounded,
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: screenHeight * 0.025),
                      
                      // Progress Message
                      _buildProgressWidget(punchProvider),
                      
                      // Error Message - Responsive
                      if (_hasError)
                        Padding(
                          padding: EdgeInsets.only(top: screenHeight * 0.02),
                          child: AnimatedSlide(
                            duration: const Duration(milliseconds: 300),
                            offset: _hasError ? Offset.zero : const Offset(0, -1),
                            child: Container(
                              padding: EdgeInsets.all(screenWidth * 0.04),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.red.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline_rounded,
                                    color: Colors.red.shade600,
                                    size: screenWidth * 0.06,
                                  ),
                                  SizedBox(width: screenWidth * 0.03),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "Attention",
                                          style: TextStyle(
                                            color: Colors.red.shade800,
                                            fontSize: screenWidth * 0.035,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(height: screenHeight * 0.002),
                                        Text(
                                          _errorMessage,
                                          style: TextStyle(
                                            color: Colors.red.shade700,
                                            fontSize: screenWidth * 0.03,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      
                      // Bottom spacing
                      SizedBox(height: mediaQuery.viewInsets.bottom + screenHeight * 0.02),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCenterContent(
    PunchProvider punchProvider,
    ThemeData theme,
    double buttonSize,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = buttonSize * 0.3;
    
    if (_showSuccess) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: Colors.green,
            size: iconSize * 0.8,
          ),
          SizedBox(height: buttonSize * 0.03),
          Text(
            _successText,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: screenWidth * 0.032,
              color: Colors.green,
            ),
          ),
        ],
      );
    }

    if (_isPunching) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: iconSize * 0.6,
            height: iconSize * 0.6,
            child: CircularProgressIndicator(
              strokeWidth: screenWidth * 0.008,
              color: _punchButtonColor(punchProvider),
            ),
          ),
          SizedBox(height: buttonSize * 0.04),
          Text(
            "Processing...",
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              fontWeight: FontWeight.w700,
              color: _punchButtonColor(punchProvider),
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (punchProvider.punchInTime != null &&
            punchProvider.punchOutTime == null)
          ScaleTransition(
            scale: _pulseAnimation,
            child: ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  colors: [
                    Colors.red.shade400,
                    Colors.red.shade600,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds);
              },
              child: Icon(
                Icons.fingerprint_rounded,
                size: iconSize,
                color: Colors.white,
              ),
            ),
          )
        else
          Icon(
            Icons.fingerprint_rounded,
            size: iconSize * 0.95,
            color: _fingerprintColor(punchProvider),
          ),
        
        SizedBox(height: buttonSize * 0.05),
        
        if (punchProvider.punchInTime != null &&
            punchProvider.punchOutTime == null)
          ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                colors: [
                  Colors.red.shade400,
                  Colors.red.shade600,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ).createShader(bounds);
            },
            child: Text(
              _punchText(punchProvider),
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: screenWidth * 0.04,
                color: Colors.white,
                letterSpacing: 0.8,
              ),
            ),
          )
        else
          Text(
            _punchText(punchProvider),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: screenWidth * 0.038,
              color: _fingerprintColor(punchProvider),
              letterSpacing: 0.6,
            ),
          ),
        
        SizedBox(height: buttonSize * 0.03),
        
        if (punchProvider.punchInTime == null)
          Text(
            "Start your day",
            style: TextStyle(
              fontSize: screenWidth * 0.03,
              color: Colors.blue.shade400,
              fontWeight: FontWeight.w500,
            ),
          )
        else if (punchProvider.punchOutTime == null)
          Text(
            "End your shift",
            style: TextStyle(
              fontSize: screenWidth * 0.03,
              color: Colors.red.shade400,
              fontWeight: FontWeight.w500,
            ),
          )
        else
          Text(
            "Work completed",
            style: TextStyle(
              fontSize: screenWidth * 0.03,
              color: Colors.green.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }
}