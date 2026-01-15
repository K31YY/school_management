import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ungthoung_app/app_auth.dart';
import 'package:ungthoung_app/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
  configLoading();
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = true
    ..dismissOnTap = false;
  // ..customAnimation = CustomAnimation();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BTB212 App',
      home: const AppAuth(), // startup screen, launcher screen
      builder: EasyLoading.init(),
      theme: ThemeData.light().copyWith(
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.button,
          titleTextStyle: TextStyle(color: AppColors.white, fontSize: 18),
          systemOverlayStyle: SystemUiOverlayStyle.light,
          iconTheme: IconThemeData(color: AppColors.white),
        ),
      ),
    );
  }
}
// Widget (UI Components):
// 1) Stateless Widget
// 2) Statefull Widget

// Material Design (Android)
// Cupertino Design (iOS)
