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
  File? _imageFile;
  bool _isObscure = true;
  int? _currentUserId;

  // Controllers
  final TextEditingController _rollNoCtrl = TextEditingController();
  final TextEditingController _nameKhCtrl = TextEditingController();
  final TextEditingController _nameEnCtrl = TextEditingController();
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

  Future<void> _fetchUserId() async {
    final prefs = await SharedPreferences.getInstance();
    int? id = prefs.getInt('USER_ID_KEY');

    if (id != null) {
      setState(() {
        _currentUserId = id;
        // Format for display: UTB001
        _rollNoCtrl.text = "UTB${id.toString().padLeft(3, '0')}";
      });
    } else {
      _rollNoCtrl.text = "No ID Found";
    }
  }

  Future<void> _handleSave() async {
    if (_nameEnCtrl.text.isEmpty ||
        _emailCtrl.text.isEmpty ||
        _passwordCtrl.text.isEmpty) {
      EasyLoading.showError("Please fill all required fields!");
      return;
    }

    EasyLoading.show(status: 'Saving...');

    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('TOKEN');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://10.0.2.2:8000/api/students'),
      );

      request.headers.addAll({
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      });

      // Mapping ALL fields to match your Laravel Controller store()
      request.fields.addAll({
        'UserID': _rollNoCtrl.text,
        'StuName': _nameEnCtrl.text,
        'StuNameKH': _nameKhCtrl.text,
        'StuNameEN': _nameEnCtrl.text,
        'Gender': _selectedGender,
        'DOB': _dobCtrl.text, // Must be 'yyyy-MM-dd'
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
        'Status': '1', // Ensure this matches your DB
      });

      if (_imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('Photo', _imageFile!.path),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      EasyLoading.dismiss();

      if (response.statusCode == 201 || response.statusCode == 200) {
        EasyLoading.showSuccess("Saved Successfully!");
        Navigator.pop(context);
      } else {
        // If it fails, this print is critical
        print("SERVER ERROR 422: ${response.body}");
        EasyLoading.showError("Error: Check your logs");
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError("Connection failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgGray,
      appBar: AppBar(
        backgroundColor: _primaryBlue,
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
      _buildTextField(hint: "Email", controller: _emailCtrl),
      _buildTextField(hint: "Password", controller: _passwordCtrl),
      Row(
        children: [
          Expanded(child: _buildDropdown()),
          const SizedBox(width: 15),
          Expanded(
            child: _buildTextField(
              hint: "Date of Birth",
              controller: _dobCtrl,
              onTap: () => _pickDate(_dobCtrl),
            ),
          ),
        ],
      ),
      _buildTextField(hint: "Place of Birth", controller: _pobCtrl),
      _buildTextField(hint: "Promotion", controller: _promotionCtrl),
      _buildTextField(hint: "Address", controller: _addressCtrl),
      const SizedBox(height: 30),
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

  // Reusing your Teacher Form UI logic
  Widget _buildTextField({
    required String hint,
    IconData? icon,
    TextEditingController? controller,
    VoidCallback? onTap,
    bool readOnly = false,
    Color? fillColor,
  }) => Container(
    margin: const EdgeInsets.only(bottom: 15),
    decoration: BoxDecoration(
      color: fillColor ?? Colors.white,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: Colors.grey.shade400),
    ),
    child: TextField(
      controller: controller,
      readOnly: readOnly || onTap != null,
      onTap: onTap,
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

  Widget _buildDropdown() => Container(
    margin: const EdgeInsets.only(bottom: 15),
    padding: const EdgeInsets.symmetric(horizontal: 15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.grey.shade400),
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
    if (picked != null) {
      // Force YYYY-MM-DD
      setState(() => controller.text = DateFormat('yyyy-MM-dd').format(picked));
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (image != null) setState(() => _imageFile = File(image.path));
  }
}
