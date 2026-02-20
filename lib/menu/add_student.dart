import 'package:flutter/material.dart';
class AddStudent extends StatefulWidget {
  const AddStudent({super.key});

  @override
  State<AddStudent> createState() => _AddStudentState();
}

class _AddStudentState extends State<AddStudent> {
  // Colors
  final Color _primaryBlue = Color(0xFF4A5BF6);
  final Color _bgGray = const Color(0xFFF0F0F0);
  final Color _borderColor = const Color(0xFF0D61FF);

  // State
  int _selectedTabIndex = 0; // 0 = Personal Info, 1 = Parent Info

  // Dropdown Values
  String? _selectedGender;
  String? _selectedClass;
  String? _selectedYear;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgGray,
      appBar: AppBar(
        backgroundColor: _primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Register Student",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            // 1. Custom Tab Bar
            _buildCustomTabBar(),

            const SizedBox(height: 25),

            // 2. Content Switching
            _selectedTabIndex == 0
                ? _buildPersonalInfoContent()
                : _buildParentInfoContent(),
          ],
        ),
      ),
    );
  }

  // --- TAB 1: Personal Info ---
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
        const SizedBox(height: 25),

        _buildTextField(hint: "Student name in khmer"),
        const SizedBox(height: 15),

        _buildTextField(hint: "Student name in English"),
        const SizedBox(height: 15),

        _buildTextField(hint: "Phone Number / Email"),
        const SizedBox(height: 15),

        // Row: Gender + Date of Birth
        Row(
          children: [
            Expanded(
              child: _buildDropdownField(
                hint: "Gender",
                value: _selectedGender,
                items: ["Male", "Female"],
                onChanged: (val) => setState(() => _selectedGender = val),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(child: _buildDatePickerField(hint: "Date of Birth")),
          ],
        ),
        const SizedBox(height: 15),

        // Row: Class + Study Years
        Row(
          children: [
            Expanded(
              child: _buildDropdownField(
                hint: "Class",
                value: _selectedClass,
                items: ["10 - A", "10 - B", "11 - A"],
                onChanged: (val) => setState(() => _selectedClass = val),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildDropdownField(
                hint: "Study Years",
                value: _selectedYear,
                items: ["2024-2025", "2025-2026"],
                onChanged: (val) => setState(() => _selectedYear = val),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),

        _buildTextField(hint: "Promotion"),
        const SizedBox(height: 15),

        _buildTextField(hint: "Address"),

        const SizedBox(height: 30),
        _buildSaveButton(),
        const SizedBox(height: 20),
      ],
    );
  }

  // --- TAB 2: Parent Info ---
  Widget _buildParentInfoContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Father's Information"),
        _buildTextField(hint: "Full Name"),
        const SizedBox(height: 15),
        _buildTextField(hint: "Job Title"),

        const SizedBox(height: 20),

        _buildSectionHeader("Mother's Information"),
        _buildTextField(hint: "Full Name"),
        const SizedBox(height: 15),
        _buildTextField(hint: "Job Title"),

        const SizedBox(height: 20),

        _buildSectionHeader("Contact Information"),
        _buildTextField(hint: "Phone Number"),
        const SizedBox(height: 15),
        _buildTextField(hint: "Email"),

        const SizedBox(height: 40),
        _buildSaveButton(),
        const SizedBox(height: 20),
      ],
    );
  }

  // --- Helper Widgets ---

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
                  "Parent Info", // Changed text for this screen
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

  Widget _buildTextField({required String hint}) {
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
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      height: 52, // Fixed height to match text fields
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(
            hint,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          icon: const Icon(Icons.arrow_drop_down),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: TextStyle(color: Colors.grey[800], fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDatePickerField({required String hint}) {
    return Container(
      height: 52,
      padding: const EdgeInsets.only(left: 20, right: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(hint, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          Icon(Icons.calendar_today, color: _primaryBlue, size: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
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
        onPressed: () {},
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
}
