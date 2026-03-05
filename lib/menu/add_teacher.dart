// ignore_for_file: avoid_print

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddTeacher extends StatefulWidget {
  const AddTeacher({super.key});

  @override
  State<AddTeacher> createState() => _AddTeacherState();
}

class _AddTeacherState extends State<AddTeacher> {
  final Color _primaryBlue = const Color(0xFF4A5BF6);
  final Color _borderColor = const Color(0xFF0D61FF);
  final Color _bgGray = const Color(0xFFF5F5F5);

  int _selectedTabIndex = 0;
  String _selectedGender = "Male";
  File? _imageFile;

  // Controllers for TextFields
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _addressCtrl = TextEditingController();
  final TextEditingController _dobCtrl = TextEditingController();
  final TextEditingController _startDateCtrl = TextEditingController();
  final TextEditingController _endDateCtrl = TextEditingController();
  final TextEditingController _certCtrl = TextEditingController();
  final TextEditingController _skillCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _dobCtrl.dispose();
    _startDateCtrl.dispose();
    _endDateCtrl.dispose();
    _certCtrl.dispose();
    _skillCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) setState(() => _imageFile = File(pickedFile.path));
  }

  Future<void> _pickDate(
    BuildContext context,
    TextEditingController ctrl,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => ctrl.text = DateFormat('yyyy-MM-dd').format(picked));
    }
  }

  Future<void> _handleSave() async {
    if (_nameCtrl.text.isEmpty) {
      EasyLoading.showError("Please enter teacher name!");
      return;
    }

    EasyLoading.show(status: 'Saving...');

    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      int? userId = prefs.getInt('user_id');
      if (token == null || token.isEmpty) {
        EasyLoading.dismiss();
        EasyLoading.showError("Token does not exist! Please login again.");
        return;
      }

      // Make Multipart Request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://10.0.2.2:8000/api/teachers'), // use api for emulator
      );

      // Add Headers (Authorization)
      request.headers.addAll({
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      });

      // Add Fields
      request.fields['UserID'] = userId?.toString() ?? "1";
      request.fields['TeacherName'] = _nameCtrl.text;
      request.fields['Gender'] = _selectedGender;
      request.fields['DOB'] = _dobCtrl.text;
      request.fields['Phone'] = _phoneCtrl.text;
      request.fields['Email'] = _emailCtrl.text;
      request.fields['Address'] = _addressCtrl.text;
      request.fields['StartDate'] = _startDateCtrl.text;
      request.fields['EndDate'] = _endDateCtrl.text;
      request.fields['Specialty'] = _skillCtrl.text;
      request.fields['Certificate'] = _certCtrl.text;

      // Send Image if exists
      if (_imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('Photo', _imageFile!.path),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      EasyLoading.dismiss();

      if (response.statusCode == 201 || response.statusCode == 200) {
        EasyLoading.showSuccess("Teacher registered successfully!");
        if (!mounted) return;
        Navigator.pop(context);
      } else if (response.statusCode == 401) {
        EasyLoading.showError(
          "Unauthorized! Please login again.",
        ); // For 401 Unauthorized, show specific message
      } else if (response.statusCode == 422) {
        // 422 Unprocessable Entity usually means validation error from server
        print("Validation Error: ${response.body}");
        EasyLoading.showError("Validation error occurred!");
      } else {
        print(
          "Server Error: ${response.body}",
        ); // Log server response for debugging
        EasyLoading.showError("Server error: ${response.statusCode}");
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError("Failed to connect to server!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgGray,
      appBar: AppBar(
        backgroundColor: _primaryBlue,
        title: const Text(
          "Register Teacher",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildCustomTabBar(),
            const SizedBox(height: 25),
            _selectedTabIndex == 0
                ? _buildPersonalInfo()
                : _buildProfessionalInfo(),
          ],
        ),
      ),
    );
  }

  // --- UI Components ---
  Widget _buildCustomTabBar() {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [_tabItem("Personal Info", 0), _tabItem("Professional", 1)],
      ),
    );
  }

  Widget _tabItem(String title, int index) {
    bool isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? _primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfo() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: 100,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black26),
              image: _imageFile != null
                  ? DecorationImage(
                      image: FileImage(_imageFile!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: _imageFile == null
                ? const Icon(Icons.add_a_photo, size: 40, color: Colors.grey)
                : null,
          ),
        ),
        const SizedBox(height: 20),
        _buildTextField(hint: "Full Name", controller: _nameCtrl),
        const SizedBox(height: 15),
        _buildDropdown(),
        const SizedBox(height: 15),
        _buildTextField(
          hint: "DOB (YYYY-MM-DD)",
          icon: Icons.calendar_today,
          controller: _dobCtrl,
          onTap: () => _pickDate(context, _dobCtrl),
        ),
        const SizedBox(height: 15),
        _buildTextField(hint: "Phone Number", controller: _phoneCtrl),
        const SizedBox(height: 15),
        _buildTextField(hint: "Email", controller: _emailCtrl),
        const SizedBox(height: 15),
        _buildTextField(hint: "Address", controller: _addressCtrl),
        const SizedBox(height: 15),
        _buildDateRange(),
        const SizedBox(height: 30),
        _buildSaveButton(),
      ],
    );
  }

  Widget _buildProfessionalInfo() {
    return Column(
      children: [
        _buildTextField(hint: "Certificate", controller: _certCtrl),
        const SizedBox(height: 15),
        _buildTextField(hint: "Skills", controller: _skillCtrl),
        const SizedBox(height: 50),
        _buildSaveButton(),
      ],
    );
  }

  Widget _buildTextField({
    required String hint,
    IconData? icon,
    TextEditingController? controller,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _borderColor),
      ),
      child: TextField(
        controller: controller,
        readOnly: onTap != null,
        onTap: onTap,
        decoration: InputDecoration(
          hintText: hint,
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

  Widget _buildDropdown() {
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
          items: [
            "Male",
            "Female",
            "Other",
          ].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
          onChanged: (v) => setState(() => _selectedGender = v!),
        ),
      ),
    );
  }

  Widget _buildDateRange() {
    return Row(
      children: [
        Expanded(
          child: _buildTextField(
            hint: "Start",
            icon: Icons.event,
            controller: _startDateCtrl,
            onTap: () => _pickDate(context, _startDateCtrl),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildTextField(
            hint: "End",
            icon: Icons.event,
            controller: _endDateCtrl,
            onTap: () => _pickDate(context, _endDateCtrl),
          ),
        ),
      ],
    );
  }

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
        onPressed: _handleSave,
        child: const Text(
          "SAVE DATA",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
