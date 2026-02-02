import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Optional, for styling

void main() {
  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: AssignScreen()),
  );
}

class AssignScreen extends StatefulWidget {
  const AssignScreen({super.key});

  @override
  State<AssignScreen> createState() => _AssignScreenState();
}

class _AssignScreenState extends State<AssignScreen> {
  // Color Palette based on image
  final Color primaryBlue = const Color(0xFF0055FF);
  final Color backgroundGrey = const Color(0xFFF0F0F0);
  final Color textDark = const Color(0xFF333333);

  // State for the Day Selector
  int selectedDayIndex = 0;
  final List<String> days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

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
          "Assign",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Top Section: Dropdowns ---
                  _buildLabel("Select Class Section"),
                  const SizedBox(height: 8),
                  _buildDropdownInput("10 - A"),

                  const SizedBox(height: 16),

                  _buildLabel(
                    "Select Class Section",
                  ), // Label repeated as per image
                  const SizedBox(height: 8),
                  _buildDropdownInput("Semester 1"),

                  const SizedBox(height: 24),

                  // --- Day Selector ---
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(days.length, (index) {
                        return _buildDayItem(index);
                      }),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- Existing Schedule Card ---
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "English Grade 10",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: textDark,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Teacher Name",
                              style: GoogleFonts.poppins(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            _buildTimeBadge("7:00 AM", isDark: true),
                            _buildTimeBadge("8:00 AM", isDark: false),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- Bottom Section: "Add New" ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "Add New",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildLabel("Select Teacher"),
                  const SizedBox(height: 8),
                  _buildDropdownInput("Lor Soth"),

                  const SizedBox(height: 16),

                  _buildLabel("Select Subject"),
                  const SizedBox(height: 8),
                  _buildDropdownInput("English"),

                  const SizedBox(height: 16),

                  // --- Date Inputs ---
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Start"),
                            const SizedBox(height: 8),
                            _buildDateInput("2025-11-29"),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("End"),
                            const SizedBox(height: 8),
                            _buildDateInput("2026-11-29"),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // --- Action Buttons ---
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[600],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              "Cancel",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              "Save",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widget Helpers ---

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.grey[600],
      ),
    );
  }

  Widget _buildDropdownInput(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: primaryBlue, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down),
          isExpanded: true,
          items: [value].map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: GoogleFonts.poppins(color: Colors.black87),
              ),
            );
          }).toList(),
          onChanged: (_) {},
        ),
      ),
    );
  }

  Widget _buildDateInput(String date) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: primaryBlue, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(date, style: GoogleFonts.poppins(color: Colors.grey[700])),
          Icon(Icons.access_time, size: 18, color: Colors.grey[500]),
        ],
      ),
    );
  }

  Widget _buildDayItem(int index) {
    bool isSelected = selectedDayIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDayIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          days[index],
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildTimeBadge(String time, {required bool isDark}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF555555) : const Color(0xFFE0E0E0),
      ),
      child: Text(
        time,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.grey[700],
        ),
      ),
    );
  }
}
