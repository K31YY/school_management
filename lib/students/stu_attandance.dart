import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class MyAttendanceScreen extends StatefulWidget {
  const MyAttendanceScreen({super.key});

  @override
  State<MyAttendanceScreen> createState() => _MyAttendanceScreenState();
}

class _MyAttendanceScreenState extends State<MyAttendanceScreen> {
  // Colors
  final Color primaryBlue = const Color(0xFF4A5BF6);
  final Color backgroundGrey = const Color(0xFFF0F0F0);
  final Color textDark = const Color(0xFF333333);
  final Color absentRed = const Color(0xFFFF4D4D);
  final Color presentBlue = const Color(0xFF00C853);

  // --- 1. Add State Variables ---
  String? selectedMonth;
  String? selectedYear;

  // --- 2. Define Data Lists ---
  final List<String> months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];

  final List<String> years = ["2023", "2024", "2025", "2026"];

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
          "My Attendance",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // --- 3. Pass Data to Filter Dropdowns ---
            Row(
              children: [
                Expanded(
                  child: _buildFilterDropdown(
                    hint: "Months",
                    items: months,
                    value: selectedMonth,
                    onChanged: (val) {
                      setState(() {
                        selectedMonth = val;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildFilterDropdown(
                    hint: "Years",
                    items: years,
                    value: selectedYear,
                    onChanged: (val) {
                      setState(() {
                        selectedYear = val;
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Attendance Cards
            _buildAttendanceCard(
              title: "English Grade 10",
              classroom: "Classroom 01",
              absentCount: "02",
              presentCount: "30",
            ),
            _buildAttendanceCard(
              title: "English Grade 10",
              classroom: "Classroom 01",
              absentCount: "02",
              presentCount: "30",
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  // Updated Helper: Accepts items, current value, and change function
  Widget _buildFilterDropdown({
    required String hint,
    required List<String> items,
    required String? value,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.black12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value, // Connects the state variable
          hint: Text(
            hint,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: textDark,
              fontSize: 14,
            ),
          ),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
          isExpanded: true,
          // Maps the list of strings to DropdownMenuItems
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: GoogleFonts.poppins(color: textDark)),
            );
          }).toList(),
          onChanged: onChanged, // Connects the setState function
        ),
      ),
    );
  }

  Widget _buildAttendanceCard({
    required String title,
    required String classroom,
    required String absentCount,
    required String presentCount,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                classroom,
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
            ],
          ),
          Row(
            children: [
              _buildStatItem(absentCount, "absent", absentRed),
              const SizedBox(width: 24),
              _buildStatItem(presentCount, "present", presentBlue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String count, String label, Color color) {
    return Column(
      children: [
        Text(
          count,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
