import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ungthoung_app/app_colors.dart';

// Make sure these match your exact file names!
import 'package:ungthoung_app/login_user.dart';
import 'package:ungthoung_app/app_dashboard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool isLoggedIn = false;

  try {
    // Read SharedPreferences safely
    final sp = await SharedPreferences.getInstance();
    final String? token = sp.getString('TOKEN');

    // If we have a token, skip login and go to dashboard
    if (token != null && token.isNotEmpty) {
      isLoggedIn = true;
    }
  } catch (e) {
    debugPrint("Startup Error: $e");
  }

  configLoading();
  runApp(MyApp(isLoggedIn: isLoggedIn));
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

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BTB212 App',
      // The routing magic happens right here:
      home: isLoggedIn ? const AppDashboard() : const LoginUser(),
      builder: EasyLoading.init(),
      theme: ThemeData.light().copyWith(
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.button,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 18),
          systemOverlayStyle: SystemUiOverlayStyle.light,
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
    );
  }
}
