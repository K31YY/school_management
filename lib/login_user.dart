import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ungthoung_app/providers/auth_provider.dart';
import 'package:ungthoung_app/services/api_service.dart';

class LoginUser extends ConsumerStatefulWidget {
  const LoginUser({super.key});

  @override
  ConsumerState<LoginUser> createState() => _LoginUserState();
}

class _LoginUserState extends ConsumerState<LoginUser> {
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

    try {
      EasyLoading.show(status: 'Logging in...');

      final response = await ref.read(apiServiceProvider).post('login', {
        'LoginKey': loginKey,
        'Password': password,
      });

      EasyLoading.dismiss();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          final userData = data['user'];
          final uId = int.tryParse(userData?['id']?.toString() ?? "0") ?? 0;

          await ref.read(authProvider.notifier).updateAuth(
                token: data['token'] ?? "",
                role: data['role'] ?? "",
                fullName: data['display_name'] ?? "User",
                userId: uId,
              );

          EasyLoading.showSuccess('Welcome!');
          // Navigation happens automatically via main.dart watching authProvider
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
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                  fontSize: 18,),
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
