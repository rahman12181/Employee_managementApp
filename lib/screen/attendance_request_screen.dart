// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:management_app/screen/attendance_requests_list_screen.dart';
import '../services/attendance_request_service.dart';
import 'package:flutter/services.dart';

class AttendanceRequestScreen extends StatefulWidget {
  const AttendanceRequestScreen({super.key});

  @override
  State<AttendanceRequestScreen> createState() =>
      _AttendanceRequestScreenState();
}

class _AttendanceRequestScreenState extends State<AttendanceRequestScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  DateTime selectedDate = DateTime.now();
  final TextEditingController explanationCtrl = TextEditingController();

  String reason = "On Duty";
  bool isSubmitting = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  late double screenWidth;
  late double screenHeight;
  late bool isDarkMode;

  double responsiveWidth(double v) => screenWidth * v;
  double responsiveFontSize(double v) => screenWidth * (v / 375);

  final List<String> reasons = [
    "On Duty",
    "Missed Punch",
    "System Issue",
    "Medical Emergency",
    "Personal Reason",
    "Transport Issue",
  ];

  final Map<String, IconData> reasonIcons = {
    "On Duty": Icons.work_outline,
    "Missed Punch": Icons.timer_outlined,
    "System Issue": Icons.error_outline,
    "Medical Emergency": Icons.local_hospital_outlined,
    "Personal Reason": Icons.person_outline,
    "Transport Issue": Icons.directions_bus_outlined,
  };

  final Map<String, Color> reasonColors = {
    "On Duty": Colors.blue,
    "Missed Punch": Colors.amber,
    "System Issue": Colors.red,
    "Medical Emergency": Colors.green,
    "Personal Reason": Colors.purple,
    "Transport Issue": Colors.orange,
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // System navigation bar color ko update karna
    _updateSystemNavigationBar();
  }

  void _updateSystemNavigationBar() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: isDark ? Colors.black : Colors.white,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    explanationCtrl.dispose();

    // Navigation bar ko default pe reset karna
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        statusBarColor: Colors.transparent,
      ),
    );

    super.dispose();
  }

  InputDecoration inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        fontSize: responsiveFontSize(14),
        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: TextStyle(
        color: isDarkMode ? Colors.blue[300]! : Colors.blue[700]!,
        fontSize: responsiveFontSize(14),
        fontWeight: FontWeight.w600,
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenHeight * 0.02,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(responsiveWidth(0.035)),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(responsiveWidth(0.035)),
        borderSide: BorderSide(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(responsiveWidth(0.035)),
        borderSide: BorderSide(
          color: isDarkMode ? Colors.blue[400]! : Colors.blue[600]!,
          width: 2.0,
        ),
      ),
      filled: true,
      fillColor: isDarkMode ? Colors.grey[800]! : Colors.grey[50]!,
      prefixIcon: icon != null
          ? Icon(
              icon,
              size: screenWidth * 0.05,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            )
          : null,
      prefixIconColor: isDarkMode ? Colors.grey[400] : Colors.grey[600],
      suffixIcon: label == "Date"
          ? Icon(
              Icons.calendar_today_rounded,
              size: screenWidth * 0.05,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            )
          : null,
    );
  }

  Future<void> submitAttendanceRequest() async {
    if (!_formKey.currentState!.validate() || isSubmitting) return;

    // Add haptic feedback
    HapticFeedback.mediumImpact();

    setState(() => isSubmitting = true);

    try {
      await AttendanceRequestService().submitRequest(
        date: selectedDate,
        reason: reason,
        explanation: explanationCtrl.text.trim(),
      );

      if (!mounted) return;

      // Success animation
      await _showSuccessAnimation();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Attendance request submitted successfully!",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      // Add a small delay before navigating back
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      final message = e.toString().replaceAll("Exception:", "").trim();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message.isEmpty
                      ? "Request failed. Please try again."
                      : message,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  Future<void> _showSuccessAnimation() async {
    // Create an overlay entry for the success animation
    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Container(
          color: Colors.black.withOpacity(0.4),
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[900]! : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green.withOpacity(0.1),
                        border: Border.all(color: Colors.green, width: 3),
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 50,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Request Sent!",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Your attendance request has been submitted successfully.",
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
    await Future.delayed(const Duration(seconds: 1));
    overlayEntry.remove();
  }

  Widget _buildReasonChips() {
    return Wrap(
      spacing: screenWidth * 0.02,
      runSpacing: screenHeight * 0.01,
      children: reasons.map((reasonOption) {
        final bool isSelected = reason == reasonOption;
        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                reasonIcons[reasonOption],
                size: screenWidth * 0.04,
                color: isSelected ? Colors.white : reasonColors[reasonOption],
              ),
              SizedBox(width: screenWidth * 0.02),
              Text(
                reasonOption,
                style: TextStyle(
                  fontSize: responsiveFontSize(13),
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : null,
                ),
              ),
            ],
          ),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              HapticFeedback.selectionClick();
              setState(() => reason = reasonOption);
            }
          },
          backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
          selectedColor: reasonColors[reasonOption]?.withOpacity(0.8),
          side: BorderSide(
            color: isSelected
                ? reasonColors[reasonOption]!
                : isDarkMode
                ? Colors.grey[700]!
                : Colors.grey[300]!,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(responsiveWidth(0.025)),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenHeight * 0.012,
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // System navigation bar ko update karna
    _updateSystemNavigationBar();

    // Color scheme
    final backgroundColor = isDarkMode
        ? Colors.grey[900]!
        : const Color(0xFFF8FAFD);
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final primaryColor = isDarkMode
        ? Colors.blue[300]!
        : const Color(0xFF2563EB);
    final secondaryColor = isDarkMode
        ? Colors.blue[400]!
        : const Color(0xFF3B82F6);
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subtitleColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];
    final shadowColor = isDarkMode
        ? Colors.black.withOpacity(0.5)
        : Colors.blueGrey.withOpacity(0.1);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: backgroundColor,
          extendBody: true,
          extendBodyBehindAppBar: false,
          appBar: AppBar(
            title: AnimatedOpacity(
              opacity: _fadeAnimation.value,
              duration: const Duration(milliseconds: 300),
              child: Text(
                "Attendance Request",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: responsiveFontSize(18),
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            centerTitle: true,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: const [0.0, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 20,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white, size: 24),
                color: isDarkMode ? Colors.grey[900] : Colors.white,
                surfaceTintColor: isDarkMode ? Colors.grey[800] : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                onSelected: (value) async {
                  if (value == 'my_requests') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AttendanceRequestsListScreen(),
                      ),
                    );
                  }
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem<String>(
                    value: 'my_requests',
                    height: 48,
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? Colors.blue[800]!
                                : Colors.blue[50]!,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.history,
                            size: 18,
                            color: isDarkMode
                                ? Colors.blue[200]!
                                : Colors.blue[700]!,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "My Requests",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode
                                    ? Colors.white
                                    : Colors.grey[900],
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "View attendance history",
                              style: TextStyle(
                                fontSize: 11,
                                color: isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: isDarkMode
                  ? Brightness.light
                  : Brightness.dark,
              statusBarBrightness: isDarkMode
                  ? Brightness.dark
                  : Brightness.light,
              systemNavigationBarColor: Colors.transparent,
              systemNavigationBarDividerColor: Colors.transparent,
              systemNavigationBarIconBrightness: isDarkMode
                  ? Brightness.light
                  : Brightness.dark,
            ),
          ),
          body: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: isDarkMode
                  ? Brightness.light
                  : Brightness.dark,
              statusBarBrightness: isDarkMode
                  ? Brightness.dark
                  : Brightness.light,
              systemNavigationBarColor: isDarkMode
                  ? Colors.black
                  : Colors.white,
              systemNavigationBarDividerColor: Colors.transparent,
              systemNavigationBarIconBrightness: isDarkMode
                  ? Brightness.light
                  : Brightness.dark,
            ),
            child: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  screenWidth * 0.05,
                  screenHeight * 0.02,
                  screenWidth * 0.05,
                  screenHeight * 0.05,
                ),
                child: Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Card
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(screenWidth * 0.05),
                          margin: EdgeInsets.only(bottom: screenHeight * 0.03),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDarkMode
                                  ? [
                                      const Color(0xFF1E293B),
                                      const Color(0xFF0F172A),
                                    ]
                                  : [
                                      const Color(0xFFE0F2FE),
                                      const Color(0xFFF0F9FF),
                                    ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(
                              responsiveWidth(0.05),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: shadowColor,
                                blurRadius: 25,
                                spreadRadius: 1,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(screenWidth * 0.03),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.calendar_month_rounded,
                                      size: screenWidth * 0.07,
                                      color: primaryColor,
                                    ),
                                  ),
                                  SizedBox(width: screenWidth * 0.04),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Submit Your Request",
                                          style: TextStyle(
                                            fontSize: responsiveFontSize(16),
                                            fontWeight: FontWeight.w700,
                                            color: textColor,
                                          ),
                                        ),
                                        SizedBox(height: screenHeight * 0.005),
                                        Text(
                                          "Fill in the details below to request attendance adjustment",
                                          style: TextStyle(
                                            fontSize: responsiveFontSize(12),
                                            color: subtitleColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              Divider(
                                color: isDarkMode
                                    ? Colors.grey[700]
                                    : Colors.grey[300],
                                height: 1,
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              Text(
                                "Note: Requests are subject to approval by your manager.",
                                style: TextStyle(
                                  fontSize: responsiveFontSize(11),
                                  fontStyle: FontStyle.italic,
                                  color: isDarkMode
                                      ? Colors.amber[200]
                                      : Colors.amber[800],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Form Card
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              responsiveWidth(0.05),
                            ),
                          ),
                          color: cardColor,
                          child: Padding(
                            padding: EdgeInsets.all(screenWidth * 0.045),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Date Picker
                                  Text(
                                    "Select Date",
                                    style: TextStyle(
                                      fontSize: responsiveFontSize(14),
                                      fontWeight: FontWeight.w600,
                                      color: textColor,
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.01),
                                  InkWell(
                                    onTap: () async {
                                      HapticFeedback.selectionClick();
                                      final picked = await showDatePicker(
                                        context: context,
                                        firstDate: DateTime.now().subtract(
                                          const Duration(days: 30),
                                        ),
                                        lastDate: DateTime.now(),
                                        initialDate: selectedDate,
                                        builder: (context, child) {
                                          return Theme(
                                            data: Theme.of(context).copyWith(
                                              colorScheme: ColorScheme.light(
                                                primary: primaryColor,
                                                onPrimary: Colors.white,
                                                surface: isDarkMode
                                                    ? const Color(0xFF1E1E1E)
                                                    : Colors.white,
                                                onSurface: textColor,
                                              ),
                                              dialogTheme: DialogThemeData(
                                                backgroundColor: isDarkMode
                                                    ? const Color(0xFF1E1E1E)
                                                    : Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                              ),
                                            ),
                                            child: child!,
                                          );
                                        },
                                      );
                                      if (picked != null) {
                                        setState(() => selectedDate = picked);
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(
                                      responsiveWidth(0.035),
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: screenWidth * 0.04,
                                        vertical: screenHeight * 0.02,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDarkMode
                                            ? Colors.grey[800]
                                            : Colors.grey[50],
                                        borderRadius: BorderRadius.circular(
                                          responsiveWidth(0.035),
                                        ),
                                        border: Border.all(
                                          color: isDarkMode
                                              ? Colors.grey[700]!
                                              : Colors.grey[300]!,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today_rounded,
                                            size: screenWidth * 0.05,
                                            color: primaryColor,
                                          ),
                                          SizedBox(width: screenWidth * 0.03),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Selected Date",
                                                  style: TextStyle(
                                                    fontSize:
                                                        responsiveFontSize(12),
                                                    color: subtitleColor,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: screenHeight * 0.005,
                                                ),
                                                Text(
                                                  DateFormat(
                                                    'EEEE, dd MMMM yyyy',
                                                  ).format(selectedDate),
                                                  style: TextStyle(
                                                    fontSize:
                                                        responsiveFontSize(14),
                                                    fontWeight: FontWeight.w600,
                                                    color: textColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            Icons.chevron_right_rounded,
                                            size: screenWidth * 0.06,
                                            color: subtitleColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: screenHeight * 0.025),

                                  // Reason Selection
                                  Text(
                                    "Select Reason",
                                    style: TextStyle(
                                      fontSize: responsiveFontSize(14),
                                      fontWeight: FontWeight.w600,
                                      color: textColor,
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.015),
                                  _buildReasonChips(),

                                  SizedBox(height: screenHeight * 0.025),

                                  // Explanation
                                  Text(
                                    "Additional Explanation",
                                    style: TextStyle(
                                      fontSize: responsiveFontSize(14),
                                      fontWeight: FontWeight.w600,
                                      color: textColor,
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.01),
                                  TextFormField(
                                    controller: explanationCtrl,
                                    style: TextStyle(
                                      fontSize: responsiveFontSize(14),
                                      color: textColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 4,
                                    minLines: 3,
                                    decoration: inputDecoration(
                                      "Explain your situation in detail...",
                                      icon: Icons.description_outlined,
                                    ),
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) {
                                        return "Please provide an explanation";
                                      }
                                      if (v.trim().length < 10) {
                                        return "Minimum 10 characters required";
                                      }
                                      return null;
                                    },
                                    textInputAction: TextInputAction.done,
                                  ),

                                  SizedBox(height: screenHeight * 0.03),

                                  // Character Counter
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        "${explanationCtrl.text.length}/500",
                                        style: TextStyle(
                                          fontSize: responsiveFontSize(12),
                                          color:
                                              explanationCtrl.text.length > 500
                                              ? Colors.red
                                              : subtitleColor,
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: screenHeight * 0.04),

                                  // Submit Button
                                  SizedBox(
                                    width: double.infinity,
                                    height: screenHeight * 0.065,
                                    child: ElevatedButton(
                                      onPressed: isSubmitting
                                          ? null
                                          : submitAttendanceRequest,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            responsiveWidth(0.035),
                                          ),
                                        ),
                                        elevation: 0,
                                        shadowColor: Colors.transparent,
                                        animationDuration: const Duration(
                                          milliseconds: 300,
                                        ),
                                      ),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          AnimatedOpacity(
                                            opacity: isSubmitting ? 0 : 1,
                                            duration: const Duration(
                                              milliseconds: 200,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.send_rounded,
                                                  size: screenWidth * 0.045,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(
                                                  width: screenWidth * 0.02,
                                                ),
                                                Text(
                                                  "Submit Request",
                                                  style: TextStyle(
                                                    fontSize:
                                                        screenWidth * 0.04,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (isSubmitting)
                                            SizedBox(
                                              width: screenWidth * 0.06,
                                              height: screenWidth * 0.06,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 3,
                                                color: Colors.white,
                                                backgroundColor: Colors.white
                                                    .withOpacity(0.3),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: screenHeight * 0.02),

                                  // Cancel Button
                                  SizedBox(
                                    width: double.infinity,
                                    height: screenHeight * 0.055,
                                    child: TextButton(
                                      onPressed: isSubmitting
                                          ? null
                                          : () {
                                              HapticFeedback.lightImpact();
                                              Navigator.pop(context);
                                            },
                                      style: TextButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            responsiveWidth(0.035),
                                          ),
                                        ),
                                        foregroundColor: subtitleColor,
                                      ),
                                      child: Text(
                                        "Cancel",
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.038,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Footer Information
                        Padding(
                          padding: EdgeInsets.only(top: screenHeight * 0.03),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                size: screenWidth * 0.04,
                                color: subtitleColor,
                              ),
                              SizedBox(width: screenWidth * 0.015),
                              Flexible(
                                child: Text(
                                  "You'll receive a notification once your request is processed",
                                  style: TextStyle(
                                    fontSize: responsiveFontSize(11),
                                    color: subtitleColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
