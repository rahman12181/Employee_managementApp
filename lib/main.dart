import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:management_app/card_screen/attendance_regularization.dart';
import 'package:management_app/card_screen/check_more.dart';
import 'package:management_app/card_screen/leave_approval.dart';
import 'package:management_app/card_screen/leaverequest.dart';
import 'package:management_app/card_screen/leaverequestdetail.dart';
import 'package:management_app/card_screen/regularization_approval.dart';
import 'package:management_app/card_screen/regularization_lsiting.dart';
import 'package:management_app/providers/attendance_history_provider.dart';
import 'package:management_app/providers/employee_provider.dart';
import 'package:management_app/providers/profile_provider.dart';
import 'package:management_app/providers/punch_provider.dart';
import 'package:management_app/screen/HomeMain_Screen.dart';
import 'package:management_app/screen/attendance_history_screen.dart';
import 'package:management_app/screen/forgotPassword_screen.dart';
import 'package:management_app/screen/home_screen.dart';
import 'package:management_app/screen/login_screen.dart';
import 'package:management_app/screen/notification_screen.dart';
import 'package:management_app/screen/profilescreen.dart';
import 'package:management_app/screen/setting_screen.dart';
import 'package:management_app/screen/splash_screen.dart';
import 'package:management_app/services/auth_service.dart';
import 'package:provider/provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  
  await AuthService.loadCookies();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeProvider()),
        ChangeNotifierProvider(create: (_) => PunchProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceHistoryProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Management_App',
      themeMode: ThemeMode.system,

      theme: ThemeData(
        useMaterial3: false, 
        fontFamily: 'poppins',
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
        ),
      ),

     
      darkTheme: ThemeData(
        useMaterial3: false, 
        brightness: Brightness.dark,
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarIconBrightness: Brightness.light,
          ),
        ),
      ),

      home: SplashScreen(),
      initialRoute: '/splashScreen',

      routes: {
        '/splashScreen': (context) => SplashScreen(),
        '/loginScreen': (context) => LoginScreen(),
        '/forgotpasswordScreen': (context) => ForgotpasswordScreen(),
        '/homeMainScreen': (context) => HomemainScreen(),
        '/homeScreen': (context) => HomeScreen(),
        '/settingScreen': (context) => SettingsScreen(),
        '/attendanceScreen': (context) => AttendanceHistoryScreen(),
        '/notificationScreen': (context) => NotificationScreen(),
        '/profileScreen': (context) => Profilescreen(),

        // card screens
        '/leaveRequest': (context) => LeaveRequest(),
        '/leaveRequestDetail': (context) => LeaveRequestdetail(),
        '/leaveApproval': (context) => LeaveApproval(),
        '/attendanceRegularization': (context) => AttendanceRegularization(),
        '/regularizationApproval': (context) => RegularizationApproval(),
        '/regularizationListing': (context) => RegularizationLsiting(),
        '/checkMore': (context) => CheckMore(),
      },
    );
  }
}
