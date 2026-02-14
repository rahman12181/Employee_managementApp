// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:management_app/services/auth_service.dart';
import 'package:flutter/services.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _showSuccessDialog() {
    final screenWidth = MediaQuery.of(context).size.width;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: screenWidth * 0.85,
            padding: EdgeInsets.all(screenWidth * 0.06),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(screenWidth * 0.06),
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
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.elasticOut,
                  builder: (_, value, __) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.green,
                            width: 3,
                          ),
                        ),
                        child: const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.green,
                          size: 60,
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: screenWidth * 0.05),
                const Text(
                  "Check your mail!",
                  style: TextStyle(
                    fontSize: 22,
                    fontFamily: "poppins",
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: screenWidth * 0.03),
                const Text(
                  "A password reset link has been sent to your registered email address.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: "poppins",
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: screenWidth * 0.06),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                      _emailController.clear();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: screenWidth * 0.035,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      "OK",
                      style: TextStyle(
                        fontFamily: "poppins",
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: screenWidth * 0.85,
            padding: EdgeInsets.all(screenWidth * 0.06),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(screenWidth * 0.06),
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
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.red,
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    color: Colors.red,
                    size: 60,
                  ),
                ),
                SizedBox(height: screenWidth * 0.05),
                const Text(
                  "Something went wrong",
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: "poppins",
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: screenWidth * 0.03),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: "poppins",
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: screenWidth * 0.06),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: screenWidth * 0.035,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      "OK",
                      style: TextStyle(
                        fontFamily: "poppins",
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    try {
      final auth = AuthService();
      await auth.forgotPassword(_emailController.text.trim());

      if (!mounted) return;
      setState(() => _isLoading = false);

      _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      _showErrorDialog(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive font sizes
    double responsiveFontSize(double baseSize) {
      return baseSize * (screenWidth / 375);
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: Container(
              padding: EdgeInsets.all(screenWidth * 0.015),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: Colors.grey.shade800,
                size: screenWidth * 0.05,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "Change Password",
            style: TextStyle(
              fontSize: responsiveFontSize(18),
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              letterSpacing: 0.5,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: FadeTransition(
                opacity: _fadeInAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Animated Logo
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.all(screenWidth * 0.03),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue.shade50,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.2),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              "assets/images/app_icon.png",
                              width: screenWidth * 0.2,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.04),

                      // Title with Animation
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOut,
                        builder: (context, double value, child) {
                          return Opacity(
                            opacity: value,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Reset Password",
                                  style: TextStyle(
                                    fontSize: responsiveFontSize(28),
                                    fontFamily: "poppins",
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.005),
                                Text(
                                  "Enter your email to receive reset instructions",
                                  style: TextStyle(
                                    fontSize: responsiveFontSize(14),
                                    fontFamily: "poppins",
                                    color: Colors.grey.shade600,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      SizedBox(height: screenHeight * 0.05),

                      // Form with Animation
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOut,
                        builder: (context, double value, child) {
                          return Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: Opacity(
                              opacity: value,
                              child: child,
                            ),
                          );
                        },
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Email Field with Premium Styling
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    screenWidth * 0.04,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  style: TextStyle(
                                    fontSize: responsiveFontSize(16),
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: "Email address",
                                    labelStyle: TextStyle(
                                      fontSize: responsiveFontSize(14),
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    floatingLabelStyle: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w600,
                                      fontSize: responsiveFontSize(14),
                                    ),
                                    prefixIcon: Container(
                                      padding: EdgeInsets.all(
                                        screenWidth * 0.02,
                                      ),
                                      child: Icon(
                                        Icons.email_rounded,
                                        size: responsiveFontSize(20),
                                        color: Colors.blue,
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        screenWidth * 0.04,
                                      ),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        screenWidth * 0.04,
                                      ),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                        width: 1.5,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        screenWidth * 0.04,
                                      ),
                                      borderSide: const BorderSide(
                                        color: Colors.blue,
                                        width: 2,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.04,
                                      vertical: screenHeight * 0.015,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Email required";
                                    }
                                    if (!RegExp(
                                            r'^[a-zA-Z0-9._%+-]+@ppecon\.com$')
                                        .hasMatch(value)) {
                                      return "Only @ppecon.com emails are allowed";
                                    }
                                    return null;
                                  },
                                ),
                              ),

                              SizedBox(height: screenHeight * 0.04),

                              // Info Card
                              Container(
                                padding: EdgeInsets.all(screenWidth * 0.04),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(
                                    screenWidth * 0.04,
                                  ),
                                  border: Border.all(
                                    color: Colors.blue.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline_rounded,
                                      color: Colors.blue.shade700,
                                      size: screenWidth * 0.05,
                                    ),
                                    SizedBox(width: screenWidth * 0.03),
                                    Expanded(
                                      child: Text(
                                        "We'll send a password reset link to your email. Please check your inbox.",
                                        style: TextStyle(
                                          fontSize: responsiveFontSize(12),
                                          color: Colors.blue.shade700,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: screenHeight * 0.04),

                              // Submit Button with Animation
                              TweenAnimationBuilder(
                                tween: Tween<double>(begin: 0, end: 1),
                                duration: const Duration(milliseconds: 600),
                                curve: Curves.elasticOut,
                                builder: (context, double value, child) {
                                  return Transform.scale(
                                    scale: value,
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed:
                                            _isLoading ? null : _submit,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                            vertical: screenHeight * 0.018,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              screenWidth * 0.04,
                                            ),
                                          ),
                                          elevation: 5,
                                          shadowColor:
                                              Colors.blue.withOpacity(0.4),
                                        ),
                                        child: _isLoading
                                            ? SizedBox(
                                                height: screenHeight * 0.025,
                                                width: screenHeight * 0.025,
                                                child:
                                                    const CircularProgressIndicator(
                                                  strokeWidth: 2.5,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(Colors.white),
                                                ),
                                              )
                                            : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.send_rounded,
                                                    size:
                                                        responsiveFontSize(18),
                                                  ),
                                                  SizedBox(
                                                    width: screenWidth * 0.02,
                                                  ),
                                                  Text(
                                                    "Send Reset Link",
                                                    style: TextStyle(
                                                      fontSize:
                                                          responsiveFontSize(
                                                        16,
                                                      ),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                  );
                                },
                              ),

                              SizedBox(height: screenHeight * 0.02),

                              // Back to Login Link
                              TweenAnimationBuilder(
                                tween: Tween<double>(begin: 0, end: 1),
                                duration: const Duration(milliseconds: 600),
                                curve: Curves.easeOut,
                                builder: (context, double value, child) {
                                  return Opacity(
                                    opacity: value,
                                    child: TextButton(
                                      onPressed: () {
                                        HapticFeedback.lightImpact();
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        "Back to Login",
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: responsiveFontSize(14),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.03),

                      // Footer
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOut,
                        builder: (context, double value, child) {
                          return Opacity(
                            opacity: value,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 1,
                                      width: screenWidth * 0.2,
                                      color: Colors.grey.shade300,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: screenWidth * 0.03,
                                      ),
                                      child: Text(
                                        "Powered by",
                                        style: TextStyle(
                                          fontSize: responsiveFontSize(11),
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: 1,
                                      width: screenWidth * 0.2,
                                      color: Colors.grey.shade300,
                                    ),
                                  ],
                                ),
                                SizedBox(height: screenHeight * 0.01),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "Pioneer.",
                                        style: TextStyle(
                                          fontSize: responsiveFontSize(13),
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      TextSpan(
                                        text: "Tech",
                                        style: TextStyle(
                                          fontSize: responsiveFontSize(13),
                                          color: Colors.blue,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}