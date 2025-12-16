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
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 35, 20, 20),
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
                              width: 100,
                            ),
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.07),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Welcome back!",
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: "poppins",
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Enter your Login Credentials",
                            style: TextStyle(
                              fontSize: 13,
                              fontFamily: "poppins",
                              color: const Color.fromARGB(255, 96, 93, 93),
                            ),
                          ),
                        ),

                        SizedBox(height: 70),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 12,
                            ),
                            labelText: "Email address",
                            prefixIcon: Icon(Icons.email_rounded, size: 17),
                            labelStyle: TextStyle(fontSize: 14),
                            floatingLabelStyle: TextStyle(color: Colors.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
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
                        SizedBox(height: 35),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 12,
                            ),
                            labelText: "Password",
                            prefixIcon: Icon(Icons.lock, size: 18),
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
                            labelStyle: TextStyle(fontSize: 14),
                            floatingLabelStyle: TextStyle(color: Colors.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 52, 169, 232),
                              ),
                            ),
                          ),
                          validator: (value) => (value == null || value.isEmpty)
                              ? "password required"
                              : null,
                        ),
                        SizedBox(height: 17),
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
                                fontSize: 15,
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
                        SizedBox(height: 17),
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
                                                  Navigator.pop(dialogContext);
                                                  if (mounted) {
                                                    Navigator.pushReplacementNamed(
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
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 28,
                                                      horizontal: 24,
                                                    ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      height: 60,
                                                      width: 60,
                                                      decoration: BoxDecoration(
                                                        color: Colors.green
                                                            .withAlpha(30),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: const Icon(
                                                        Icons
                                                            .check_circle_rounded,
                                                        color: Colors.green,
                                                        size: 42,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 18),
                                                    Text(
                                                      title,
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      content,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors
                                                            .grey
                                                            .shade700,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 20),
                                                    const SizedBox(
                                                      height: 18,
                                                      width: 18,
                                                      child:
                                                          CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                          ),
                                                    ),
                                                    const SizedBox(height: 12),
                                                    Text(
                                                      "Signing you in...",
                                                      style: TextStyle(
                                                        fontSize: 12,
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
                                                title: Text(title),
                                                content: Text(content),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: const Text("OK"),
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
                                              title: const Text(
                                                "Network Error",
                                              ),
                                              content: Text("$e"),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: const Text("OK"),
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
                              screenWidth * 0.9,
                              screenHeight * 0.05,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: _isloading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "Login",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                        ),

                        SizedBox(height: screenHeight * 0.08),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Container(
                                height: 1,
                                width: 50,
                                color: Colors.grey.shade400,
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                "Powered by",
                                style: TextStyle(
                                  fontSize: 12,
                                  letterSpacing: 0.5,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),

                            Flexible(
                              child: Container(
                                height: 1,
                                width: 50,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Pioneer.",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontFamily: "poppins",
                                  color: const Color.fromARGB(255, 36, 35, 35),
                                ),
                              ),
                              TextSpan(
                                text: "Tech",
                                style: TextStyle(
                                  fontSize: 15,
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
