import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:flutter_easyloading/flutter_easyloading.dart';
// Ensure these paths match your project structure exactly
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

        // Inside loginUser() after successful API call
        if (data['success'] == true) {
          final userData = data['user'];

          // 1. Extract role carefully
          final String role = (data['role'] ?? userData?['role'] ?? "")
              .toString();
          final String token = data['token'] ?? "";
          final String fullName =
              data['display_name'] ?? userData?['name'] ?? "User";
          final int uId = int.tryParse(userData?['id']?.toString() ?? "0") ?? 0;

          // 2. Update Global State
          // This call tells main.dart: "Hey, we have a new user and they are an ADMIN"
          await ref
              .read(authProvider.notifier)
              .updateAuth(
                token: token,
                role: role,
                fullName: fullName,
                userId: uId,
              );
          EasyLoading.showSuccess('Welcome, $fullName!');
        } else {
          EasyLoading.showError(data['message'] ?? 'Login failed!');
        }
      } else {
        EasyLoading.showError('Invalid Username or Password!');
      }
    } catch (e) {
      EasyLoading.dismiss();
      debugPrint("Login Error: $e");
      EasyLoading.showError('Connection Error: Check your backend.');
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
              Text(
                "Ung Thoung Buddhist",
                style: TextStyle(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const Text(
                "High School Management System",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 50),
              _buildTextField(
                controller: _usernameController,
                label: "Username or Email",
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _passwordController,
                label: "Password",
                icon: Icons.lock_outline,
                isPassword: true,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? _isObscured : false,
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _primaryColor, width: 2),
          borderRadius: BorderRadius.circular(15),
        ),
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isObscured ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () => setState(() => _isObscured = !_isObscured),
              )
            : null,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
