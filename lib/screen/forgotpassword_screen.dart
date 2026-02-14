// ignore_for_file: deprecated_member_use

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:management_app/screen/login_screen.dart';
import 'package:management_app/services/auth_service.dart';

class ForgotpasswordScreen extends StatefulWidget {
  const ForgotpasswordScreen({super.key});

  @override
  State<ForgotpasswordScreen> createState() => _ForgotpasswordScreenState();
}

class _ForgotpasswordScreenState extends State<ForgotpasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isloading = false;
  final TextEditingController _emailController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                color == Colors.green ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Color scheme
    final backgroundColor = isDarkMode ? const Color(0xFF121212) : Colors.white;
    final surfaceColor = isDarkMode ? Colors.grey[850]! : Colors.grey[50]!;
    final primaryColor = isDarkMode ? Colors.blue[300]! : Colors.blue[600]!;
    final textColor = isDarkMode ? Colors.white : Colors.grey[900]!;
    final subtitleColor = isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;
    final inputBgColor = isDarkMode ? Colors.grey[800]! : Colors.white;
    final borderColor = isDarkMode ? Colors.grey[700]! : Colors.grey[200]!;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenHeight * 0.02,
            ),
            child: Column(
              children: [
                // Animated Header
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        // Back Button and Logo Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: borderColor,
                                  width: 1.5,
                                ),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: textColor,
                                  size: screenWidth * 0.05,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(screenWidth * 0.03),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    primaryColor.withOpacity(0.2),
                                    primaryColor.withOpacity(0.1),
                                  ],
                                ),
                              ),
                              child: Image.asset(
                                "assets/images/app_icon.png",
                                width: screenWidth * 0.12,
                                color: isDarkMode ? Colors.white : null,
                              ),
                            ),
                            const SizedBox(width: 40), // For balance
                          ],
                        ),
                        
                        SizedBox(height: screenHeight * 0.04),
                        
                        // Title and Subtitle
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.05,
                          ),
                          child: Column(
                            children: [
                              Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  fontSize: screenWidth * 0.07,
                                  fontWeight: FontWeight.w800,
                                  color: textColor,
                                  letterSpacing: -0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: screenHeight * 0.015),
                              Text(
                                "Don't worry! It happens. Please enter your\nregistered email address to reset your password",
                                style: TextStyle(
                                  fontSize: screenWidth * 0.035,
                                  color: subtitleColor,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.05),

                // Animated Form
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      padding: EdgeInsets.all(screenWidth * 0.06),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(screenWidth * 0.05),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Email Field
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Email Address",
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.038,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.012),
                                Container(
                                  decoration: BoxDecoration(
                                    color: inputBgColor,
                                    borderRadius: BorderRadius.circular(screenWidth * 0.04),
                                    border: Border.all(
                                      color: borderColor,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: TextFormField(
                                    controller: _emailController,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.04,
                                      color: textColor,
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      hintText: "Enter your email",
                                      hintStyle: TextStyle(
                                        fontSize: screenWidth * 0.035,
                                        color: subtitleColor.withOpacity(0.7),
                                      ),
                                      prefixIcon: Container(
                                        padding: EdgeInsets.all(screenWidth * 0.025),
                                        child: Icon(
                                          Icons.email_outlined,
                                          color: primaryColor,
                                          size: screenWidth * 0.05,
                                        ),
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: screenHeight * 0.015,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Email is required";
                                      }
                                      if (!RegExp(r'^[a-zA-Z0-9._%+-]+@ppecon\.com$')
                                          .hasMatch(value)) {
                                        return "Please use your @ppecon.com email";
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: screenHeight * 0.035),

                            // Continue Button
                            Container(
                              width: double.infinity,
                              height: screenHeight * 0.06,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    primaryColor,
                                    primaryColor.withOpacity(0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(screenWidth * 0.04),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _isloading ? null : _handleForgotPassword,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(screenWidth * 0.04),
                                  ),
                                ),
                                child: _isloading
                                    ? SizedBox(
                                        height: screenHeight * 0.03,
                                        width: screenHeight * 0.03,
                                        child: const CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.send_rounded,
                                            size: screenWidth * 0.05,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: screenWidth * 0.02),
                                          Text(
                                            "SEND RESET LINK",
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.04,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                              letterSpacing: 0.5,
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
                  ),
                ),

                SizedBox(height: screenHeight * 0.04),

                // Login Link
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: screenHeight * 0.02,
                    ),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(screenWidth * 0.04),
                      border: Border.all(
                        color: borderColor,
                        width: 1,
                      ),
                    ),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Remember your password? ",
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              color: subtitleColor,
                            ),
                          ),
                          TextSpan(
                            text: "Sign In",
                            style: TextStyle(
                              fontSize: screenWidth * 0.038,
                              fontWeight: FontWeight.w700,
                              color: primaryColor,
                              decoration: TextDecoration.underline,
                              decorationColor: primaryColor.withOpacity(0.3),
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.02),

                // Info Text
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.security_rounded,
                        size: screenWidth * 0.03,
                        color: subtitleColor,
                      ),
                      SizedBox(width: screenWidth * 0.01),
                      Text(
                        "We'll send a reset link to your email",
                        style: TextStyle(
                          fontSize: screenWidth * 0.03,
                          color: subtitleColor,
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
    );
  }

  Future<void> _handleForgotPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isloading = true);

    try {
      final auth = AuthService();
      final message = await auth.forgotPassword(
        _emailController.text.trim(),
      );

      if (!mounted) return;

      setState(() => _isloading = false);
      _showSnackbar(message, Colors.green);

      // Clear email after success
      _emailController.clear();

      // Optional: Navigate to login after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
          );
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isloading = false);
      _showSnackbar(e.toString(), Colors.red);
    }
  }
}