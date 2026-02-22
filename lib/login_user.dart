import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ungthoung_app/app_dashboard.dart'; // កែឈ្មោះតាម file dashboard របស់អ្នក

class LoginUser extends StatefulWidget {
  const LoginUser({super.key});

  @override
  State<LoginUser> createState() => _LoginUserState();
}

class _LoginUserState extends State<LoginUser> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscure = true;

  // មុខងារ Login តភ្ជាប់ទៅ MySQL API
  Future<void> loginUser() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      EasyLoading.showError('សូមបំពេញព័ត៌មានឱ្យអស់!');
      return;
    }

    // កុំភ្លេចដូរ IP ទៅតាមម៉ាស៊ីន Backend របស់អ្នក (ឧទាហរណ៍: 192.168.1.10)
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
          // --- ចំណុចសំខាន់៖ រក្សាទុកឈ្មោះអ្នកប្រើ (admin01) ចូលក្នុងម៉ាស៊ីន ---
          final sp = await SharedPreferences.getInstance();

          // ទាញយក Username ពីក្នុង Object 'user' នៃ API Response
          String nameFromApi = data['user']['Username'];
          String roleFromApi = data['user']['Role'];

          await sp.setString('FULLNAME', nameFromApi);
          await sp.setString('ROLE', roleFromApi);
          await sp.setString('TOKEN', data['token']);

          if (!mounted) return;

          EasyLoading.showSuccess('ចូលប្រើប្រាស់ជោគជ័យ!');

          // ទៅកាន់ទំព័រ Dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AppDashboard()),
          );
        } else {
          EasyLoading.showError('ឈ្មោះអ្នកប្រើ ឬលេខសម្ងាត់មិនត្រឹមត្រូវ!');
        }
      } else {
        EasyLoading.showError('ការចូលប្រើប្រាស់បរាជ័យ!');
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('មិនអាចភ្ជាប់ទៅកាន់ Server បានទេ!');
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
              // Logo ឬ រូបភាព
              const Icon(Icons.school, size: 100, color: Color(0xFF4A5BF6)),
              const SizedBox(height: 20),
              const Text(
                "Welcome Back",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Login to your account",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),

              // Username Field
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
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
            ],
          ),
        ),
      ),
    );
  }
}
