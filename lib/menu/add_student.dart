// ignore_for_file: avoid_print, curly_braces_in_flow_control_structures, use_build_context_synchronously, unused_field

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddStudent extends StatefulWidget {
  const AddStudent({super.key});

  @override
  State<AddStudent> createState() => _AddStudentState();
}

class _AddStudentState extends State<AddStudent> {
  final Color _primaryBlue = const Color(0xFF4A5BF6);
  final Color _bgGray = const Color(0xFFF5F5F5);

  int _selectedTabIndex = 0;
  String _selectedGender = "Male";
  String _selectedStatus = "1";
  File? _imageFile;
  int? _currentUserId;

  // Controllers
  final TextEditingController _rollNoCtrl =
      TextEditingController();
  final TextEditingController _nameKhCtrl = TextEditingController();
  final TextEditingController _nameEnCtrl = TextEditingController();
  final TextEditingController _stuNameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _pobCtrl = TextEditingController();
  final TextEditingController _dobCtrl = TextEditingController();
  final TextEditingController _promotionCtrl = TextEditingController();
  final TextEditingController _addressCtrl = TextEditingController();

  final TextEditingController _fatherNameCtrl = TextEditingController();
  final TextEditingController _fatherJobCtrl = TextEditingController();
  final TextEditingController _motherNameCtrl = TextEditingController();
  final TextEditingController _motherJobCtrl = TextEditingController();
  final TextEditingController _familyContactCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserId();
  }

  // Fix: Show only the ID number (e.g., 1)
  Future<void> _fetchUserId() async {
    final prefs = await SharedPreferences.getInstance();
    int? id = prefs.getInt('USER_ID_KEY');
    if (id != null) {
      setState(() {
        _currentUserId = id;
        _rollNoCtrl.text = id.toString();
      });
    }
  }

  Future<void> _handleSave() async {
    // 1. Validation - Ensure required fields are not empty
    if (_nameEnCtrl.text.isEmpty ||
        _emailCtrl.text.isEmpty ||
        _passwordCtrl.text.isEmpty) {
      EasyLoading.showError("Please fill Name, Email, and Password");
      return;
    }

    EasyLoading.show(status: 'Saving...');

    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('TOKEN');

      // Use your specific local IP or 10.0.2.2 for Emulator
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://10.0.2.2:8000/api/students'),
      );

      // 2. CRITICAL HEADERS (Postman adds these automatically, Flutter needs them)
      request.headers.addAll({
        "Authorization": "Bearer $token",
        "Accept": "application/json", // This prevents the 500 redirect error
      });

      // 3. ADD FIELDS (Must match your Postman keys exactly)
      request.fields.addAll({
        'UserID':
            _currentUserId?.toString() ?? "1", // Ensure this is a valid ID
        'StuName':
            "${_nameEnCtrl.text} (${_nameKhCtrl.text})", // Matches Postman style
        'StuNameKH': _nameKhCtrl.text,
        'StuNameEN': _nameEnCtrl.text,
        'Gender': _selectedGender, // e.g., "Male"
        'DOB': _dobCtrl.text, // e.g., "2008-01-01"
        'POB': _pobCtrl.text,
        'Address': _addressCtrl.text,
        'Phone': _phoneCtrl.text,
        'Email': _emailCtrl.text,
        'password': _passwordCtrl.text,
        'Promotion': _promotionCtrl.text,
        'FatherName': _fatherNameCtrl.text,
        'FatherJob': _fatherJobCtrl.text,
        'MotherName': _motherNameCtrl.text,
        'MotherJob': _motherJobCtrl.text,
        'FamilyContact': _familyContactCtrl.text,
        'Status': "1", // Sending as String "1" (Laravel handles it)
        'IsDeleted': "0",
      });

      // 4. ADD PHOTO (Key must be 'Photo' with capital P)
      if (_imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('Photo', _imageFile!.path),
        );
      }

      // 5. SEND AND CAPTURE RESPONSE
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      EasyLoading.dismiss();

      if (response.statusCode == 201 || response.statusCode == 200) {
        EasyLoading.showSuccess("Registered Successfully!");
        Navigator.pop(context, true); // Return true to refresh the list
      } else {
        // THIS IS THE MOST IMPORTANT PART FOR DEBUGGING
        print("FULL ERROR FROM SERVER: ${response.body}");

        // If the error is 422, it's a validation error (e.g., Email already exists)
        if (response.statusCode == 422) {
          EasyLoading.showError("Email already taken or Data invalid");
        } else {
          EasyLoading.showError("Server Error: ${response.statusCode}");
        }
      }
    } catch (e) {
      EasyLoading.dismiss();
      print("CONNECTION ERROR: $e");
      EasyLoading.showError("Could not connect to server");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgGray,
      appBar: AppBar(
        backgroundColor: _primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Register Student",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildCustomTabBar(),
            const SizedBox(height: 25),
            _selectedTabIndex == 0 ? _buildPersonalInfo() : _buildFamilyInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfo() => Column(
    children: [
      _buildImagePicker(),
      const SizedBox(height: 20),
      _buildTextField(
        hint: "UserID",
        controller: _rollNoCtrl,
        readOnly: true,
        fillColor: Colors.grey[200],
      ),
      _buildTextField(hint: "Name (Khmer)", controller: _nameKhCtrl),
      _buildTextField(hint: "Name (English)", controller: _nameEnCtrl),
      _buildTextField(hint: "FullName", controller: _stuNameCtrl),
      _buildTextField(hint: "Email", controller: _emailCtrl),
      _buildTextField(hint: "Phone", controller: _phoneCtrl),
      _buildTextField(
        hint: "Password",
        controller: _passwordCtrl,
        isPassword: true,
      ),
      Row(
        children: [
          Expanded(child: _buildGenderDropdown()),
          const SizedBox(width: 15),
          Expanded(
            child: _buildTextField(
              hint: "DOB",
              controller: _dobCtrl,
              icon: Icons.calendar_today,
              onTap: () => _pickDate(_dobCtrl),
            ),
          ),
        ],
      ),
      _buildTextField(hint: "Place of Birth", controller: _pobCtrl),
      _buildTextField(hint: "Promotion", controller: _promotionCtrl),
      _buildTextField(hint: "Address", controller: _addressCtrl),
      _buildStatusDropdown(),
      const SizedBox(height: 15),
      _buildSaveButton(),
    ],
  );

  Widget _buildFamilyInfo() => Column(
    children: [
      _buildTextField(hint: "Father Name", controller: _fatherNameCtrl),
      _buildTextField(hint: "Father Job", controller: _fatherJobCtrl),
      _buildTextField(hint: "Mother Name", controller: _motherNameCtrl),
      _buildTextField(hint: "Mother Job", controller: _motherJobCtrl),
      _buildTextField(hint: "Contact Number", controller: _familyContactCtrl),
      const SizedBox(height: 30),
      _buildSaveButton(),
    ],
  );

  // --- UI Components ---

  Widget _buildTextField({
    required String hint,
    TextEditingController? controller,
    IconData? icon,
    VoidCallback? onTap,
    bool readOnly = false,
    Color? fillColor,
    bool isPassword = false,
  }) => Container(
    margin: const EdgeInsets.only(bottom: 15),
    decoration: BoxDecoration(
      color: fillColor ?? Colors.white,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: Colors.blue.shade400),
    ),
    child: TextField(
      controller: controller,
      readOnly: readOnly || onTap != null,
      onTap: onTap,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),
        suffixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
      ),
    ),
  );

  Widget _buildGenderDropdown() => Container(
    margin: const EdgeInsets.only(bottom: 15),
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

  Widget _buildStatusDropdown() => Container(
    margin: const EdgeInsets.only(bottom: 15),
    padding: const EdgeInsets.symmetric(horizontal: 15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: Colors.blue.shade400),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _selectedStatus,
        isExpanded: true,
        items: const [
          DropdownMenuItem(value: "1", child: Text("Active")),
          DropdownMenuItem(value: "0", child: Text("Inactive")),
        ],
        onChanged: (v) => setState(() => _selectedStatus = v!),
      ),
    ),
  );

  Widget _buildCustomTabBar() => Container(
    height: 45,
    decoration: BoxDecoration(
      color: Colors.grey[300],
      borderRadius: BorderRadius.circular(25),
    ),
    child: Row(children: [_tabItem("Personal", 0), _tabItem("Parent Info", 1)]),
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

  Widget _buildImagePicker() => Center(
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
  );

  Future<void> _pickDate(TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null)
      setState(() => controller.text = DateFormat('yyyy-MM-dd').format(picked));
  }

  Future<void> _pickImage() async {
    final XFile? image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (image != null) setState(() => _imageFile = File(image.path));
  }
}
