// ignore_for_file: avoid_print, use_build_context_synchronously, curly_braces_in_flow_control_structures
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateStudentScreen extends StatefulWidget {
  final dynamic student;
  final String apiUrl;

  const UpdateStudentScreen({
    super.key,
    required this.student,
    required this.apiUrl,
  });

  @override
  State<UpdateStudentScreen> createState() => _UpdateStudentScreenState();
}

class _UpdateStudentScreenState extends State<UpdateStudentScreen> {
  final Color _primaryBlue = const Color(0xFF4A5BF6);
  int _selectedTabIndex = 0;

  // --- Image State ---
  File? _imageFile;
  bool _isPickerActive = false; // Safety lock for ImagePicker

  // --- Dropdown State ---
  late String _selectedGender;
  late String _selectedStatus;

  // --- Controllers ---
  late TextEditingController _nameKhCtrl,
      _nameEnCtrl,
      _phoneCtrl,
      _emailCtrl,
      _pobCtrl,
      _dobCtrl,
      _promotionCtrl,
      _addressCtrl,
      _fatherNameCtrl,
      _fatherJobCtrl,
      _motherNameCtrl,
      _motherJobCtrl,
      _familyContactCtrl;

  @override
  void initState() {
    super.initState();
    final s = widget.student;

    _nameKhCtrl = TextEditingController(text: s['StuNameKH']?.toString() ?? "");
    _nameEnCtrl = TextEditingController(text: s['StuNameEN']?.toString() ?? "");
    _phoneCtrl = TextEditingController(text: s['Phone']?.toString() ?? "");
    _emailCtrl = TextEditingController(text: s['Email']?.toString() ?? "");
    _pobCtrl = TextEditingController(text: s['POB']?.toString() ?? "");
    _dobCtrl = TextEditingController(text: s['DOB']?.toString() ?? "");
    _promotionCtrl = TextEditingController(
      text: s['Promotion']?.toString() ?? "",
    );
    _addressCtrl = TextEditingController(text: s['Address']?.toString() ?? "");
    _fatherNameCtrl = TextEditingController(
      text: s['FatherName']?.toString() ?? "",
    );
    _fatherJobCtrl = TextEditingController(
      text: s['FatherJob']?.toString() ?? "",
    );
    _motherNameCtrl = TextEditingController(
      text: s['MotherName']?.toString() ?? "",
    );
    _motherJobCtrl = TextEditingController(
      text: s['MotherJob']?.toString() ?? "",
    );
    _familyContactCtrl = TextEditingController(
      text: s['FamilyContact']?.toString() ?? "",
    );

    // Handle Gender Logic
    String genderApi = s['Gender']?.toString() ?? "Male";
    List<String> genderOptions = ["Male", "Female", "Other"];
    _selectedGender = genderOptions.contains(genderApi) ? genderApi : "Male";

    // Handle Status Logic
    String statusApi = s['Status']?.toString() ?? "1";
    _selectedStatus = (statusApi == "1" || statusApi == "0") ? statusApi : "1";
  }

