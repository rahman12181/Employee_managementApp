// lib/screens/goodbye_screen.dart

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:management_app/screen/login_screen.dart';

class GoodbyeScreen extends StatefulWidget {
  const GoodbyeScreen({super.key});

  @override
  State<GoodbyeScreen> createState() => _GoodbyeScreenState();
}

class _GoodbyeScreenState extends State<GoodbyeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _rotateAnimation = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    double responsiveWidth(double percentage) => screenWidth * percentage;
    double responsiveHeight(double percentage) => screenHeight * percentage;
    double responsiveFontSize(double baseSize) => baseSize * (screenWidth / 375);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              // Decorative Background Elements
              Positioned(
                top: -screenHeight * 0.1,
                right: -screenWidth * 0.2,
                child: Container(
                  width: screenWidth * 0.6,
                  height: screenWidth * 0.6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.shade50.withOpacity(0.3),
                  ),
                ),
              ),
              Positioned(
                bottom: -screenHeight * 0.1,
                left: -screenWidth * 0.2,
                child: Container(
                  width: screenWidth * 0.6,
                  height: screenWidth * 0.6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.purple.shade50.withOpacity(0.3),
                  ),
                ),
              ),

              // Main Content
              Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: responsiveWidth(0.06),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated Logo with Wave
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Outer Glow
                                  TweenAnimationBuilder(
                                    tween: Tween<double>(begin: 0.8, end: 1.2),
                                    duration: const Duration(milliseconds: 1000),
                                    curve: Curves.easeInOut,
                                    builder: (context, double value, child) {
                                      return Container(
                                        width: responsiveWidth(0.45) * value,
                                        height: responsiveWidth(0.45) * value,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: RadialGradient(
                                            colors: [
                                              Colors.blue.shade100.withOpacity(0.2),
                                              Colors.blue.shade50.withOpacity(0.1),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  
                                  // Main Logo Container
                                  ScaleTransition(
                                    scale: _scaleAnimation,
                                    child: RotationTransition(
                                      turns: _rotateAnimation,
                                      child: Container(
                                        width: responsiveWidth(0.35),
                                        height: responsiveWidth(0.35),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Colors.blue.shade50,
                                              Colors.blue.shade100,
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.blue.withOpacity(0.3),
                                              blurRadius: 30,
                                              spreadRadius: 5,
                                              offset: const Offset(0, 10),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Image.asset(
                                            "assets/images/app_icon.png",
                                            width: responsiveWidth(0.2),
                                            height: responsiveWidth(0.2),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: responsiveHeight(0.03)),
                              
                              // Company Name with Gradient
                              ShaderMask(
                                shaderCallback: (bounds) {
                                  return LinearGradient(
                                    colors: [
                                      Colors.blue.shade700,
                                      Colors.purple.shade600,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ).createShader(bounds);
                                },
                                child: Text(
                                  "PIONEER TECH",
                                  style: TextStyle(
                                    fontSize: responsiveFontSize(32),
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 4,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(height: responsiveHeight(0.005)),
                              
                              // Tagline
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: responsiveWidth(0.04),
                                  vertical: responsiveHeight(0.005),
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blue.shade50,
                                      Colors.purple.shade50,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "INNOVATION • EXCELLENCE • TRUST",
                                  style: TextStyle(
                                    fontSize: responsiveFontSize(12),
                                    letterSpacing: 2,
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: responsiveHeight(0.06)),

                      // Goodbye Message Card
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Container(
                            padding: EdgeInsets.all(responsiveWidth(0.06)),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(responsiveWidth(0.05)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.1),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.blue.shade100,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                // Animated Wave Icon
                                TweenAnimationBuilder(
                                  tween: Tween<double>(begin: 1.0, end: 1.2),
                                  duration: const Duration(milliseconds: 800),
                                  curve: Curves.easeInOut,
                                  child: Container(
                                    padding: EdgeInsets.all(responsiveWidth(0.04)),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          Colors.green.shade50,
                                          Colors.green.shade100,
                                        ],
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.waving_hand_rounded,
                                      size: responsiveWidth(0.12),
                                      color: Colors.green.shade600,
                                    ),
                                  ),
                                  builder: (context, double value, Widget? child) {
                                    return Transform.scale(
                                      scale: value,
                                      child: child,
                                    );
                                  },
                                ),
                                SizedBox(height: responsiveHeight(0.02)),
                                
                                Text(
                                  "Goodbye!",
                                  style: TextStyle(
                                    fontSize: responsiveFontSize(28),
                                    fontWeight: FontWeight.w800,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                                SizedBox(height: responsiveHeight(0.015)),
                                
                                Text(
                                  "You have been successfully logged out.\nThank you for spending time with us today.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: responsiveFontSize(15),
                                    color: Colors.grey.shade600,
                                    height: 1.5,
                                  ),
                                ),

                                SizedBox(height: responsiveHeight(0.02)),

                                // Time of logout
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: responsiveWidth(0.04),
                                    vertical: responsiveHeight(0.008),
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.access_time_rounded,
                                        size: responsiveWidth(0.04),
                                        color: Colors.grey.shade600,
                                      ),
                                      SizedBox(width: responsiveWidth(0.02)),
                                      Text(
                                        "Logged out at ${_getCurrentTime()}",
                                        style: TextStyle(
                                          fontSize: responsiveFontSize(13),
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.w500,
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

                      SizedBox(height: responsiveHeight(0.04)),

                      // Action Buttons
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            children: [
                              Text(
                                "See you again soon!",
                                style: TextStyle(
                                  fontSize: responsiveFontSize(16),
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              SizedBox(height: responsiveHeight(0.02)),
                              
                              // Login Button
                              Container(
                                width: double.infinity,
                                height: responsiveHeight(0.07),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blue.shade600,
                                      Colors.purple.shade600,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(responsiveWidth(0.03)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.3),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const LoginScreen(),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(responsiveWidth(0.03)),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.login_rounded,
                                        size: responsiveWidth(0.06),
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: responsiveWidth(0.02)),
                                      Text(
                                        "Login Again",
                                        style: TextStyle(
                                          fontSize: responsiveFontSize(18),
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              SizedBox(height: responsiveHeight(0.015)),

                              // Exit Button
                              TextButton.icon(
                                onPressed: () => _showExitDialog(context, screenWidth),
                                icon: Icon(
                                  Icons.exit_to_app_rounded,
                                  size: responsiveWidth(0.05),
                                  color: Colors.grey.shade500,
                                ),
                                label: Text(
                                  "Exit Application",
                                  style: TextStyle(
                                    fontSize: responsiveFontSize(15),
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: responsiveWidth(0.06),
                                    vertical: responsiveHeight(0.015),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: responsiveHeight(0.03)),

                      // Footer
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            Text(
                              "© 2026 Pioneer Tech. All rights reserved.",
                              style: TextStyle(
                                fontSize: responsiveFontSize(11),
                                color: Colors.grey.shade400,
                              ),
                            ),
                            SizedBox(height: responsiveHeight(0.005)),
                            Text(
                              "Version 2.0.0",
                              style: TextStyle(
                                fontSize: responsiveFontSize(10),
                                color: Colors.grey.shade400,
                              ),
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
      ),
    );
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : hour;
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  Future<void> _showExitDialog(BuildContext context, double screenWidth) async {
    return showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
        ),
        child: Container(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.orange.shade50,
                      Colors.orange.shade100,
                    ],
                  ),
                ),
                child: Icon(
                  Icons.exit_to_app_rounded,
                  size: screenWidth * 0.1,
                  color: Colors.orange.shade600,
                ),
              ),
              SizedBox(height: screenWidth * 0.04),
              Text(
                "Exit Application?",
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: screenWidth * 0.02),
              Text(
                "Are you sure you want to close the application?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: screenWidth * 0.06),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: screenWidth * 0.035,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(screenWidth * 0.02),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: Text(
                        "Stay",
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        SystemNavigator.pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade600,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: screenWidth * 0.035,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(screenWidth * 0.02),
                        ),
                      ),
                      child: Text(
                        "Exit",
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}