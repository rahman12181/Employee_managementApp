import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SystembarUtil {

static void setSystemBar(BuildContext context){

  final screenColorBrightness=Theme.of(context).brightness;       
  final isdark = screenColorBrightness == Brightness.dark;

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      statusBarIconBrightness: isdark ? Brightness.light : Brightness.dark,
      systemNavigationBarIconBrightness: isdark ?Brightness.light : Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    )
  );   
}
  
}