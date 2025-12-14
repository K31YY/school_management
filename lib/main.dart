import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ungthoung_app/app_colors.dart';
import 'package:ungthoung_app/login_user.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BTB212 App',
      home: const LoginUser(), // startup screen, launcher screen
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
