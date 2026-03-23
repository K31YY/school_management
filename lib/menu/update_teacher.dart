// ignore_for_file: avoid_print, curly_braces_in_flow_control_structures, use_build_context_synchronously
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateTeacherScreen extends StatefulWidget {
  final dynamic teacher;
  final String apiUrl;

  const UpdateTeacherScreen({
    super.key,
    required this.teacher,
    required this.apiUrl,
  });

  @override
  State<UpdateTeacherScreen> createState() => _UpdateTeacherScreenState();
}

class _UpdateTeacherScreenState extends State<UpdateTeacherScreen> {
  final Color _primaryBlue = const Color(0xFF4A5BF6);
  int _selectedTabIndex = 0;
  String _selectedGender = "Male";
  File? _imageFile;
  bool _isObscure = true;

  late TextEditingController _nameCtrl,
      _phoneCtrl,
      _emailCtrl,
      _passwordCtrl,
      _addressCtrl,
      _dobCtrl,
      _startDateCtrl,
      _endDateCtrl,
      _certCtrl,
      _skillCtrl;

  @override
  void initState() {
    super.initState();
    final t = widget.teacher;
    _nameCtrl = TextEditingController(text: t['TeacherName']);
    _phoneCtrl = TextEditingController(text: t['Phone']);
    _emailCtrl = TextEditingController(text: t['Email']);
    _passwordCtrl = TextEditingController();
    _addressCtrl = TextEditingController(text: t['Address']);
    _dobCtrl = TextEditingController(text: t['DOB']);
    _startDateCtrl = TextEditingController(text: t['StartDate']);
    _endDateCtrl = TextEditingController(text: t['EndDate']);
    _certCtrl = TextEditingController(text: t['Certificate']);
    _skillCtrl = TextEditingController(text: t['Specialty']);
    _selectedGender = t['Gender'] ?? "Male";
  }

  Future<void> _handleUpdate() async {
    if (_nameCtrl.text.isEmpty || _emailCtrl.text.isEmpty) {
      EasyLoading.showError("Name and Email required!");
      return;
    }

    EasyLoading.show(status: 'Updating...');
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('TOKEN');
      final String id = (widget.teacher['id'] ?? widget.teacher['TeacherID'])
          .toString();

      // FIXED: Use POST + _method: PUT for image uploads
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${widget.apiUrl}/$id'),
      );
      request.headers.addAll({
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      });
      request.fields['_method'] = 'PUT';

      request.fields.addAll({
        'TeacherName': _nameCtrl.text,
        'Gender': _selectedGender,
        'DOB': _dobCtrl.text,
        'Phone': _phoneCtrl.text,
        'Email': _emailCtrl.text,
        'Address': _addressCtrl.text,
        'StartDate': _startDateCtrl.text,
        'EndDate': _endDateCtrl.text,
        'Specialty': _skillCtrl.text,
        'Certificate': _certCtrl.text,
      });

      if (_passwordCtrl.text.isNotEmpty)
        request.fields['password'] = _passwordCtrl.text;
      if (_imageFile != null)
        request.files.add(
          await http.MultipartFile.fromPath('Photo', _imageFile!.path),
        );

      var response = await http.Response.fromStream(await request.send());
      EasyLoading.dismiss();

      if (response.statusCode == 200 || response.statusCode == 201) {
        EasyLoading.showSuccess("Updated!");
        Navigator.pop(context, true);
      } else {
        print(response.body);
        EasyLoading.showError("Error ${response.statusCode}");
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError("Connection Failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _primaryBlue,
        title: const Text(
          "Update Teacher",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildTabs(),
            const SizedBox(height: 25),
            _selectedTabIndex == 0 ? _buildPersonal() : _buildProfessional(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() => Container(
    height: 45,
    decoration: BoxDecoration(
      color: Colors.grey[300],
      borderRadius: BorderRadius.circular(25),
    ),
    child: Row(
      children: [_tabItem("Personal", 0), _tabItem("Professional", 1)],
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
            color: _selectedTabIndex == i ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );

  Widget _buildPersonal() => Column(
    children: [
      GestureDetector(
        onTap: _pickImg,
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
              ? const Icon(Icons.add_a_photo, color: Colors.grey)
              : null,
        ),
      ),
      const SizedBox(height: 20),
      _txtField("Full Name", _nameCtrl),
      const SizedBox(height: 15),
      _dropdown(),
      const SizedBox(height: 15),
      _txtField(
        "DOB",
        _dobCtrl,
        icon: Icons.calendar_today,
        onTap: () => _pickDate(_dobCtrl),
      ),
      const SizedBox(height: 15),
      _txtField("Email", _emailCtrl),
      const SizedBox(height: 15),
      _txtField("Password (Optional)", _passwordCtrl, isPass: true),
      const SizedBox(height: 15),
      _txtField("Phone", _phoneCtrl),
      const SizedBox(height: 15),
      _txtField("Address", _addressCtrl, icon: Icons.location_on),
      const SizedBox(height: 30),
      _btn(),
    ],
  );

  Widget _buildProfessional() => Column(
    children: [
      _txtField("Certificate", _certCtrl),
      const SizedBox(height: 15),
      _txtField("Skills", _skillCtrl),
      const SizedBox(height: 40),
      _btn(),
    ],
  );

  Widget _txtField(
    String h,
    TextEditingController c, {
    IconData? icon,
    VoidCallback? onTap,
    bool isPass = false,
  }) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: Colors.blue.shade400),
    ),
    child: TextField(
      controller: c,
      obscureText: isPass && _isObscure,
      readOnly: onTap != null,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: h,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.all(15),
        suffixIcon: isPass
            ? IconButton(
                icon: Icon(
                  _isObscure ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () => setState(() => _isObscure = !_isObscure),
              )
            : (icon != null ? Icon(icon) : null),
      ),
    ),
  );

  Widget _dropdown() => Container(
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
        ].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
        onChanged: (v) => setState(() => _selectedGender = v!),
      ),
    ),
  );

  Widget _btn() => SizedBox(
    width: double.infinity,
    height: 50,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: _handleUpdate,
      child: const Text(
        "UPDATE",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    ),
  );

  Future<void> _pickDate(TextEditingController c) async {
    DateTime? p = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );
    if (p != null) setState(() => c.text = DateFormat('yyyy-MM-dd').format(p));
  }

  Future<void> _pickImg() async {
    final XFile? i = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (i != null) setState(() => _imageFile = File(i.path));
  }
}
