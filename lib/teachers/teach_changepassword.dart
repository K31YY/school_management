import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TeachChangepassword(),
    ),
  );
}

class TeachChangepassword extends StatefulWidget {
  const TeachChangepassword({super.key});

  @override
  State<TeachChangepassword> createState() => _TeachChangepasswordState();
}

class _TeachChangepasswordState extends State<TeachChangepassword> {
  // Colors
  final Color primaryBlue = const Color(0xFF0055FF);
  final Color backgroundGrey = const Color(0xFFF0F0F0);
  final Color alertRed = const Color(
    0xFFFF4D4D,
  ); // For the "Change Password" title

  // State for password visibility toggles
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGrey,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // --- 1. Illustration (Placeholder) ---
            // In a real app, use Image.asset('assets/lock_image.png')
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_reset_rounded,
                size: 60,
                color: Colors.orange[400],
              ),
            ),

            const SizedBox(height: 24),

            // --- 2. Title & Subtitle ---
            Text(
              "Change Password",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: alertRed,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Enter your new password below, you just being extra safe",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),

            const SizedBox(height: 32),

            // --- 3. Form Fields ---

            // Current Password
            _buildPasswordLabel("Current Password"),
            const SizedBox(height: 8),
            _buildPasswordField(
              hintText: "123456",
              isObscured: _obscureCurrent,
              onToggleVisibility: () {
                setState(() {
                  _obscureCurrent = !_obscureCurrent;
                });
              },
            ),

            const SizedBox(height: 16),

            // New Password
            _buildPasswordLabel("New Password"),
            const SizedBox(height: 8),
            _buildPasswordField(
              hintText: "******",
              isObscured: _obscureNew,
              onToggleVisibility: () {
                setState(() {
                  _obscureNew = !_obscureNew;
                });
              },
            ),

            const SizedBox(height: 16),

            // Confirm Password
            _buildPasswordLabel("Confirm Password"),
            const SizedBox(height: 8),
            _buildPasswordField(
              hintText: "******",
              isObscured: _obscureConfirm,
              onToggleVisibility: () {
                setState(() {
                  _obscureConfirm = !_obscureConfirm;
                });
              },
            ),

            const SizedBox(height: 40),

            // --- 4. Action Buttons ---
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[600],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        "Save",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildPasswordLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: primaryBlue, // The labels in this design are Blue
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String hintText,
    required bool isObscured,
    required VoidCallback onToggleVisibility,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryBlue, width: 1), // Blue border
      ),
      child: TextField(
        obscureText: isObscured,
        style: GoogleFonts.poppins(color: Colors.black87),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              isObscured
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: Colors.black87,
              size: 20,
            ),
            onPressed: onToggleVisibility,
          ),
        ),
      ),
    );
  }
}
