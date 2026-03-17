import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ungthoung_app/app_colors.dart';
import 'package:ungthoung_app/app_dashboard.dart';
import 'package:ungthoung_app/login_user.dart';

import 'package:ungthoung_app/students/student_dashboard.dart';
import 'package:ungthoung_app/teachers/teacher_dashboard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (required for signup_user.dart and app_auth.dart)
  await Firebase.initializeApp();

  String? userRole;
  bool isLoggedIn = false;

  try {
    final sp = await SharedPreferences.getInstance();
    final String? token = sp.getString(
      'TOKEN',
    ); // Fixed: was 'token', must match 'TOKEN' saved in login_user.dart
    userRole = sp.getString('ROLE');
    if (token != null && token.isNotEmpty) {
      isLoggedIn = true;
    }
  } catch (e) {
    debugPrint("Startup Error: $e");
  }

  configLoading();
  runApp(MyApp(isLoggedIn: isLoggedIn, role: userRole));
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = AppColors.bgColor
    ..backgroundColor = AppColors.bgColor
    ..indicatorColor = Colors.white
    ..textColor = Colors.white
    ..maskColor = Colors.blue
    ..userInteractions = true
    ..dismissOnTap = false;
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String? role;

  const MyApp({super.key, required this.isLoggedIn, this.role});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ung Thoung Buddhist High School',
      // Using a global key for navigation is helpful for 401 interceptors later
      builder: EasyLoading.init(),
      theme: ThemeData(
        useMaterial3: true, // Recommended for 2026 Flutter apps
        primaryColor: AppColors.bgColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.button,
          centerTitle: true,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
      ),
      home: _getHome(),
    );
  }

  Widget _getHome() {
    if (!isLoggedIn) return const LoginUser();

    final normalizedRole = role?.toLowerCase().trim();

    switch (normalizedRole) {
      case 'admin':
        return const AdminDashboard();
      case 'teacher':
        return const TeacherDashboard();
      case 'student':
        return const StudentDashboard();
      default:
        // If logged in but role is missing/corrupt, force re-login
        return const LoginUser();
    }
  }
}
