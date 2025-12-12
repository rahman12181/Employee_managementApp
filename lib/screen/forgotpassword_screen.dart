import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:management_app/animations/slide_animation.dart';
import 'package:management_app/screen/login_screen.dart';
import 'package:management_app/services/auth_service.dart';

class ForgotpasswordScreen extends StatefulWidget {
  const ForgotpasswordScreen({super.key});

  @override
  State<ForgotpasswordScreen> createState() => _ForgotpasswordScreenState();
}

class _ForgotpasswordScreenState extends State<ForgotpasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isloading = false;
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                SlideAnimation(
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Image.asset(
                          "assets/images/app_icon.png",
                          width: screenWidth * 0.25,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.08),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Forgot Password",
                          style: TextStyle(
                            fontSize: 25,
                            fontFamily: "poppins",
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        textAlign: TextAlign.center,
                        "Enter your email to reset your \naccount password",
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: "poppins",
                          color: const Color.fromARGB(255, 134, 133, 133),
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.06),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
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
                              : (!RegExp(r'^[a-zA-Z0-9._%+-]+@ppecon\.com$').hasMatch(value))
                              ? "invalid email address"
                              : null,
                        ),
                            SizedBox(height: screenHeight * 0.04),
                            ElevatedButton(
                              onPressed: _isloading
                                  ? null
                                  : () async {
                                      if (!_formKey.currentState!.validate()){
                                        return;
                                      }
                                      setState(() {
                                        _isloading = true;
                                      });

                                      try {
                                        final auth = AuthService();
                                        final message = await auth
                                            .forgotPassword(
                                              _emailController.text.trim(),
                                            );

                                        setState(() => _isloading = false);

                                        if (!mounted) return;

                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              message,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontFamily: "poppins",
                                              ),
                                            ),
                                            backgroundColor: Colors.green,
                                            behavior: SnackBarBehavior.floating,
                                            margin: const EdgeInsets.all(17),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(17),
                                            ),
                                            duration: const Duration(
                                              seconds: 2,
                                            ),
                                          ),
                                        );
                                      } catch (e) {
                                        setState(() => _isloading = false);

                                        if (!mounted) return;

                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              e.toString(),
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontFamily: "poppins",
                                              ),
                                            ),
                                            backgroundColor: Colors.red,
                                            behavior: SnackBarBehavior.floating,
                                            margin: const EdgeInsets.all(17),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(17),
                                            ),
                                            duration: const Duration(
                                              seconds: 2,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  52,
                                  169,
                                  232,
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
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      "Continue",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontFamily: "poppins",
                                        color: Colors.black,
                                      ),
                                    ),
                            ),

                            SizedBox(height: screenHeight * 0.05),
                            Align(
                              alignment: Alignment.center,
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Remember Password?",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: "poppins",
                                        color: Colors.black,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "Log In",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontFamily: "poppins",
                                        fontWeight: FontWeight.bold,
                                        color: const Color.fromARGB(
                                          255,
                                          52,
                                          169,
                                          232,
                                        ),
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>LoginScreen(),
                                            ),
                                          );
                                        },
                                    ),
                                  ],
                                ),
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
    );
  }
}
