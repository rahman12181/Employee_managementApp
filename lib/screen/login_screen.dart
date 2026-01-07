// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:management_app/animations/slide_animation.dart';
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

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isloading = false;
  bool _isPasswordVisible = false;
  bool _isColorChanged = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    EdgeInsets screenPadding = MediaQuery.of(context).padding;

    double textScaleFactor = MediaQuery.of(context).textScaleFactor;

    double responsiveFontSize(double baseSize) {
      return (baseSize * (screenWidth / 375)) * (1 / textScaleFactor.clamp(0.8, 1.2));
    }

    double responsiveHeight(double percentage) {
      final safeHeight = screenHeight - screenPadding.top - screenPadding.bottom;
      return safeHeight * percentage;
    }

    double responsiveWidth(double percentage) {
      return screenWidth * percentage;
    }

    final backgroundColor = isDarkMode ? Colors.grey[900] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final hintTextColor = isDarkMode ? Colors.grey[400] : const Color.fromARGB(255, 96, 93, 93);
    final borderColor = isDarkMode ? Colors.grey[700] : Colors.black;
    final focusedBorderColor = isDarkMode ? Colors.blue[300]! : const Color.fromARGB(255, 52, 169, 232);
    final forgotPasswordColor = _isColorChanged ? (isDarkMode ? Colors.white : Colors.black) : Colors.blue;
    final dividerColor = isDarkMode ? Colors.grey[700] : Colors.grey.shade400;
    final dialogBgColor = isDarkMode ? Colors.grey[800] : Colors.white;
    final dialogTextColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SlideAnimation(
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SettingsScreen(),
                                ),
                              );
                            },
                            child: Image.asset(
                              "assets/images/app_icon.png",
                              width: responsiveWidth(0.267),
                              color: isDarkMode ? Colors.white : null,
                            ),
                          ),
                        ),

                        SizedBox(height: responsiveHeight(0.05)),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Welcome back!",
                            style: TextStyle(
                              fontSize: responsiveFontSize(20),
                              fontFamily: "poppins",
                              color: textColor,
                            ),
                          ),
                        ),
                        SizedBox(height: responsiveHeight(0.01)),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Enter your Login Credentials",
                            style: TextStyle(
                              fontSize: responsiveFontSize(13),
                              fontFamily: "poppins",
                              color: hintTextColor,
                            ),
                          ),
                        ),

                        SizedBox(height: responsiveHeight(0.07)),
                        TextFormField(
                          controller: _emailController,
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: responsiveWidth(0.04),
                              vertical: responsiveHeight(0.015),
                            ),
                            labelText: "Email address",
                            prefixIcon: Icon(
                              Icons.email_rounded,
                              size: responsiveFontSize(17),
                              color: isDarkMode ? Colors.grey[400] : null,
                            ),
                            labelStyle: TextStyle(
                              fontSize: responsiveFontSize(14),
                              color: hintTextColor,
                            ),
                            floatingLabelStyle: TextStyle(
                              color: focusedBorderColor,
                            ),
                            hintStyle: TextStyle(color: hintTextColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                responsiveWidth(0.04),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                responsiveWidth(0.04),
                              ),
                              borderSide: BorderSide(color: borderColor ?? Colors.black),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                responsiveWidth(0.04),
                              ),
                              borderSide: BorderSide(
                                color: focusedBorderColor,
                              ),
                            ),
                            filled: isDarkMode,
                            fillColor: isDarkMode ? Colors.grey[800] : null,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "email required";
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
                        SizedBox(height: responsiveHeight(0.042)),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: responsiveWidth(0.04),
                              vertical: responsiveHeight(0.015),
                            ),
                            labelText: "Password",
                            prefixIcon: Icon(
                              Icons.lock,
                              size: responsiveFontSize(18),
                              color: isDarkMode ? Colors.grey[400] : null,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: isDarkMode ? Colors.grey[400] : null,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            labelStyle: TextStyle(
                              fontSize: responsiveFontSize(14),
                              color: hintTextColor,
                            ),
                            floatingLabelStyle: TextStyle(
                              color: focusedBorderColor,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                responsiveWidth(0.04),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                responsiveWidth(0.04),
                              ),
                              borderSide: BorderSide(color: borderColor ?? Colors.black),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                responsiveWidth(0.04),
                              ),
                              borderSide: BorderSide(color: focusedBorderColor),
                            ),
                            filled: isDarkMode,
                            fillColor: isDarkMode ? Colors.grey[800] : null,
                          ),
                          validator: (value) => (value == null || value.isEmpty)
                              ? "password required"
                              : null,
                        ),
                        SizedBox(height: responsiveHeight(0.02)),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isColorChanged = true;
                              Navigator.pushNamed(
                                context,
                                "/forgotpasswordScreen",
                              );
                            });
                          },
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "Forgot password?",
                              style: TextStyle(
                                fontSize: responsiveFontSize(15),
                                fontWeight: FontWeight.bold,
                                fontFamily: "poppins",
                                color: forgotPasswordColor,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: responsiveHeight(0.02)),
                        ElevatedButton(
                          onPressed: _isloading
                              ? null
                              : () async {
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
                                          response["home_page"] ??
                                          "/homeScreen";
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
                                      await CheckuserUtils.saveloginStatus(
                                        route: route,
                                        cookies: AuthService.cookies,
                                      );

                                      setState(() => _isloading = false);

                                      WidgetsBinding.instance.addPostFrameCallback((
                                        _,
                                      ) {
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (dialogContext) {
                                            if (loginSuccess) {
                                              Future.delayed(
                                                const Duration(seconds: 1),
                                                () {
                                                  // ignore: use_build_context_synchronously
                                                  Navigator.pop(dialogContext);
                                                  if (mounted) {
                                                    Navigator.pushReplacementNamed(
                                                      // ignore: use_build_context_synchronously
                                                      context,
                                                      route,
                                                    );
                                                  }
                                                },
                                              );
                                            }

                                            return Dialog(
                                              backgroundColor: dialogBgColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      responsiveWidth(0.053),
                                                    ),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                  vertical: responsiveHeight(
                                                    0.034,
                                                  ),
                                                  horizontal: responsiveWidth(
                                                    0.064,
                                                  ),
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      height: responsiveHeight(
                                                        0.074,
                                                      ),
                                                      width: responsiveHeight(
                                                        0.074,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: isDarkMode 
                                                          ? Colors.green.withAlpha(50)
                                                          : Colors.green.withAlpha(30),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(
                                                        Icons
                                                            .check_circle_rounded,
                                                        color: Colors.green,
                                                        size:
                                                            responsiveFontSize(
                                                              42,
                                                            ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: responsiveHeight(
                                                        0.022,
                                                      ),
                                                    ),
                                                    Text(
                                                      title,
                                                      style: TextStyle(
                                                        fontSize:
                                                            responsiveFontSize(
                                                              18,
                                                            ),
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: dialogTextColor,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: responsiveHeight(
                                                        0.01,
                                                      ),
                                                    ),
                                                    Text(
                                                      content,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize:
                                                            responsiveFontSize(
                                                              14,
                                                            ),
                                                        color: isDarkMode
                                                          ? Colors.grey[300]
                                                          : Colors.grey.shade700,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: responsiveHeight(
                                                        0.024,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: responsiveHeight(
                                                        0.022,
                                                      ),
                                                      width: responsiveHeight(
                                                        0.022,
                                                      ),
                                                      child:
                                                          CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            color: focusedBorderColor,
                                                          ),
                                                    ),
                                                    SizedBox(
                                                      height: responsiveHeight(
                                                        0.015,
                                                      ),
                                                    ),
                                                    Text(
                                                      "Signing you in...",
                                                      style: TextStyle(
                                                        fontSize:
                                                            responsiveFontSize(
                                                              12,
                                                            ),
                                                        color: isDarkMode
                                                          ? Colors.grey[400]
                                                          : Colors.grey.shade500,
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
                                              builder: (_) => AlertDialog(
                                                backgroundColor: dialogBgColor,
                                                title: Text(
                                                  title,
                                                  style: TextStyle(
                                                    fontSize:
                                                        responsiveFontSize(16),
                                                    color: dialogTextColor,
                                                  ),
                                                ),
                                                content: Text(
                                                  content,
                                                  style: TextStyle(
                                                    fontSize:
                                                        responsiveFontSize(14),
                                                    color: dialogTextColor,
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: Text(
                                                      "OK",
                                                      style: TextStyle(
                                                        fontSize:
                                                            responsiveFontSize(
                                                              14,
                                                            ),
                                                        color: focusedBorderColor,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          });
                                    }
                                  } catch (e) {
                                    setState(() => _isloading = false);
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                          showDialog(
                                            context: context,
                                            builder: (_) => AlertDialog(
                                              backgroundColor: dialogBgColor,
                                              title: Text(
                                                "Network Error",
                                                style: TextStyle(
                                                  fontSize: responsiveFontSize(
                                                    16,
                                                  ),
                                                  color: dialogTextColor,
                                                ),
                                              ),
                                              content: Text(
                                                "$e",
                                                style: TextStyle(
                                                  fontSize: responsiveFontSize(
                                                    14,
                                                  ),
                                                  color: dialogTextColor,
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: Text(
                                                    "OK",
                                                    style: TextStyle(
                                                      fontSize:
                                                          responsiveFontSize(
                                                            14,
                                                          ),
                                                      color: focusedBorderColor,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        });
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: focusedBorderColor,
                            minimumSize: Size(
                              responsiveWidth(0.9),
                              responsiveHeight(0.05),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                responsiveWidth(0.04),
                              ),
                            ),
                          ),
                          child: _isloading
                              ? SizedBox(
                                  height: responsiveHeight(0.027),
                                  width: responsiveHeight(0.027),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: textColor,
                                  ),
                                )
                              : Text(
                                  "Login",
                                  style: TextStyle(
                                    fontSize: responsiveFontSize(16),
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                        ),

                        SizedBox(height: responsiveHeight(0.08)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Container(
                                height: 1,
                                width: responsiveWidth(0.133),
                                color: dividerColor,
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
                                ),
                              ),
                            ),

                            Flexible(
                              child: Container(
                                height: 1,
                                width: responsiveWidth(0.133),
                                color: dividerColor,
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
                                  fontSize: responsiveFontSize(15),
                                  fontFamily: "poppins",
                                  color: textColor,
                                ),
                              ),
                              TextSpan(
                                text: "Tech",
                                style: TextStyle(
                                  fontSize: responsiveFontSize(15),
                                  color: textColor,
                                  fontFamily: "poppins",
                                  fontWeight: FontWeight.w600,
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
            ),
          ),
        ),
      ),
    );
  }
}