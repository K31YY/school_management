import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ungthoung_app/providers/auth_provider.dart';

import 'package:ungthoung_app/app_colors.dart';
import 'package:ungthoung_app/app_dashboard.dart';
import 'package:ungthoung_app/login_user.dart';
import 'package:ungthoung_app/students/student_dashboard.dart';
import 'package:ungthoung_app/teachers/teacher_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  configLoading();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
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

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ung Thoung Buddhist High School',
      builder: EasyLoading.init(),
      theme: ThemeData(
        fontFamily: 'KhmerFonts',
        useMaterial3: true,
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
      home: _getHome(authState),
    );
  }

  Widget _getHome(AuthState auth) {
    if (!auth.isAuthenticated) return const LoginUser();

    switch (auth.role?.toLowerCase().trim()) {
      case 'admin':
        return const AdminDashboard();
      case 'teacher':
        return const TeacherDashboard();
      case 'student':
        return const StudentDashboard();
      default:
        return const LoginUser();
    }
  }
}
