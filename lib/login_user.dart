import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:ungthoung_app/app_dashboard.dart';
import 'package:ungthoung_app/students/student_dashboard.dart';
import 'package:ungthoung_app/teachers/teacher_dashboard.dart';

class LoginUser extends StatefulWidget {
  const LoginUser({super.key});

  @override
  State<LoginUser> createState() => _LoginUserState();
}

class _LoginUserState extends State<LoginUser> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscured = true;
  final Color _primaryColor = const Color(0xFF4A5BF6);

  Future<void> loginUser() async {
    final loginKey = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (loginKey.isEmpty || password.isEmpty) {
      EasyLoading.showError('Please enter both username and password!');
      return;
    }

    final url = Uri.parse('http://10.0.2.2:8000/api/login');

    try {
      EasyLoading.show(status: 'Logging in...');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'LoginKey': loginKey, 'Password': password}),
      );

      EasyLoading.dismiss();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          final sp = await SharedPreferences.getInstance();

          if (data['user'] != null && data['user']['id'] != null) {
            final uId = int.parse(data['user']['id'].toString());
            await sp.setInt('USER_ID_KEY', uId);
          }

          await sp.setString('TOKEN', data['token'] ?? "");
          await sp.setString('ROLE', data['role'] ?? "");
          await sp.setString('FULLNAME', data['display_name'] ?? "User");

          EasyLoading.showSuccess('Welcome!');

          final role = data['role']?.toString().toLowerCase() ?? "";
          Widget nextScreen;

          if (role == 'admin') {
            nextScreen = const AdminDashboard();
          } else if (role == 'teacher') {
            nextScreen = const TeacherDashboard();
          } else {
            nextScreen = const StudentDashboard();
          }

          if (!mounted) return;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => nextScreen),
          );
        } else {
          EasyLoading.showError(data['message'] ?? 'Login failed!');
        }
      } else {
        EasyLoading.showError('Invalid Username or Password!');
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('Failed to connect to Server!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school_rounded, size: 100, color: _primaryColor),
              const SizedBox(height: 10),
              const Text(
                "Ung Thoung Buddhist",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142),
                ),
                textAlign: TextAlign.center,
              ),
              const Text(
                "High School Management System",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 50),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: "Username or Email",
                  prefixIcon: const Icon(Icons.person_outline),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: _isObscured,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscured ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () => setState(() => _isObscured = !_isObscured),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: loginUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    "LOGIN",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
