// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  // Logic: Form Key for validation
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _currentPassCtrl = TextEditingController();
  final TextEditingController _newPassCtrl = TextEditingController();
  final TextEditingController _confirmPassCtrl = TextEditingController();

  final Color primaryBlue = const Color(0xFF4A5BF6);
  final Color backgroundGrey = const Color(0xFFF0F0F0);
  final Color alertRed = const Color(0xFFFF4D4D);

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    // Logic: Trigger internal TextFormField validators
    if (!_formKey.currentState!.validate()) {
      return;
    }

    EasyLoading.show(status: 'Updating...');

    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('TOKEN');

      // Analytical Note: body keys match your Laravel AuthController requirements
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/change-password'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: {
          'current_password': _currentPassCtrl.text,
          'password': _newPassCtrl.text,
          'password_confirmation': _confirmPassCtrl.text,
        },
      );

      EasyLoading.dismiss();

      if (response.statusCode == 200) {
        EasyLoading.showSuccess("Password updated!");
        if (mounted) Navigator.pop(context);
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final errorMsg = responseData['message'] ?? "Failed to update";
        EasyLoading.showError(errorMsg);
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError("Network Error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGrey,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Change Password",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Form(
          key: _formKey, // Attach the form key here
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildHeaderIcon(),
              const SizedBox(height: 24),
              Text(
                "Update Security",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: alertRed,
                ),
              ),
              const SizedBox(height: 32),
              _buildTextFormField(
                label: "Current Password",
                controller: _currentPassCtrl,
                obscure: _obscureCurrent,
                toggle: () =>
                    setState(() => _obscureCurrent = !_obscureCurrent),
                validator: (value) =>
                    value!.isEmpty ? "Enter current password" : null,
              ),
              const SizedBox(height: 20),
              _buildTextFormField(
                label: "New Password",
                controller: _newPassCtrl,
                obscure: _obscureNew,
                toggle: () => setState(() => _obscureNew = !_obscureNew),
                validator: (value) {
                  if (value!.isEmpty) return "Enter new password";
                  if (value.length < 6) return "Must be at least 6 characters";
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildTextFormField(
                label: "Confirm New Password",
                controller: _confirmPassCtrl,
                obscure: _obscureConfirm,
                toggle: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
                validator: (value) {
                  if (value != _newPassCtrl.text)
                    return "Passwords do not match";
                  return null;
                },
              ),
              const SizedBox(height: 40),
              _buildButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderIcon() => Container(
    height: 100,
    width: 100,
    decoration: BoxDecoration(color: Colors.blue[50], shape: BoxShape.circle),
    child: Icon(Icons.lock_reset_rounded, size: 50, color: Colors.orange[400]),
  );

  Widget _buildTextFormField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback toggle,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: GoogleFonts.poppins(fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        hintText: "Enter $label",
        labelStyle: TextStyle(color: primaryBlue, fontWeight: FontWeight.w500),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryBlue),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: Colors.grey,
          ),
          onPressed: toggle,
        ),
      ),
    );
  }

  Widget _buildButtons() => Row(
    children: [
      Expanded(
        child: OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.red[500],
            padding: const EdgeInsets.symmetric(vertical: 15),
            side: BorderSide(color: Colors.red),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            "Cancel",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: ElevatedButton(
          onPressed: _handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: const Text(
            "Save Changes",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    ],
  );
}
