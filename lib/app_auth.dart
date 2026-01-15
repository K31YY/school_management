import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ungthoung_app/app_dashboard.dart';
import 'package:ungthoung_app/login_user.dart';

class AppAuth extends StatelessWidget {
  const AppAuth({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, data) {
        if (data.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (data.hasData) {
          return const AppDashboard();
        }
        return const LoginUser();
      },
    );
  }
}
