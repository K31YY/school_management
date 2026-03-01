import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ungthoung_app/app_colors.dart';
import 'package:ungthoung_app/app_dashboard.dart';
import 'package:ungthoung_app/signup_user.dart';
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
  bool _isObscure = true;

  // Login to API Laravel
  Future<void> loginUser() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      EasyLoading.showError('please fill in all fields!');
      return;
    }

    final url = Uri.parse('http://10.0.2.2:8000/api/login');

    try {
      EasyLoading.show(status: 'Login...');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'Username': username, 'Password': password}),
      );

      EasyLoading.dismiss();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          final sp = await SharedPreferences.getInstance();

          // Get user info from API response
          String nameFromApi = data['user']['Username'];
          String roleFromApi = data['user']['Role']; 
          String tokenFromApi = data['token'];

          // Save user info to SharedPreferences
          await sp.setString('FULLNAME', nameFromApi);
          await sp.setString('ROLE', roleFromApi);
          await sp.setString('TOKEN', tokenFromApi);

          if (!mounted) return;

          EasyLoading.showSuccess('Login successful!');

          // Add logic to navigate to different dashboards based on user role
          Widget nextScreen;

          // Update this logic to match your actual role values from the API
          if (roleFromApi == 'Admin') {
            nextScreen = const AdminDashboard(); 
          } else if (roleFromApi == 'Teacher') {
            nextScreen = const TeacherDashboard();
          } else if (roleFromApi == 'Student') {
            nextScreen = const StudentDashboard();
          } else {
            nextScreen = const AdminDashboard();
          }

          // push replacement to prevent going back to login screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => nextScreen),
          );
          // ---------------------------------------------
          
        } else {
          EasyLoading.showError('Invalid username or password!');
        }
      } else {
        EasyLoading.showError('Login failed!');
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('An error occurred during login!');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            children: [
              const SizedBox(height: 80),
              const Icon(Icons.school, size: 100, color: Color(0xFF4A5BF6)),
              const SizedBox(height: 20),
              const Text(
                "Ung Thoung Buddhist",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const Text(
                "High School",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                  fontSize: 18,),
              ),
              const SizedBox(height: 40),

              // Username Field
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.blue,
                  labelText: "Username",
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Password Field
              TextField(
                controller: _passwordController,
                obscureText: _isObscure,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.blue,
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscure ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () => setState(() => _isObscure = !_isObscure),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: loginUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A5BF6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
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
              const SizedBox(height: 25),
              const Text(
                "Forgot Password?",
                style: TextStyle(color: Colors.blue),
              ),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text("Don't have an account?"),
                  const SizedBox(width: 5),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignupUser(),
                        ),
                      );
                    },
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
