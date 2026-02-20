import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddTeacher extends StatefulWidget {
  const AddTeacher({super.key});

  @override
  State<AddTeacher> createState() => _AddTeacherState();
}

class _AddTeacherState extends State<AddTeacher> {
  // Colors
  final Color _primaryBlue = const Color(0xFF4A5BF6);
  final Color _bgGray = const Color(0xFFF0F0F0);
  final Color _borderColor = const Color(0xFF0D61FF);

  // State
  int _selectedTabIndex = 0; // 0 = Personal Info, 1 = Professional
  String _selectedGender = "Male"; // Default value for dropdown

  // --- NEW: Image File Variable ---
  File? _imageFile;

  // Controllers
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  @override
  void dispose() {
    _dobController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  // --- NEW: Logic to Pick Image ---
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // --- Logic: Pick Date ---
  Future<void> _pickDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        controller.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

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
            _buildCustomTabBar(),
            const SizedBox(height: 25),
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
        // --- UPDATED: Image Placeholder with Click Action ---
        Center(
          child: GestureDetector(
            onTap: _pickImage, // Triggers image selection
            child: Container(
              width: 100,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black26),
                borderRadius: BorderRadius.circular(4),
                // If image exists, show it as background
                image: _imageFile != null
                    ? DecorationImage(
                        image: FileImage(_imageFile!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _imageFile == null
                  ? Stack(
                      children: [
                        // Optional: Center icon for empty state
                        Center(
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.grey[300],
                          ),
                        ),
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
                    )
                  : null, // If image is selected, don't show the icons inside
            ),
          ),
        ),
        const SizedBox(height: 20),

        const Text(
          "Information",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),

        _buildTextField(hint: "Full Name"),
        const SizedBox(height: 15),

        _buildDropdownField(),
        const SizedBox(height: 15),

        _buildTextField(
          hint: "Date of Birth (YYYY-MM-DD)",
          icon: Icons.schedule,
          controller: _dobController,
          onTap: () => _pickDate(context, _dobController),
        ),
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
              Expanded(
                child: _buildDateSubField("Start", _startDateController),
              ),
              const SizedBox(width: 15),
              Expanded(child: _buildDateSubField("End", _endDateController)),
            ],
          ),
        ),

        const SizedBox(height: 30),
        _buildSaveButton(),
        const SizedBox(height: 20),
      ],
    );
  }

  // --- VIEW 2: Professional Content ---
  Widget _buildProfessionalContent() {
    return Column(
      children: [
        _buildTextField(hint: "Certificate"),
        const SizedBox(height: 15),
        _buildTextField(hint: "Skills"),
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
          // You can access _imageFile here to upload it later
        ("Image Selected: ${_imageFile?.path}");
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

  Widget _buildDateSubField(String label, TextEditingController controller) {
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
        GestureDetector(
          onTap: () => _pickDate(context, controller),
          child: Container(
            height: 45,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: _borderColor),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: IgnorePointer(
                      child: TextField(
                        controller: controller,
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: "Select Date",
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Icon(Icons.schedule, size: 18, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
