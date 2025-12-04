import 'package:flutter/material.dart';
import 'package:management_app/screen/home_screen.dart';
import 'package:management_app/screen/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckuserUtils {
  
  static Future<void> checkUser(BuildContext context) async{
    SharedPreferences preference=await SharedPreferences.getInstance();
    await Future.delayed(const Duration(seconds: 3));
    if (!context.mounted) return;

    bool isFirstTime=preference.getBool("isFirstTime") ?? true;
    bool isLoggedIn=preference.getBool("isLoggedIn") ?? false;

     
    if (isFirstTime) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()) 
      );
      preference.setBool("isFirstTime", false);
    }else{

       if (isLoggedIn) {
         Navigator.pushReplacement(
         context,
         MaterialPageRoute(builder: (context) => const HomeScreen())
       );
     }else{
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen())
      );
     }
    }
   
  }
}