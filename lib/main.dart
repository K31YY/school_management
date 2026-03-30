import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ungthoung_app/providers/auth_provider.dart';
import 'package:ungthoung_app/themes/app_colors.dart';
import 'package:ungthoung_app/admin/app_dashboard.dart';
import 'package:ungthoung_app/module/auth/login_user.dart';
import 'package:ungthoung_app/students/student_dashboard.dart';
import 'package:ungthoung_app/teachers/teacher_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  configLoading();
  runApp(const ProviderScope(child: MyApp()));
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
    // 1. Loading state check (if your provider supports it)
    if (auth.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 2. Authentication check
    if (!auth.isAuthenticated) return const LoginUser();

    // 3. ANALYTICAL FIX: Normalize role and use .contains()
    final String role = auth.role?.toLowerCase().trim() ?? "";

    if (role.contains('admin')) {
      // This will now catch 'admin', 'admin01', and your specific 'admin02'
      return const AdminDashboard();
    } else if (role.contains('teacher')) {
      return const TeacherDashboard();
    } else if (role.contains('student')) {
      return const StudentDashboard();
    } else {
      // If the role is truly unknown, show a clear error or return to login
      return const Scaffold(
        body: Center(child: Text("Role Not Recognized. Please contact admin.")),
      );
    }
  }
}
