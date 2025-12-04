import 'package:flutter/material.dart';
import 'package:management_app/animations/slide_animation.dart';
import 'package:management_app/screen/home_screen.dart';
import 'package:management_app/services/auth_service.dart';

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
    double screenHeight = MediaQuery.of(context).size.width;
    double screenWidth = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 30, 20, 20),
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
                          child: Image.asset(
                            "assets/images/app_icon.png",
                            width: 100,
                          ),
                        ),
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
                              color: const Color.fromARGB(255, 134, 133, 133),
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
                              :  (!RegExp(r'^[a-zA-Z0-9._%+-]+@extensioncrm\.com$').hasMatch(value))
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
                              : value.length <= 6
                              ? "invalid password,length should be greater then 6 charecter."
                              : !RegExp(r'[A-Z]').hasMatch(value)
                              ? "At least one uppercase letter required"
                              : !RegExp(
                                  r'[!@#\$&*~%^()_+\-=\[\]{};:"\\|,.<>\/?]',
                                ).hasMatch(value)
                              ? "At least one special character required"
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

                                  setState(() {
                                    _isloading = true;
                                  });

                                  try {
                                    final auth = AuthService();

                                    final response = await auth.loginUser(
                                      email: _emailController.text.trim(),
                                      password: _passwordController.text.trim(),
                                    );
                                    if (!mounted) return;
                                    if (response["status"] == true) {
                                      setState(() {
                                        _isloading = false;
                                      });
                                      if (!mounted) return;
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => HomeScreen(),
                                        ),
                                        (route) => false,
                                      );
                                    } else {
                                      if (!mounted) return;
                                      setState(() {
                                        _isloading = false;
                                      });
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            response["message"] ??
                                                "Login failed",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontFamily: "poppins",
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                          margin: EdgeInsets.all(17),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadiusGeometry.circular(
                                                  15,
                                                ),
                                          ),
                                          duration: Duration(seconds: 2),
                                          backgroundColor: const Color.fromARGB(
                                            255,
                                            52,
                                            169,
                                            232,
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    setState(() {
                                      _isloading = false;
                                    });
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Error: $e",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontFamily: "poppins",
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                        margin: EdgeInsets.all(17),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadiusGeometry.circular(15),
                                        ),
                                        backgroundColor: const Color.fromARGB(
                                          255,
                                          52,
                                          169,
                                          232,
                                        ),
                                      ),
                                    );
                                  }
                                },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 52, 169, 232),
                            minimumSize: Size(
                              screenWidth * 0.9,
                              screenHeight * 0.10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),

                          child: _isloading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  "Continue",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontFamily: "poppins",
                                    color: Colors.black,
                                  ),
                                ),
                        ),
                        SizedBox(height: screenHeight * 0.07),
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
