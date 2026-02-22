// ignore_for_file: deprecated_member_use, unused_field

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
import 'package:management_app/services/location_service.dart';
import 'package:management_app/services/connectivity_service.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class HomemainScreen extends StatefulWidget {
  const HomemainScreen({super.key});

  @override
  State<HomemainScreen> createState() => _HomemainScreenState();
}

class _HomemainScreenState extends State<HomemainScreen>
    with TickerProviderStateMixin {
  String _currentTime = '';
  String _currentDate = '';
  Timer? _timer;
  String _greeting = 'Welcome,';
  Timer? _greetingTimer;

  final CheckinService _checkinService = CheckinService();
  final LocationService _locationService = LocationService();
  final ConnectivityService _connectivityService = ConnectivityService();

  bool _isPunching = false;
  bool _showSuccess = false;
  String _successText = "";
  bool _hasError = false;
  String _errorMessage = "";

  // Location variables
  Position? _currentPosition;
  String _locationAddress = "Tap to fetch location";
  bool _isLocationLoading = false;
  String _locationError = "";
  String _locationType = "";
  Timer? _locationTimer;
  bool _isFirstLocationFetch = true;

  // Internet connectivity
  bool _hasInternet = true;
  ConnectivityResult _connectionType = ConnectivityResult.none;
  StreamSubscription? _connectivitySubscription;

  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  late AnimationController _glowAnimationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _glowAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
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

    // Initialize connectivity service
    _connectivityService.initialize();
    _checkInternetConnection();

    _connectivitySubscription = _connectivityService.connectionStatus.listen((
      result,
    ) {
      if (mounted) {
        setState(() {
          _connectionType = result;
          _hasInternet = result != ConnectivityResult.none;
        });
      }
    });

    // Fetch location on init with delay to ensure UI is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchLocation();
    });

    // Refresh location periodically
    _locationTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      if (mounted) {
        _fetchLocation();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeData());
  }

  Future<void> _checkInternetConnection() async {
    bool hasInternet = await _connectivityService.hasInternetConnection();
    ConnectivityResult type = await _connectivityService.getConnectionType();
    setState(() {
      _hasInternet = hasInternet;
      _connectionType = type;
    });
  }

  Future<void> _initializeData() async {
    try {
      final employeeProvider = Provider.of<EmployeeProvider>(
        context,
        listen: false,
      );

      await employeeProvider.loadEmployeeIdFromLocal();
      await Provider.of<ProfileProvider>(context, listen: false).loadProfile();
      await Provider.of<PunchProvider>(
        context,
        listen: false,
      ).loadDailyPunches();

      final employeeId = employeeProvider.employeeId;
      if (employeeId != null) {
        await Provider.of<AttendanceProvider>(
          context,
          listen: false,
        ).loadMonthAttendance(employeeId, DateTime.now());
      }
    } catch (_) {}
  }

  Future<void> _fetchLocation() async {
    // Don't fetch if already loading
    if (_isLocationLoading) return;

    setState(() {
      _isLocationLoading = true;
      _locationError = "";
      _locationType = "";
    });

    final result = await _locationService.getCurrentLocation();

    if (!mounted) return;

    setState(() {
      _isLocationLoading = false;
      _isFirstLocationFetch = false;

      if (result['success']) {
        _currentPosition = result['position'];
        _locationError = "";
        _locationType = "success";

        // Show coordinates immediately
        _locationAddress =
            "📍 ${result['position'].latitude.toStringAsFixed(6)}, ${result['position'].longitude.toStringAsFixed(6)}";

        // Get address in background
        _getAddressFromCoordinates(
          result['position'].latitude,
          result['position'].longitude,
        );
      } else {
        _locationError = result['error'];
        _locationType = result['type'];

        // Set appropriate message based on error type
        if (result['type'] == 'permission_denied' ||
            result['type'] == 'permanent') {
          _locationAddress = "Permission required";
        } else if (result['type'] == 'gps_disabled') {
          _locationAddress = "GPS is off";
        } else {
          _locationAddress = "Location unavailable";
        }
      }
    });
  }

  Future<void> _getAddressFromCoordinates(double lat, double lng) async {
    String address = await _locationService.getAddressFromLatLng(lat, lng);
    if (mounted) {
      setState(() {
        _locationAddress = address;
      });
    }
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
    _locationTimer?.cancel();
    _connectivitySubscription?.cancel();
    _animationController.dispose();
    _glowAnimationController.dispose();
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

  // ==================== NEW DIALOGS (20% height, 70% width) ====================

  void _showSuccessDialog({required String message, required bool isPunchIn}) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: screenWidth * 0.7,
            height: screenHeight * 0.2,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPunchIn ? Icons.login_rounded : Icons.logout_rounded,
                      color: Colors.green.shade600,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    // Auto close after 2 seconds
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  void _showErrorDialog(String message) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: screenWidth * 0.7,
            height: screenHeight * 0.2,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    color: Colors.red.shade600,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // Auto close after 2 seconds
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  void _showInfoDialog(String message, {Color color = Colors.blue}) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: screenWidth * 0.7,
            height: screenHeight * 0.2,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.info_outline_rounded,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  // ==================== PUNCH LOGIC ====================

  Future<void> _onPunchTap() async {
    final punchProvider = Provider.of<PunchProvider>(context, listen: false);
    final slideProvider = Provider.of<SlideProvider>(context, listen: false);

    if (_hasError) {
      setState(() {
        _hasError = false;
        _errorMessage = "";
      });
    }

    // Check if already completed
    if (punchProvider.punchInTime != null && punchProvider.punchOutTime != null) {
      _showInfoDialog('You have already completed your shift today');
      return;
    }

    HapticFeedback.lightImpact();

    // Show slide button for punch in/out
    if (punchProvider.punchInTime != null && punchProvider.punchOutTime == null) {
      slideProvider.showSlideButton(false, _performPunch);
    } else if (punchProvider.punchInTime == null) {
      slideProvider.showSlideButton(true, _performPunch);
    }
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

    // Double check if already punched
    if (isPunchIn && punchProvider.punchInTime != null) {
      _showInfoDialog('Already checked in today');
      return;
    }

    if (!isPunchIn && punchProvider.punchOutTime != null) {
      _showInfoDialog('Already checked out today');
      return;
    }

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

      // Get fresh location
      Position? freshPosition;
      bool locationSuccess = false;

      try {
        setState(() {
          _isLocationLoading = true;
          _locationError = "";
        });

        final locationResult = await _locationService.getCurrentLocation();

        if (locationResult['success']) {
          freshPosition = locationResult['position'];

          // Validate coordinates
          if (freshPosition!.latitude != 0 || freshPosition.longitude != 0) {
            locationSuccess = true;

            setState(() {
              _currentPosition = freshPosition;
              _locationError = "";
              _locationType = "success";
              _locationAddress =
                  "📍 ${freshPosition!.latitude.toStringAsFixed(6)}, ${freshPosition.longitude.toStringAsFixed(6)}";
            });

            _getAddressFromCoordinates(
              freshPosition.latitude,
              freshPosition.longitude,
            );
          } else {
            setState(() {
              _locationError = "Invalid location";
              _locationType = "error";
              _locationAddress = "Location unavailable";
            });
            locationSuccess = false;
          }
        } else {
          setState(() {
            _locationError = locationResult['error'];
            _locationType = locationResult['type'];
            _locationAddress = "Location unavailable";
          });
          locationSuccess = false;
        }
      } catch (e) {
        debugPrint("Error getting location: $e");
        setState(() {
          _locationError = "Failed to get location";
          _locationAddress = "Location unavailable";
        });
        locationSuccess = false;
      } finally {
        setState(() {
          _isLocationLoading = false;
        });
      }

      // If location failed, show error and stop
      if (!locationSuccess || freshPosition == null) {
        setState(() {
          _isPunching = false;
          _hasError = true;
          _errorMessage = _locationError.isNotEmpty
              ? _locationError
              : "Cannot punch without valid location";
        });

        Timer(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _hasError = false;
              _errorMessage = "";
            });
          }
        });

        return;
      }

      // Call ERP API with location
      final result = await _checkinService.checkIn(
        employeeId: employeeId,
        logType: logType,
        currentPosition: freshPosition,
      );

      setState(() {
        _isPunching = false;
      });

      // Handle offline mode
      if (result['offlineMode'] == true) {
        _successText = isPunchIn 
            ? "✓ Checked in (Offline Mode)"
            : "✓ Checked out (Offline Mode)";

        setState(() {
          _showSuccess = true;
        });

        // Save locally
        if (isPunchIn) {
          await punchProvider.setPunchIn(utcNow);
        } else {
          await punchProvider.setPunchOut(utcNow);
        }

        _showInfoDialog(result['message'] ?? 'Punch saved offline', color: Colors.orange);

        Timer(const Duration(seconds: 2), () {
          if (mounted) setState(() => _showSuccess = false);
        });
      }
      // Handle successful punch
      else if (result['success']) {
        // Save locally
        if (isPunchIn) {
          await punchProvider.setPunchIn(utcNow);
        } else {
          await punchProvider.setPunchOut(utcNow);
        }

        _successText = isPunchIn
            ? "Checked in at ${DateFormat('hh:mm a').format(riyadhNow)}"
            : "Checked out at ${DateFormat('hh:mm a').format(riyadhNow)}";

        setState(() {
          _showSuccess = true;
        });

        // Show success dialog
        _showSuccessDialog(
          message: result['message'] ?? _successText,
          isPunchIn: isPunchIn,
        );

        Timer(const Duration(seconds: 2), () {
          if (mounted) setState(() => _showSuccess = false);
        });

        _fetchLocation();

        final currentMonth = DateTime(utcNow.year, utcNow.month);
        await attendanceProvider.loadMonthAttendance(employeeId, currentMonth);
      }
      // Handle other errors
      else {
        setState(() {
          _hasError = true;
          _errorMessage = result['message'] ?? "Punch failed";
        });

        // Show error dialog
        _showErrorDialog(result['message'] ?? 'Punch failed');

        Timer(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _hasError = false;
              _errorMessage = "";
            });
          }
        });
      }

    } catch (e) {
      setState(() {
        _isPunching = false;
        _hasError = true;
        _errorMessage = "An error occurred";
      });

      _showErrorDialog('Error: $e');

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

  Widget _buildTimeWidget(
    String time,
    String label,
    Color color,
    IconData icon,
  ) {
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
          Icon(
            icon,
            color: color,
            size: MediaQuery.of(context).size.width * 0.05,
          ),
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

  Widget _buildLocationWidget() {
    final screenWidth = MediaQuery.of(context).size.width;

    if (_isLocationLoading) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: 8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "Fetching location...",
              style: TextStyle(
                fontSize: screenWidth * 0.03,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    if (_locationError.isNotEmpty) {
      Color errorColor = Colors.red;
      IconData errorIcon = Icons.error_outline_rounded;
      String buttonText = "Settings";
      VoidCallback? onTap;

      switch (_locationType) {
        case 'gps_disabled':
          errorColor = Colors.orange;
          errorIcon = Icons.gps_off_rounded;
          buttonText = "Enable GPS";
          onTap = () => _locationService.openLocationSettings();
          break;
        case 'denied':
          errorColor = Colors.orange;
          errorIcon = Icons.location_off_rounded;
          buttonText = "Allow Permission";
          onTap = () => _locationService.requestLocationPermission().then(
            (_) => _fetchLocation(),
          );
          break;
        case 'permanent':
          errorColor = Colors.red;
          errorIcon = Icons.security_rounded;
          buttonText = "Open Settings";
          onTap = () => _locationService.openAppSettings();
          break;
        case 'timeout':
          errorColor = Colors.orange;
          errorIcon = Icons.timer_off_rounded;
          buttonText = "Retry";
          onTap = () => _fetchLocation();
          break;
        default:
          errorColor = Colors.red;
          errorIcon = Icons.error_outline_rounded;
          buttonText = "Retry";
          onTap = () => _fetchLocation();
      }

      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: 8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(errorIcon, size: 16, color: errorColor),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                _locationError,
                style: TextStyle(
                  fontSize: screenWidth * 0.03,
                  color: errorColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ),
            GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  buttonText,
                  style: TextStyle(
                    fontSize: screenWidth * 0.025,
                    color: errorColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on_rounded,
                  size: 14,
                  color: Colors.green.shade600,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    _locationAddress,
                    style: TextStyle(
                      fontSize: screenWidth * 0.03,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInternetStatusWidget() {
    final screenWidth = MediaQuery.of(context).size.width;

    if (!_hasInternet) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: 8,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: 14,
                color: Colors.red.shade600,
              ),
              const SizedBox(width: 4),
              Text(
                "No Internet Connection",
                style: TextStyle(
                  fontSize: screenWidth * 0.03,
                  color: Colors.red.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final buttonSize = isPortrait ? screenWidth * 0.45 : screenHeight * 0.45;
    final progressSize = buttonSize * 1.15;
    final glowSize = buttonSize * 1.25;

    final punchProvider = Provider.of<PunchProvider>(context);

    final List<Color> headerGradientColors = isDarkMode
        ? [Colors.grey.shade900, Colors.grey.shade800]
        : [Colors.blue.shade50, Colors.purple.shade50];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
        systemNavigationBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Column(
          children: [
            Container(
              height: mediaQuery.padding.top,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: headerGradientColors,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: headerGradientColors,
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(25),
                          bottomRight: Radius.circular(25),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: screenHeight * 0.02,
                          left: screenWidth * 0.05,
                          right: screenWidth * 0.05,
                          bottom: screenHeight * 0.02,
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
                                      onTap: () => Navigator.pushNamed(
                                        context,
                                        '/settingScreen',
                                      ),
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
                                    color: isDarkMode ? Colors.white : Colors.grey.shade900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.005),
                                Text(
                                  _currentDate,
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.035,
                                    color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade600,
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
                                      _punchButtonColor(punchProvider).withOpacity(0.08),
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
                                      color: Theme.of(context).cardColor,
                                      boxShadow: _getButtonShadows(punchProvider),
                                      border: Border.all(
                                        color: _punchButtonColor(punchProvider).withOpacity(0.15),
                                        width: screenWidth * 0.005,
                                      ),
                                    ),
                                    child: Center(
                                      child: _buildCenterContent(
                                        punchProvider,
                                        Theme.of(context),
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
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                              border: Border.all(
                                color: Theme.of(context).dividerColor.withOpacity(0.1),
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
                          SizedBox(height: screenHeight * 0.015),
                          _buildInternetStatusWidget(),
                          SizedBox(height: screenHeight * 0.015),
                          _buildLocationWidget(),
                          SizedBox(height: screenHeight * 0.015),
                          _buildProgressWidget(punchProvider),
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
                          SizedBox(
                            height: mediaQuery.viewInsets.bottom + screenHeight * 0.02,
                          ),
                        ],
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
                  colors: [Colors.red.shade400, Colors.red.shade600],
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
                colors: [Colors.red.shade400, Colors.red.shade600],
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