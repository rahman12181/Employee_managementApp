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
    // MediaQuery values
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    EdgeInsets screenPadding = MediaQuery.of(context).padding;
    
   
   
    
    double responsiveFontSize(double baseSize) {
      return baseSize * (screenWidth / 375); 
    }
    
    double responsiveHeight(double percentage) {
      return screenHeight * percentage;
    }
    
    double responsiveWidth(double percentage) {
      return screenWidth * percentage;
    }

    return Scaffold(
      backgroundColor: Colors.white,
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
                                  builder: (context) => SettingsScreen(),
                                ),
                              );
                            },
                            child: Image.asset(
                              "assets/images/app_icon.png",
                              width: responsiveWidth(0.267), 
                            ),
                          ),
                        ),

                        SizedBox(height: responsiveHeight(0.07)),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Welcome back!",
                            style: TextStyle(
                              fontSize: responsiveFontSize(20),
                              fontFamily: "poppins",
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
                              color: const Color.fromARGB(255, 96, 93, 93),
                            ),
                          ),
                        ),

                        SizedBox(height: responsiveHeight(0.085)),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: responsiveWidth(0.04),
                              vertical: responsiveHeight(0.015),
                            ),
                            labelText: "Email address",
                            prefixIcon: Icon(
                              Icons.email_rounded, 
                              size: responsiveFontSize(17)
                            ),
                            labelStyle: TextStyle(
                              fontSize: responsiveFontSize(14)
                            ),
                            floatingLabelStyle: const TextStyle(color: Colors.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                responsiveWidth(0.04)
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                responsiveWidth(0.04)
                              ),
                              borderSide: const BorderSide(color: Colors.black),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                responsiveWidth(0.04)
                              ),
                              borderSide: const BorderSide(
                                color: Color.fromARGB(255, 52, 169, 232),
                              ),
                            ),
                          ),
                          validator: (value) => (value == null || value.isEmpty)
                              ? "email required"
                              : (!RegExp(
                                  r'^[a-zA-Z0-9._%+-]+@ppecon\.com$',
                                ).hasMatch(value))
                              ? "invalid email address"
                              : null,
                        ),
                        SizedBox(height: responsiveHeight(0.042)),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: responsiveWidth(0.04),
                              vertical: responsiveHeight(0.015),
                            ),
                            labelText: "Password",
                            prefixIcon: Icon(
                              Icons.lock, 
                              size: responsiveFontSize(18)
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            labelStyle: TextStyle(
                              fontSize: responsiveFontSize(14)
                            ),
                            floatingLabelStyle: const TextStyle(color: Colors.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                responsiveWidth(0.04)
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                responsiveWidth(0.04)
                              ),
                              borderSide: const BorderSide(color: Colors.black),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                responsiveWidth(0.04)
                              ),
                              borderSide: const BorderSide(
                                color: Color.fromARGB(255, 52, 169, 232),
                              ),
                            ),
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
                                color: _isColorChanged
                                    ? const Color.fromARGB(255, 52, 169, 232)
                                    : Colors.black,
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

                                      String route = response["home_page"];
                                      if (route == "/app/home") {
                                        route = "/homeScreen";
                                      }

                                      await CheckuserUtils.saveloginStatus(
                                        route: route,
                                        cookies: AuthService.cookies,
                                      );

                                      setState(() => _isloading = false);

                                      WidgetsBinding.instance.addPostFrameCallback((_,) {
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
                                              backgroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      responsiveWidth(0.053)
                                                    ),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                  vertical: responsiveHeight(0.034),
                                                  horizontal: responsiveWidth(0.064),
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      height: responsiveHeight(0.074),
                                                      width: responsiveHeight(0.074),
                                                      decoration: BoxDecoration(
                                                        color: Colors.green
                                                            .withAlpha(30),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(
                                                        Icons
                                                            .check_circle_rounded,
                                                        color: Colors.green,
                                                        size: responsiveFontSize(42),
                                                      ),
                                                    ),
                                                    SizedBox(height: responsiveHeight(0.022)),
                                                    Text(
                                                      title,
                                                      style: TextStyle(
                                                        fontSize: responsiveFontSize(18),
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    SizedBox(height: responsiveHeight(0.01)),
                                                    Text(
                                                      content,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: responsiveFontSize(14),
                                                        color: Colors
                                                            .grey
                                                            .shade700,
                                                      ),
                                                    ),
                                                    SizedBox(height: responsiveHeight(0.024)),
                                                    SizedBox(
                                                      height: responsiveHeight(0.022),
                                                      width: responsiveHeight(0.022),
                                                      child:
                                                          const CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                          ),
                                                    ),
                                                    SizedBox(height: responsiveHeight(0.015)),
                                                    Text(
                                                      "Signing you in...",
                                                      style: TextStyle(
                                                        fontSize: responsiveFontSize(12),
                                                        color: Colors
                                                            .grey
                                                            .shade500,
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
                                                title: Text(
                                                  title,
                                                  style: TextStyle(
                                                    fontSize: responsiveFontSize(16),
                                                  ),
                                                ),
                                                content: Text(
                                                  content,
                                                  style: TextStyle(
                                                    fontSize: responsiveFontSize(14),
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: Text(
                                                      "OK",
                                                      style: TextStyle(
                                                        fontSize: responsiveFontSize(14),
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
                                              title: Text(
                                                "Network Error",
                                                style: TextStyle(
                                                  fontSize: responsiveFontSize(16),
                                                ),
                                              ),
                                              content: Text(
                                                "$e",
                                                style: TextStyle(
                                                  fontSize: responsiveFontSize(14),
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: Text(
                                                    "OK",
                                                    style: TextStyle(
                                                      fontSize: responsiveFontSize(14),
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
                            backgroundColor: const Color.fromARGB(
                              255,
                              38,
                              161,
                              227,
                            ),
                            minimumSize: Size(
                              responsiveWidth(0.9),
                              responsiveHeight(0.05),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                responsiveWidth(0.04)
                              ),
                            ),
                          ),
                          child: _isloading
                              ? SizedBox(
                                  height: responsiveHeight(0.027),
                                  width: responsiveHeight(0.027),
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  "Login",
                                  style: TextStyle(
                                    fontSize: responsiveFontSize(16),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
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
                                color: Colors.grey.shade400,
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
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),

                            Flexible(
                              child: Container(
                                height: 1,
                                width: responsiveWidth(0.133),
                                color: Colors.grey.shade400,
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
                                  color: const Color.fromARGB(255, 36, 35, 35),
                                ),
                              ),
                              TextSpan(
                                text: "Tech",
                                style: TextStyle(
                                  fontSize: responsiveFontSize(15),
                                  color: Colors.black,
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