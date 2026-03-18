// ignore_for_file: avoid_print, curly_braces_in_flow_control_structures

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

  final Color _bgGray = const Color(0xFFF5F5F5);

  int _selectedTabIndex = 0;

  String _selectedGender = "Male";

  File? _imageFile;

  bool _isObscure = true;

  int? _currentUserId;

  final TextEditingController _rollNoCtrl = TextEditingController();

  final TextEditingController _nameCtrl = TextEditingController();

  final TextEditingController _phoneCtrl = TextEditingController();

  final TextEditingController _emailCtrl = TextEditingController();

  final TextEditingController _passwordCtrl = TextEditingController();

  final TextEditingController _addressCtrl = TextEditingController();

  final TextEditingController _dobCtrl = TextEditingController();

  final TextEditingController _startDateCtrl = TextEditingController();

  final TextEditingController _endDateCtrl = TextEditingController();

  final TextEditingController _certCtrl = TextEditingController();

  final TextEditingController _skillCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    _fetchUserId();
  }

  Future<void> _fetchUserId() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Make sure this key matches exactly what you saved in LoginUser.dart

    // If you saved it as 'ID', change this to 'ID'.

    int? id = prefs.getInt('USER_ID_KEY');

    if (id != null) {
      if (mounted) {
        setState(() {
          _currentUserId = id;

          _rollNoCtrl.text = id.toString();
        });
      }
    } else {
      // 2. If it's null, check if it was accidentally saved as a String

      String? idStr = prefs.getString('USER_ID_KEY');

      if (idStr != null) {
        setState(() {
          _currentUserId = int.tryParse(idStr);

          _rollNoCtrl.text = idStr;
        });
      } else {
        _rollNoCtrl.text = "ID Missing";
      }
    }
  }

  @override
  void dispose() {
    _rollNoCtrl.dispose();

    _nameCtrl.dispose();

    _phoneCtrl.dispose();

    _emailCtrl.dispose();

    _passwordCtrl.dispose();

    _addressCtrl.dispose();

    _dobCtrl.dispose();

    _startDateCtrl.dispose();

    _endDateCtrl.dispose();

    _certCtrl.dispose();

    _skillCtrl.dispose();

    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_nameCtrl.text.isEmpty) {
      EasyLoading.showError("Please enter the name!");

      return;
    }

    EasyLoading.show(status: 'Saving...');

    try {
      final prefs = await SharedPreferences.getInstance();

      // Use the token from SharedPreferences or Provider

      String? token = prefs.getString('TOKEN');

      var request = http.MultipartRequest(
        'POST',

        Uri.parse('http://10.0.2.2:8000/api/teachers'),
      );

      // 1. Headers

      request.headers.addAll({
        "Authorization": "Bearer $token",

        "Accept": "application/json",
      });

      // 2. Body Fields

      // Ensure 'user_id' matches the column name in your database

      request.fields['user_id'] = _currentUserId?.toString() ?? "";

      request.fields['TeacherName'] = _nameCtrl.text;

      request.fields['Gender'] = _selectedGender;

      request.fields['DOB'] = _dobCtrl.text;

      request.fields['Phone'] = _phoneCtrl.text;

      request.fields['Email'] = _emailCtrl.text;

      request.fields['Password'] = _passwordCtrl.text;

      request.fields['Address'] = _addressCtrl.text;

      request.fields['StartDate'] = _startDateCtrl.text;

      request.fields['EndDate'] = _endDateCtrl.text;

      request.fields['Specialty'] = _skillCtrl.text;

      request.fields['Certificate'] = _certCtrl.text;

      // 3. Photo

      if (_imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('Photo', _imageFile!.path),
        );
      }

      var streamedResponse = await request.send();

      var response = await http.Response.fromStream(streamedResponse);

      EasyLoading.dismiss();

      if (response.statusCode == 200 || response.statusCode == 201) {
        EasyLoading.showSuccess("Saved Successfully!");

        if (mounted) Navigator.pop(context);
      } else {
        // Print the error body to see what the server is complaining about

        print("Server Error Body: ${response.body}");

        EasyLoading.showError("Error: ${response.statusCode}");
      }
    } catch (e) {
      EasyLoading.dismiss();

      EasyLoading.showError("Connection failed!");

      print("Error details: $e");
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

  Widget _buildPersonalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Center(
          child: GestureDetector(
            onTap: _pickImage,

            child: Container(
              width: 110,

              height: 130,

              decoration: BoxDecoration(
                color: Colors.white,

                border: Border.all(color: Colors.black12),

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
        ),

        const SizedBox(height: 20),

        const Text(
          "Personal Information",

          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 15),

        _buildTextField(
          hint: "UserID",

          controller: _rollNoCtrl,

          readOnly: true,

          fillColor: Colors.grey[200],
        ),

        const SizedBox(height: 15),

        _buildTextField(hint: "Enter Full Name", controller: _nameCtrl),

        const SizedBox(height: 15),

        _buildDropdown(),

        const SizedBox(height: 15),

        _buildTextField(
          hint: "YYYY-MM-DD",

          icon: Icons.calendar_today,

          controller: _dobCtrl,

          onTap: () => _pickDate(context, _dobCtrl),
        ),

        const SizedBox(height: 15),

        _buildTextField(hint: "Enter email", controller: _emailCtrl),

        const SizedBox(height: 15),

        _buildTextField(
          hint: "Enter password",

          controller: _passwordCtrl,

          isPassword: true,
        ),

        const SizedBox(height: 15),

        _buildTextField(hint: "Enter phone number", controller: _phoneCtrl),

        const SizedBox(height: 15),

        _buildTextField(
          hint: "Enter address",

          controller: _addressCtrl,

          icon:
              Icons.location_on_outlined, // Optional: matches the address theme
        ),

        // --- NEW: Start Date and End Date Row ---
        const SizedBox(height: 15),

        Row(
          children: [
            Expanded(
              child: _buildTextField(
                hint: "Start",

                icon: Icons.calendar_today,

                controller: _startDateCtrl,

                onTap: () => _pickDate(context, _startDateCtrl),
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: _buildTextField(
                hint: "End",

                icon: Icons.calendar_today,

                controller: _endDateCtrl,

                onTap: () => _pickDate(context, _endDateCtrl),
              ),
            ),
          ],
        ),

        // ----------------------------------------
        const SizedBox(height: 30),

        _buildSaveButton(),
      ],
    );
  }

  // --- UI Helpers ---

  Widget _buildTextField({
    required String hint,

    IconData? icon,

    TextEditingController? controller,

    VoidCallback? onTap,

    bool readOnly = false,

    Color? fillColor,

    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: fillColor ?? Colors.white,

        borderRadius: BorderRadius.circular(15),

        border: Border.all(color: Colors.blue.shade400),
      ),

      child: TextField(
        controller: controller,

        obscureText: isPassword ? _isObscure : false,

        readOnly: readOnly || onTap != null,

        onTap: onTap,

        decoration: InputDecoration(
          hintText: hint,

          border: InputBorder.none,

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,

            vertical: 12,
          ),

          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isObscure ? Icons.visibility : Icons.visibility_off,

                    color: Colors.grey,
                  ),

                  onPressed: () => setState(() => _isObscure = !_isObscure),
                )
              : (icon != null ? Icon(icon, color: Colors.grey) : null),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 5, left: 5),

    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
  );

  Widget _buildProfessionalInfo() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,

    children: [
      const Text(
        "Professional Details",

        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),

      const SizedBox(height: 15),

      _buildLabel("Certificate *"),

      _buildTextField(hint: "Enter certificate", controller: _certCtrl),

      const SizedBox(height: 15),

      _buildLabel("Skills *"),

      _buildTextField(hint: "Enter skills", controller: _skillCtrl),

      const SizedBox(height: 50),

      _buildSaveButton(),
    ],
  );

  Widget _buildDropdown() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 15),

    decoration: BoxDecoration(
      color: Colors.white,

      borderRadius: BorderRadius.circular(15),

      border: Border.all(color: Colors.blue.shade400),
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

  Widget _buildCustomTabBar() => Container(
    height: 45,

    decoration: BoxDecoration(
      color: Colors.grey[300],

      borderRadius: BorderRadius.circular(25),
    ),

    child: Row(
      children: [_tabItem("Personal Info", 0), _tabItem("Professional", 1)],
    ),
  );

  Widget _tabItem(String title, int index) => Expanded(
    child: GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),

      child: Container(
        alignment: Alignment.center,

        decoration: BoxDecoration(
          color: _selectedTabIndex == index ? _primaryBlue : Colors.transparent,

          borderRadius: BorderRadius.circular(25),
        ),

        child: Text(
          title,

          style: TextStyle(
            color: _selectedTabIndex == index ? Colors.white : Colors.black,

            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );

  Widget _buildSaveButton() => SizedBox(
    width: double.infinity,

    height: 50,

    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryBlue,

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),

      onPressed: _handleSave,

      child: const Text(
        "SAVE",

        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    ),
  );

  // --- Date Picker Method ---

  Future<void> _pickDate(
    BuildContext context,

    TextEditingController controller,
  ) async {
    DateTime? picked = await showDatePicker(
      context: context,

      initialDate: DateTime.now(),

      firstDate: DateTime(1950),

      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  // --- Image Picker Method ---

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }
}
