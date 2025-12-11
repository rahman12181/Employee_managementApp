import 'package:flutter/material.dart';

class ForgotpasswordScreen extends StatefulWidget {
  const ForgotpasswordScreen({super.key});

  @override
  State<ForgotpasswordScreen> createState()=>_ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotpasswordScreen>{
  @override
  Widget build(BuildContext context) {
   return Scaffold(
    body: Center(
      child: Text("THis is your forgotpassword screen"),
    ),
   );
  }
}