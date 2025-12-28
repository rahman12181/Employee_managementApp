import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SystembarUtil {
  static void setSystemBar(BuildContext context) {
    final isDark =Theme.of(context).brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,

        statusBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,

        systemNavigationBarColor:
            isDark ? Colors.black : Colors.white,

        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,

        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
  }
}
