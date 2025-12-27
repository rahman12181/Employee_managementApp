import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:management_app/card_screen/check_more.dart';
import 'package:management_app/card_screen/leave_approval.dart';
import 'package:management_app/card_screen/leaverequest.dart';
import 'package:management_app/card_screen/leaverequestdetail.dart';
import 'package:management_app/card_screen/regularization_lsiting.dart';
import 'package:management_app/providers/attendance_provider.dart';
import 'package:management_app/providers/employee_provider.dart';
import 'package:management_app/providers/profile_provider.dart';
import 'package:management_app/providers/punch_provider.dart';
import 'package:management_app/screen/HomeMain_Screen.dart';
import 'package:management_app/screen/attendance_request_screen.dart';
import 'package:management_app/screen/attendance_screen.dart';
import 'package:management_app/screen/forgotPassword_screen.dart';
import 'package:management_app/screen/home_screen.dart';
import 'package:management_app/screen/login_screen.dart';
import 'package:management_app/screen/notification_screen.dart';
import 'package:management_app/screen/profilescreen.dart';
import 'package:management_app/screen/setting_screen.dart';
import 'package:management_app/screen/splash_screen.dart';
import 'package:management_app/screen/travel_request_screen.dart';
import 'package:management_app/services/auth_service.dart';
import 'package:provider/provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );
  
  await AuthService.loadCookies();
  final authService = AuthService();
  final initialRoute = await authService.getInitialRoute();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeProvider()),
        ChangeNotifierProvider(create: (_) => PunchProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
      ],
      child: MyApp(initialRoute: initialRoute),
    ),
  );
}
class MyApp extends StatelessWidget {
  const MyApp({super.key, required String initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pioneer',
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

      home: const SplashScreen(),
      initialRoute: '/splashScreen',

      routes: {
        '/splashScreen': (context) => const SplashScreen(),
        '/loginScreen': (context) => const LoginScreen(),
        '/forgotpasswordScreen': (context) => const ForgotpasswordScreen(),
        '/homeMainScreen': (context) => const HomemainScreen(),
        '/homeScreen': (context) => const HomeScreen(),
        '/settingScreen': (context) => const SettingsScreen(),
        '/notificationScreen': (context) => const NotificationScreen(),
        '/profileScreen': (context) => const Profilescreen(),
        '/attendanceScreen': (context) => const AttendanceScreen(),

        // card screens
        '/leaveRequest': (context) => const LeaveRequest(),
        '/leaveRequestDetail': (context) => const LeaveRequestdetail(),
        '/leaveApproval': (context) => const LeaveApproval(),
        '/attendanceRequest': (context) => const AttendanceRequestScreen(),
        '/travelRequest' : (context) => const TravelRequestScreen(),
        '/regularizationListing': (context) => const RegularizationLsiting(),
        '/checkMore': (context) => const CheckMore(),
      },
    );
  }
}
