// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:management_app/providers/employee_provider.dart';
import 'package:management_app/providers/profile_provider.dart';
import 'package:management_app/screen/setting_screen.dart';
import 'package:management_app/services/auth_service.dart';
import 'package:management_app/utils/checkuser_util.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> 
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isloading = false;
  bool _isPasswordVisible = false;
  
  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
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
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    EdgeInsets screenPadding = MediaQuery.of(context).padding;

    double textScaleFactor = MediaQuery.of(context).textScaleFactor;

    double responsiveFontSize(double baseSize) {
      return (baseSize * (screenWidth / 375)) *
          (1 / textScaleFactor.clamp(0.8, 1.2));
    }

    double responsiveHeight(double percentage) {
      final safeHeight =
          screenHeight - screenPadding.top - screenPadding.bottom;
      return safeHeight * percentage;
    }

    double responsiveWidth(double percentage) {
      return screenWidth * percentage;
    }

    final backgroundColor = isDarkMode ? Colors.grey[900] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final hintTextColor = isDarkMode
        ? Colors.grey[400]
        : const Color.fromARGB(255, 96, 93, 93);
    final borderColor = isDarkMode ? Colors.grey[700] : Colors.grey.shade300;
    final focusedBorderColor = isDarkMode
        ? Colors.blue[300]!
        : const Color(0xFF2563EB); 
    final dividerColor = isDarkMode ? Colors.grey[700] : Colors.grey.shade400;
    final dialogBgColor = isDarkMode ? Colors.grey[800] : Colors.white;
    final dialogTextColor = isDarkMode ? Colors.white : Colors.black;

    // Gradient colors for premium feel
    final gradientColors = isDarkMode
        ? [
            Colors.blue.shade800.withOpacity(0.2),
            Colors.purple.shade800.withOpacity(0.1),
          ]
        : [
            const Color(0xFF2563EB).withOpacity(0.1),
            const Color(0xFF7C3AED).withOpacity(0.05),
          ];

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.5,
            colors: gradientColors,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              responsiveWidth(0.053),
              screenPadding.top + 15,
              responsiveWidth(0.053),
              20,
            ),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: FadeTransition(
                  opacity: _fadeInAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Column(
                          children: [
                            // Animated Logo with Scale
                            ScaleTransition(
                              scale: _scaleAnimation,
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const SettingsScreen(),
                                      ),
                                    );
                                  },
                                  child: Hero(
                                    tag: 'app_logo',
                                    child: Image.asset(
                                      "assets/images/app_icon.png",
                                      width: responsiveWidth(0.267),
                                      color: isDarkMode ? Colors.white : null,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: responsiveHeight(0.05)),
                            
                            // Welcome Text with Shimmer Effect
                            TweenAnimationBuilder(
                              tween: Tween<double>(begin: 0, end: 1),
                              duration: const Duration(milliseconds: 800),
                              builder: (context, double value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: child,
                                );
                              },
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Welcome back!",
                                      style: TextStyle(
                                        fontSize: responsiveFontSize(28),
                                        fontFamily: "poppins",
                                        fontWeight: FontWeight.w700,
                                        color: textColor,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    SizedBox(height: responsiveHeight(0.005)),
                                    Text(
                                      "Enter your Login Credentials",
                                      style: TextStyle(
                                        fontSize: responsiveFontSize(14),
                                        fontFamily: "poppins",
                                        color: hintTextColor,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: responsiveHeight(0.07)),
                            
                            // Email Field with Animation
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
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    responsiveWidth(0.04),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isDarkMode
                                          ? Colors.transparent
                                          : Colors.black.withOpacity(0.03),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: TextFormField(
                                  controller: _emailController,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: responsiveFontSize(16),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: responsiveWidth(0.04),
                                      vertical: responsiveHeight(0.015),
                                    ),
                                    labelText: "Email address",
                                    labelStyle: TextStyle(
                                      fontSize: responsiveFontSize(14),
                                      color: hintTextColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    floatingLabelStyle: TextStyle(
                                      color: focusedBorderColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: responsiveFontSize(14),
                                    ),
                                    prefixIcon: Container(
                                      padding: EdgeInsets.all(responsiveWidth(0.02)),
                                      child: Icon(
                                        Icons.email_rounded,
                                        size: responsiveFontSize(20),
                                        color: focusedBorderColor,
                                      ),
                                    ),
                                    hintStyle: TextStyle(color: hintTextColor),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        responsiveWidth(0.04),
                                      ),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        responsiveWidth(0.04),
                                      ),
                                      borderSide: BorderSide(
                                        color: borderColor ?? Colors.grey.shade300,
                                        width: 1.5,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        responsiveWidth(0.04),
                                      ),
                                      borderSide: BorderSide(
                                        color: focusedBorderColor,
                                        width: 2,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: isDarkMode 
                                        ? Colors.grey[800] 
                                        : Colors.grey.shade50,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Email required";
                                    }
                                    final emailRegex = RegExp(
                                      r'^[a-zA-Z0-9._%+-]+@(ppecon\.com|gmail\.com)$',
                                    );
                                    if (!emailRegex.hasMatch(value)) {
                                      return "Only ppecon.com or gmail.com emails are allowed";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                            
                            SizedBox(height: responsiveHeight(0.042)),
                            
                            // Password Field with Animation
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
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    responsiveWidth(0.04),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isDarkMode
                                          ? Colors.transparent
                                          : Colors.black.withOpacity(0.03),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: TextFormField(
                                  controller: _passwordController,
                                  obscureText: !_isPasswordVisible,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: responsiveFontSize(16),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: responsiveWidth(0.04),
                                      vertical: responsiveHeight(0.015),
                                    ),
                                    labelText: "Password",
                                    labelStyle: TextStyle(
                                      fontSize: responsiveFontSize(14),
                                      color: hintTextColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    floatingLabelStyle: TextStyle(
                                      color: focusedBorderColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: responsiveFontSize(14),
                                    ),
                                    prefixIcon: Container(
                                      padding: EdgeInsets.all(responsiveWidth(0.02)),
                                      child: Icon(
                                        Icons.lock_rounded,
                                        size: responsiveFontSize(20),
                                        color: focusedBorderColor,
                                      ),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isPasswordVisible
                                            ? Icons.visibility_rounded
                                            : Icons.visibility_off_rounded,
                                        color: hintTextColor,
                                      ),
                                      onPressed: () {
                                        HapticFeedback.selectionClick();
                                        setState(() {
                                          _isPasswordVisible = !_isPasswordVisible;
                                        });
                                      },
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        responsiveWidth(0.04),
                                      ),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        responsiveWidth(0.04),
                                      ),
                                      borderSide: BorderSide(
                                        color: borderColor ?? Colors.grey.shade300,
                                        width: 1.5,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        responsiveWidth(0.04),
                                      ),
                                      borderSide: BorderSide(
                                        color: focusedBorderColor,
                                        width: 2,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: isDarkMode 
                                        ? Colors.grey[800] 
                                        : Colors.grey.shade50,
                                  ),
                                  validator: (value) => (value == null || value.isEmpty)
                                      ? "Password required"
                                      : null,
                                ),
                              ),
                            ),
                            
                            SizedBox(height: responsiveHeight(0.02)),
                            
                            // Forgot Password with Animation
                            TweenAnimationBuilder(
                              tween: Tween<double>(begin: 0, end: 1),
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeOut,
                              builder: (context, double value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: child,
                                );
                              },
                              child: GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.pushNamed(
                                    context,
                                    "/forgotpasswordScreen",
                                  );
                                },
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: responsiveHeight(0.005),
                                      horizontal: responsiveWidth(0.02),
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: isDarkMode
                                          ? Colors.transparent
                                          : focusedBorderColor.withOpacity(0.05),
                                    ),
                                    child: Text(
                                      "Forgot password?",
                                      style: TextStyle(
                                        fontSize: responsiveFontSize(15),
                                        fontWeight: FontWeight.w600,
                                        fontFamily: "poppins",
                                        color: focusedBorderColor,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            
                            SizedBox(height: responsiveHeight(0.04)),
                            
                            // Login Button with Gradient and Animation
                            TweenAnimationBuilder(
                              tween: Tween<double>(begin: 0, end: 1),
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.elasticOut,
                              builder: (context, double value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: child,
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    responsiveWidth(0.04),
                                  ),
                                  gradient: LinearGradient(
                                    colors: isDarkMode
                                        ? [Colors.blue[600]!, Colors.blue[800]!]
                                        : [const Color(0xFF2563EB), const Color(0xFF3B82F6)],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (isDarkMode ? Colors.blue[900]! : Colors.blue[500]!)
                                          .withOpacity(0.4),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _isloading
                                      ? null
                                      : () async {
                                          HapticFeedback.mediumImpact();
                                          if (!_formKey.currentState!.validate()) {
                                            return;
                                          }
                                          setState(() => _isloading = true);

                                          try {
                                            final auth = AuthService();
                                            final response = await auth.loginUser(
                                              email: _emailController.text.trim(),
                                              password: _passwordController.text.trim(),
                                            );

                                            String title = "";
                                            String content = "";
                                            bool loginSuccess = false;

                                            if (response["success"] == true) {
                                              title = "Success";
                                              content =
                                                  "Welcome, ${response["full_name"]}!";
                                              loginSuccess = true;

                                              final profileProvider =
                                                  Provider.of<ProfileProvider>(
                                                    context,
                                                    listen: false,
                                                  );
                                              await profileProvider.loadProfile();

                                              final email =
                                                  profileProvider.profileData?["email"];
                                              if (email != null) {
                                                await Provider.of<EmployeeProvider>(
                                                  context,
                                                  listen: false,
                                                ).fetchAndSaveEmployeeId(email);
                                              }

                                              String route =
                                                  response["home_page"] ?? "/homeScreen";
                                              switch (route) {
                                                case "/app/home":
                                                case "/app":
                                                case "/desk":
                                                case "/app/overview":
                                                  route = "/homeScreen";
                                                  break;
                                                default:
                                                  if (route.isEmpty) {
                                                    route = "/homeScreen";
                                                  }
                                              }

                                              String employeeId =
                                                  response["employee_id"] ?? "";
                                              String? sid;
                                              if (AuthService.cookies.isNotEmpty) {
                                                try {
                                                  sid = AuthService.cookies
                                                      .firstWhere(
                                                        (c) => c.startsWith("sid="),
                                                      )
                                                      .replaceAll("sid=", "")
                                                      .trim();
                                                } catch (_) {}
                                              }

                                              await CheckuserUtils.saveloginStatus(
                                                route: route,
                                                employeeId: employeeId,
                                                userName: response["email"] ?? email,
                                                authToken: sid,
                                                cookies: AuthService.cookies,
                                              );

                                              setState(() => _isloading = false);

                                              WidgetsBinding.instance.addPostFrameCallback((
                                                _,
                                              ) {
                                                showDialog(
                                                  context: context,
                                                  barrierDismissible: false,
                                                  barrierColor: Colors.black.withOpacity(0.5),
                                                  builder: (dialogContext) {
                                                    if (loginSuccess) {
                                                      Future.delayed(
                                                        const Duration(seconds: 2),
                                                        () {
                                                          if (mounted) {
                                                            // ignore: use_build_context_synchronously
                                                            Navigator.pop(dialogContext);
                                                            Navigator.pushReplacementNamed(
                                                              context,
                                                              route,
                                                            );
                                                          }
                                                        },
                                                      );
                                                    }
                                                    return Dialog(
                                                      backgroundColor: Colors.transparent,
                                                      elevation: 0,
                                                      child: Container(
                                                        padding: EdgeInsets.all(
                                                          responsiveWidth(0.08),
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color: dialogBgColor,
                                                          borderRadius: BorderRadius.circular(
                                                            responsiveWidth(0.06),
                                                          ),
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
                                                              curve: Curves.elasticOut,
                                                              width: responsiveWidth(0.15),
                                                              height: responsiveWidth(0.15),
                                                              decoration: BoxDecoration(
                                                                shape: BoxShape.circle,
                                                                color: Colors.green.withOpacity(0.1),
                                                                border: Border.all(
                                                                  color: Colors.green,
                                                                  width: 3,
                                                                ),
                                                              ),
                                                              child: Icon(
                                                                Icons.check_circle_rounded,
                                                                size: responsiveWidth(0.08),
                                                                color: Colors.green,
                                                              ),
                                                            ),
                                                            SizedBox(height: responsiveHeight(0.02)),
                                                            Text(
                                                              title,
                                                              style: TextStyle(
                                                                fontSize: responsiveFontSize(20),
                                                                fontWeight: FontWeight.w700,
                                                                color: dialogTextColor,
                                                              ),
                                                            ),
                                                            SizedBox(height: responsiveHeight(0.01)),
                                                            Text(
                                                              content,
                                                              textAlign: TextAlign.center,
                                                              style: TextStyle(
                                                                fontSize: responsiveFontSize(14),
                                                                color: isDarkMode
                                                                    ? Colors.grey[300]
                                                                    : Colors.grey.shade700,
                                                              ),
                                                            ),
                                                            SizedBox(height: responsiveHeight(0.03)),
                                                            SizedBox(
                                                              width: responsiveWidth(0.1),
                                                              height: responsiveWidth(0.1),
                                                              child: CircularProgressIndicator(
                                                                strokeWidth: 3,
                                                                color: focusedBorderColor,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              });
                                            } else if (response["exc_type"] ==
                                                "DoesNotExistError") {
                                              title = "Login Failed";
                                              content = "User not found!";
                                              setState(() => _isloading = false);
                                            } else if (response["exc_type"] ==
                                                "AuthenticationError") {
                                              title = "Invalid Credentials";
                                              content = "Incorrect password.";
                                              setState(() => _isloading = false);
                                            } else {
                                              title = "Error";
                                              content =
                                                  response["message"] ??
                                                  "Something went wrong";
                                              setState(() => _isloading = false);
                                            }

                                            if (!loginSuccess) {
                                              WidgetsBinding.instance
                                                  .addPostFrameCallback((_) {
                                                    showDialog(
                                                      context: context,
                                                      builder: (_) => Dialog(
                                                        backgroundColor: Colors.transparent,
                                                        elevation: 0,
                                                        child: Container(
                                                          padding: EdgeInsets.all(
                                                            responsiveWidth(0.06),
                                                          ),
                                                          decoration: BoxDecoration(
                                                            color: dialogBgColor,
                                                            borderRadius: BorderRadius.circular(
                                                              responsiveWidth(0.06),
                                                            ),
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
                                                                width: responsiveWidth(0.15),
                                                                height: responsiveWidth(0.15),
                                                                decoration: BoxDecoration(
                                                                  shape: BoxShape.circle,
                                                                  color: Colors.red.withOpacity(0.1),
                                                                  border: Border.all(
                                                                    color: Colors.red,
                                                                    width: 3,
                                                                  ),
                                                                ),
                                                                child: Icon(
                                                                  Icons.error_outline_rounded,
                                                                  size: responsiveWidth(0.08),
                                                                  color: Colors.red,
                                                                ),
                                                              ),
                                                              SizedBox(height: responsiveHeight(0.02)),
                                                              Text(
                                                                title,
                                                                style: TextStyle(
                                                                  fontSize: responsiveFontSize(18),
                                                                  fontWeight: FontWeight.w700,
                                                                  color: dialogTextColor,
                                                                ),
                                                              ),
                                                              SizedBox(height: responsiveHeight(0.01)),
                                                              Text(
                                                                content,
                                                                textAlign: TextAlign.center,
                                                                style: TextStyle(
                                                                  fontSize: responsiveFontSize(14),
                                                                  color: isDarkMode
                                                                      ? Colors.grey[300]
                                                                      : Colors.grey.shade700,
                                                                ),
                                                              ),
                                                              SizedBox(height: responsiveHeight(0.03)),
                                                              SizedBox(
                                                                width: double.infinity,
                                                                child: ElevatedButton(
                                                                  onPressed: () => Navigator.pop(context),
                                                                  style: ElevatedButton.styleFrom(
                                                                    backgroundColor: Colors.red,
                                                                    shape: RoundedRectangleBorder(
                                                                      borderRadius: BorderRadius.circular(
                                                                        responsiveWidth(0.03),
                                                                      ),
                                                                    ),
                                                                    padding: EdgeInsets.symmetric(
                                                                      vertical: responsiveHeight(0.015),
                                                                    ),
                                                                  ),
                                                                  child: Text(
                                                                    "Try Again",
                                                                    style: TextStyle(
                                                                      fontSize: responsiveFontSize(16),
                                                                      fontWeight: FontWeight.w600,
                                                                      color: Colors.white,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  });
                                            }
                                          } catch (e) {
                                            setState(() => _isloading = false);
                                            WidgetsBinding.instance.addPostFrameCallback((
                                              _,
                                            ) {
                                              showDialog(
                                                context: context,
                                                builder: (_) => Dialog(
                                                  backgroundColor: Colors.transparent,
                                                  elevation: 0,
                                                  child: Container(
                                                    padding: EdgeInsets.all(
                                                      responsiveWidth(0.06),
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: dialogBgColor,
                                                      borderRadius: BorderRadius.circular(
                                                        responsiveWidth(0.06),
                                                      ),
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
                                                          width: responsiveWidth(0.15),
                                                          height: responsiveWidth(0.15),
                                                          decoration: BoxDecoration(
                                                            shape: BoxShape.circle,
                                                            color: Colors.orange.withOpacity(0.1),
                                                            border: Border.all(
                                                              color: Colors.orange,
                                                              width: 3,
                                                            ),
                                                          ),
                                                          child: Icon(
                                                            Icons.wifi_off_rounded,
                                                            size: responsiveWidth(0.08),
                                                            color: Colors.orange,
                                                          ),
                                                        ),
                                                        SizedBox(height: responsiveHeight(0.02)),
                                                        Text(
                                                          "Network Error",
                                                          style: TextStyle(
                                                            fontSize: responsiveFontSize(18),
                                                            fontWeight: FontWeight.w700,
                                                            color: dialogTextColor,
                                                          ),
                                                        ),
                                                        SizedBox(height: responsiveHeight(0.01)),
                                                        Text(
                                                          "Please check your internet connection",
                                                          textAlign: TextAlign.center,
                                                          style: TextStyle(
                                                            fontSize: responsiveFontSize(14),
                                                            color: isDarkMode
                                                                ? Colors.grey[300]
                                                                : Colors.grey.shade700,
                                                          ),
                                                        ),
                                                        SizedBox(height: responsiveHeight(0.03)),
                                                        SizedBox(
                                                          width: double.infinity,
                                                          child: ElevatedButton(
                                                            onPressed: () => Navigator.pop(context),
                                                            style: ElevatedButton.styleFrom(
                                                              backgroundColor: Colors.orange,
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(
                                                                  responsiveWidth(0.03),
                                                                ),
                                                              ),
                                                              padding: EdgeInsets.symmetric(
                                                                vertical: responsiveHeight(0.015),
                                                              ),
                                                            ),
                                                            child: Text(
                                                              "OK",
                                                              style: TextStyle(
                                                                fontSize: responsiveFontSize(16),
                                                                fontWeight: FontWeight.w600,
                                                                color: Colors.white,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            });
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    minimumSize: Size(
                                      responsiveWidth(0.9),
                                      responsiveHeight(0.06),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        responsiveWidth(0.04),
                                      ),
                                    ),
                                  ),
                                  child: _isloading
                                      ? SizedBox(
                                          height: responsiveHeight(0.03),
                                          width: responsiveHeight(0.03),
                                          child: const CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.login_rounded,
                                              size: responsiveFontSize(20),
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: responsiveWidth(0.02)),
                                            Text(
                                              "Login",
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
                            ),

                            SizedBox(height: responsiveHeight(0.1)),
                            
                            // Footer with Animation
                            TweenAnimationBuilder(
                              tween: Tween<double>(begin: 0, end: 1),
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeOut,
                              builder: (context, double value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: child,
                                );
                              },
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: Container(
                                          height: 1,
                                          width: responsiveWidth(0.133),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.transparent,
                                                dividerColor!,
                                                Colors.transparent,
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: responsiveWidth(0.032),
                                        ),
                                        child: Text(
                                          "Powered by",
                                          style: TextStyle(
                                            fontSize: responsiveFontSize(12),
                                            letterSpacing: 0.5,
                                            color: hintTextColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: Container(
                                          height: 1,
                                          width: responsiveWidth(0.133),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.transparent,
                                                dividerColor,
                                                Colors.transparent,
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: responsiveHeight(0.02)),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "Pioneer.",
                                          style: TextStyle(
                                            fontSize: responsiveFontSize(16),
                                            fontFamily: "poppins",
                                            color: textColor,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        TextSpan(
                                          text: "Tech",
                                          style: TextStyle(
                                            fontSize: responsiveFontSize(16),
                                            color: focusedBorderColor,
                                            fontFamily: "poppins",
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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