  // --- Image Picker with Safety Guard ---
  Future<void> _pickImage() async {
    if (_isPickerActive) return;

    setState(() => _isPickerActive = true);

    try {
      final XFile? image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );
      if (image != null) {
        setState(() => _imageFile = File(image.path));
      }
    } catch (e) {
      EasyLoading.showError("Could not open gallery");
    } finally {
      setState(() => _isPickerActive = false);
    }
  }

  Future<void> _pickDate() async {
    DateTime? p = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (p != null)
      setState(() => _dobCtrl.text = DateFormat('yyyy-MM-dd').format(p));
  }

  // --- API Update Logic ---
  Future<void> _handleUpdate() async {
    EasyLoading.show(status: 'Updating...');
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('TOKEN');
      // Use StuID or id depending on your API structure
      final String id = (widget.student['StuID'] ?? widget.student['id'])
          .toString();

      var request = http.MultipartRequest(
        'POST', // Using POST with _method PUT for Laravel compatibility
        Uri.parse('${widget.apiUrl}/$id'),
      );

      request.headers.addAll({
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      });

      // Laravel/PHP usually requires _method override for Multipart PUT requests
      request.fields['_method'] = 'PUT';

      request.fields.addAll({
        'StuNameKH': _nameKhCtrl.text,
        'StuNameEN': _nameEnCtrl.text,
        'Gender': _selectedGender,
        'DOB': _dobCtrl.text,
        'POB': _pobCtrl.text,
        'Address': _addressCtrl.text,
        'Phone': _phoneCtrl.text,
        'Email': _emailCtrl.text,
        'Promotion': _promotionCtrl.text,
        'FatherName': _fatherNameCtrl.text,
        'FatherJob': _fatherJobCtrl.text,
        'MotherName': _motherNameCtrl.text,
        'MotherJob': _motherJobCtrl.text,
        'FamilyContact': _familyContactCtrl.text,
        'Status': _selectedStatus,
      });

      if (_imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('Photo', _imageFile!.path),
        );
      }

      var res = await http.Response.fromStream(await request.send());
      EasyLoading.dismiss();

      if (res.statusCode == 200) {
        EasyLoading.showSuccess("Updated Successfully!");
        Navigator.pop(context, true);
      } else {
        print("Response Body: ${res.body}");
        EasyLoading.showError("Update failed: ${res.statusCode}");
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError("Connection Error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _primaryBlue,
        title: const Text(
          "Update Student",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          const SizedBox(height: 15),
          _buildTabs(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _selectedTabIndex == 0
                  ? _buildPersonalInfo()
                  : _buildFamilyInfo(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Container(
      height: 45,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(children: [_tabItem("Personal", 0), _tabItem("Family", 1)]),
    ),
  );

  Widget _tabItem(String t, int i) => Expanded(
    child: GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = i),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _selectedTabIndex == i ? _primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          t,
          style: TextStyle(
            color: _selectedTabIndex == i ? Colors.white : Colors.black54,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );

  Widget _buildPersonalInfo() => Column(
    children: [
      _buildImagePicker(),
      const SizedBox(height: 25),
      _txt("Name (Khmer)", _nameKhCtrl),
      _txt("Name (English)", _nameEnCtrl),
      _txt("Email", _emailCtrl),
      _txt("Phone", _phoneCtrl),
      Row(
        children: [
          Expanded(child: _buildGenderDropdown()),
          const SizedBox(width: 15),
          Expanded(
            child: _txt(
              "DOB",
              _dobCtrl,
              icon: Icons.calendar_today,
              onTap: _pickDate,
            ),
          ),
        ],
      ),
      _txt("Place of Birth", _pobCtrl),
      _txt("Promotion", _promotionCtrl),
      _txt("Address", _addressCtrl),
      _buildStatusDropdown(),
      const SizedBox(height: 20),
      _updateBtn(),
      const SizedBox(height: 30),
    ],
  );

  Widget _buildFamilyInfo() => Column(
    children: [
      _txt("Father Name", _fatherNameCtrl),
      _txt("Father Job", _fatherJobCtrl),
      _txt("Mother Name", _motherNameCtrl),
      _txt("Mother Job", _motherJobCtrl),
      _txt("Family Contact", _familyContactCtrl),
      const SizedBox(height: 30),
      _updateBtn(),
    ],
  );

  Widget _txt(
    String h,
    TextEditingController c, {
    IconData? icon,
    VoidCallback? onTap,
  }) => Container(
    margin: const EdgeInsets.only(bottom: 15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: TextField(
      controller: c,
      readOnly: onTap != null,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: h,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 10,
        ),
        suffixIcon: icon != null ? Icon(icon, color: _primaryBlue) : null,
      ),
    ),
  );

  Widget _buildGenderDropdown() => Container(
    margin: const EdgeInsets.only(bottom: 15),
    padding: const EdgeInsets.symmetric(horizontal: 15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
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
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
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

  Widget _buildImagePicker() => GestureDetector(
    onTap: _pickImage,
    child: Stack(
      children: [
        CircleAvatar(
          radius: 55,
          backgroundColor: Colors.grey[200],
          backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
          child: _imageFile == null
              ? Icon(Icons.person, size: 50, color: Colors.grey[400])
              : null,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: CircleAvatar(
            backgroundColor: _primaryBlue,
            radius: 18,
            child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
          ),
        ),
      ],
    ),
  );

  Widget _updateBtn() => SizedBox(
    width: double.infinity,
    height: 50,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      onPressed: _handleUpdate,
      child: const Text(
        "SAVE CHANGES",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ),
  );
}
