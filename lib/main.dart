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
import 'package:management_app/utils/systembars_utils.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

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
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

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
      ),

      darkTheme: ThemeData(
        useMaterial3: false,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
      ),

      builder: (context, child) {
        SystembarUtil.setSystemBar(context);
        return child!;
      },

      initialRoute: initialRoute,

      routes: {
        '/splashScreen': (_) => const SplashScreen(),
        '/loginScreen': (_) => const LoginScreen(),
        '/forgotpasswordScreen': (_) => const ForgotpasswordScreen(),
        '/homeMainScreen': (_) => const HomemainScreen(),
        '/homeScreen': (_) => const HomeScreen(),
        '/settingScreen': (_) => const SettingsScreen(),
        '/notificationScreen': (_) => const NotificationScreen(),
        '/profileScreen': (_) => const Profilescreen(),
        '/attendanceScreen': (_) => const AttendanceScreen(),
        '/leaveRequest': (_) => const LeaveRequest(),
        '/leaveRequestDetail': (_) => const LeaveRequestdetail(),
        '/leaveApproval': (_) => const LeaveApproval(),
        '/attendanceRequest': (_) => const AttendanceRequestScreen(),
        '/travelRequest': (_) => const TravelRequestScreen(),
        '/regularizationListing': (_) => const RegularizationLsiting(),
        '/checkMore': (_) => const CheckMore(),
      },

      onUnknownRoute: (_) =>
          MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }
}
