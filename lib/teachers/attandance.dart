import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MakeAttendanceScreen extends StatefulWidget {
  const MakeAttendanceScreen({super.key});

  @override
  State<MakeAttendanceScreen> createState() => _MakeAttendanceScreenState();
}

class _MakeAttendanceScreenState extends State<MakeAttendanceScreen> {
  // Colors
  final Color primaryBlue = const Color(0xFF4A5BF6);
  final Color backgroundGrey = const Color(0xFFF0F0F0);
  final Color successGreen = const Color(0xFF00C853);
  final Color textDark = const Color(0xFF333333);

  // State
  String selectedStatus = "P"; // Default to Present

  // Mock Data
  final List<Map<String, String>> students = [
    {"name": "Rom Sarun", "id": "ID: UT0001"},
    {"name": "Khuoeurt Sokhy", "id": "ID: UT0002"},
    {"name": "Neat Tina", "id": "ID: UT0003"},
    {"name": "Reun Rin", "id": "ID: UT0004"},
    {"name": "Youm Danet", "id": "ID: UT0005"},
  ];

  // --- NEW FUNCTION: Shows "The Reason" Popup ---
  void _showReasonBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Needed so keyboard doesn't cover input
      backgroundColor: Colors.transparent, // Allows rounded corners to show
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            // Add padding at bottom equal to keyboard height + 24
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Wrap content height
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "The Reason",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),

              // Input Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Enter the reason of absent",
                    hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Apply Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the sheet
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "Apply",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

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
          "Make Attendance",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          // --- TRIGGER: Click here to open the bottom sheet ---
          IconButton(
            icon: const Icon(Icons.person_add, color: Colors.white),
            onPressed: () {
              _showReasonBottomSheet(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // --- 1. Top Filters ---
                  Row(
                    children: [
                      Expanded(child: _buildDropdown("10A -English")),
                      const SizedBox(width: 16),
                      Expanded(child: _buildDropdown("2025-2026")),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // --- 2. P / A / H Toggle ---
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: primaryBlue),
                    ),
                    child: Row(
                      children: [
                        _buildToggleOption("P", "P"),
                        _buildVerticalDivider(),
                        _buildToggleOption("A", "A"),
                        _buildVerticalDivider(),
                        _buildToggleOption("H", "H"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- 3. Student List ---
                  ...students.map(
                    (student) =>
                        _buildStudentCard(student["name"]!, student["id"]!),
                  ),

                  // NOTE: "The Reason" section has been removed from here
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildDropdown(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryBlue, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: text,
          icon: const Icon(Icons.keyboard_arrow_down),
          isExpanded: true,
          items: [text].map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
              ),
            );
          }).toList(),
          onChanged: (_) {},
        ),
      ),
    );
  }

  Widget _buildToggleOption(String label, String value) {
    bool isSelected = selectedStatus == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedStatus = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(width: 1, height: 24, color: Colors.grey[300]);
  }

  Widget _buildStudentCard(String name, String id) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryBlue, width: 1),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[300],
            child: Icon(Icons.person, color: Colors.grey[700]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: textDark,
                  ),
                ),
                Text(
                  id,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: successGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                selectedStatus,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
