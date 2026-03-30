import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ungthoung_app/admin/app_dashboard.dart';
import 'package:ungthoung_app/module/auth/login_user.dart';

class AppAuth extends StatelessWidget {
  const AppAuth({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, data) {
        if (data.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (data.hasData) {
          return const AdminDashboard();
        }
        return const LoginUser();
      },
    );
  }
}
