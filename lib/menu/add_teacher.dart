import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:ungthoung_app/cards/teacher.dart'; // Uncomment if you have this file

class AddTeacher extends StatefulWidget {
  const AddTeacher({super.key});

  @override
  State<AddTeacher> createState() => _AddTeacherState();
}

class _AddTeacherState extends State<AddTeacher> {
  // Colors
  final Color _primaryBlue = const Color(0xFF0D61FF);
  final Color _bgGray = const Color(0xFFF0F0F0);
  final Color _borderColor = const Color(0xFF0D61FF).withOpacity(0.5);

  // State
  int _selectedTabIndex = 0; // 0 = Personal Info, 1 = Professional
  String _selectedGender = "Male"; // Default value for dropdown

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgGray,
      appBar: AppBar(
        backgroundColor: _primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Register Teacher",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Custom Tab Bar (Always visible)
            _buildCustomTabBar(),

            const SizedBox(height: 25),

            // 2. Content Switching Logic
            // If tab 0 is selected, show Personal Info. Otherwise, show Professional.
            _selectedTabIndex == 0
                ? _buildPersonalInfoContent()
                : _buildProfessionalContent(),
          ],
        ),
      ),
    );
  }

  // --- VIEW 1: Personal Info Content ---
  Widget _buildPersonalInfoContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image Placeholder
        Center(
          child: Container(
            width: 100,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black26),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Stack(
              children: [
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Icon(
                    Icons.drive_folder_upload,
                    color: _primaryBlue,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // "Information" Label
        const Text(
          "Information",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),

        // Form Fields
        _buildTextField(hint: "Full Name"),
        const SizedBox(height: 15),

        _buildDropdownField(),
        const SizedBox(height: 15),

        _buildTextField(hint: "2025-11-23", icon: Icons.access_time),
        const SizedBox(height: 15),

        _buildTextField(hint: "Phone Number"),
        const SizedBox(height: 15),

        _buildTextField(hint: "Email (optional)"),
        const SizedBox(height: 15),

        _buildTextField(hint: "Address"),
        const SizedBox(height: 15),

        // Start / End Date Row
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: _borderColor),
          ),
          child: Row(
            children: [
              Expanded(child: _buildDateSubField("Start", "2025-11-29")),
              const SizedBox(width: 15),
              Expanded(child: _buildDateSubField("End", "2026-11-29")),
            ],
          ),
        ),

        const SizedBox(height: 30),

        _buildSaveButton(), // Reusable save button

        const SizedBox(height: 20),
      ],
    );
  }

  // --- VIEW 2: Professional Content ---
  Widget _buildProfessionalContent() {
    return Column(
      children: [
        // Fields specific to the Professional Tab
        _buildTextField(hint: "Certificate"),
        const SizedBox(height: 15),
        _buildTextField(hint: "Skills"),

        // Add spacing to push the button down slightly
        const SizedBox(height: 50),

        _buildSaveButton(),
      ],
    );
  }

  // --- Helper Widgets ---

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: () {
          // Add your save logic here
        },
        child: const Text(
          "Save",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomTabBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = 0),
              child: Container(
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 0
                      ? _primaryBlue
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: _selectedTabIndex == 0
                      ? Border.all(color: Colors.black)
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  "Personal Info",
                  style: TextStyle(
                    color: _selectedTabIndex == 0
                        ? Colors.white
                        : Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = 1),
              child: Container(
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 1
                      ? _primaryBlue
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: _selectedTabIndex == 1
                      ? Border.all(color: Colors.black)
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  "Professional",
                  style: TextStyle(
                    color: _selectedTabIndex == 1
                        ? Colors.white
                        : Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({required String hint, IconData? icon}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _borderColor),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          suffixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedGender,
          isExpanded: true,
          hint: const Text("Gender"),
          items: ["Male", "Female", "Other"].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: TextStyle(color: Colors.grey[700])),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedGender = val);
          },
        ),
      ),
    );
  }

  Widget _buildDateSubField(String label, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 5),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          height: 45,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: _borderColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Text(
                  date,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 10),
                child: Icon(Icons.access_time, size: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
