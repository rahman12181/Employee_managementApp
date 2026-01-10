import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
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


    final backgroundColor = isDarkMode ? Colors.grey[900]! : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final hintTextColor = isDarkMode ? Colors.grey[400]! : const Color.fromARGB(255, 134, 133, 133);
    final borderColor = isDarkMode ? Colors.grey[700]! : Colors.black;
    final focusedBorderColor = isDarkMode ? Colors.blue[300]! : const Color.fromARGB(255, 52, 169, 232);
    final buttonColor = isDarkMode ? Colors.blue[300]! : Colors.blue;
    final snackbarSuccessColor = isDarkMode ? Colors.green[800]! : Colors.green;
    final snackbarErrorColor = isDarkMode ? Colors.red[800]! : Colors.red;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              screenPadding.top + 15,
              20,
              20,
            ),
            child: Column(
              children: [
                 Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Image.asset(
                          "assets/images/app_icon.png",
                          width: responsiveWidth(0.25),
                          color: isDarkMode ? Colors.white : null,
                        ),
                      ),
                      SizedBox(height: responsiveHeight(0.08)),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Forgot Password",
                          style: TextStyle(
                            fontSize: responsiveFontSize(25),
                            fontFamily: "poppins",
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ),
                      SizedBox(height: responsiveHeight(0.02)),
                      Text(
                        textAlign: TextAlign.center,
                        "Enter your email to reset your \naccount password",
                        style: TextStyle(
                          fontSize: responsiveFontSize(15),
                          fontFamily: "poppins",
                          color: hintTextColor,
                        ),
                      ),

                      SizedBox(height: responsiveHeight(0.06)),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
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
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    responsiveWidth(0.04),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    responsiveWidth(0.04),
                                  ),
                                  borderSide: BorderSide(color: borderColor),
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
                                  ? "email required"
                                  : (!RegExp(r'^[a-zA-Z0-9._%+-]+@ppecon\.com$').hasMatch(value))
                                  ? "invalid email address"
                                  : null,
                            ),
                            SizedBox(height: responsiveHeight(0.04)),
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
                                              style: TextStyle(
                                                fontSize: responsiveFontSize(15),
                                                fontFamily: "poppins",
                                                color: Colors.white,
                                              ),
                                            ),
                                            backgroundColor: snackbarSuccessColor,
                                            behavior: SnackBarBehavior.floating,
                                            margin: EdgeInsets.all(
                                              responsiveWidth(0.045),
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    responsiveWidth(0.045),
                                                  ),
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
                                              style: TextStyle(
                                                fontSize: responsiveFontSize(15),
                                                fontFamily: "poppins",
                                                color: Colors.white,
                                              ),
                                            ),
                                            backgroundColor: snackbarErrorColor,
                                            behavior: SnackBarBehavior.floating,
                                            margin: EdgeInsets.all(
                                              responsiveWidth(0.045),
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    responsiveWidth(0.045),
                                                  ),
                                            ),
                                            duration: const Duration(
                                              seconds: 2,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: buttonColor,
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
                                        color: textColor,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      "Continue",
                                      style: TextStyle(
                                        fontSize: responsiveFontSize(15),
                                        fontFamily: "poppins",
                                        color: textColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),

                            SizedBox(height: responsiveHeight(0.05)),
                            Align(
                              alignment: Alignment.center,
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Remember Password? ",
                                      style: TextStyle(
                                        fontSize: responsiveFontSize(12),
                                        fontFamily: "poppins",
                                        color: textColor,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "Log In",
                                      style: TextStyle(
                                        fontSize: responsiveFontSize(15),
                                        fontFamily: "poppins",
                                        fontWeight: FontWeight.bold,
                                        color: buttonColor,
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
    );
  }
}