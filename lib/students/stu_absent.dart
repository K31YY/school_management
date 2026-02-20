import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RequestForYouScreen extends StatefulWidget {
  const RequestForYouScreen({super.key});

  @override
  State<RequestForYouScreen> createState() => _RequestForYouScreenState();
}

class _RequestForYouScreenState extends State<RequestForYouScreen> {
  // Colors
  final Color primaryBlue = const Color(0xFF4A5BF6);
  final Color backgroundGrey = const Color(0xFFF0F0F0);
  final Color textDark = const Color(0xFF333333);

  // --- 1. ADD STATE VARIABLES ---
  String? selectedClass; // Stores the selected class
  String? selectedDuration; // Stores the selected number of days

  // --- 2. DEFINE DATA LISTS ---
  final List<String> classOptions = ["10 - A", "10 - B", "11 - A", "11 - B"];
  final List<String> durationOptions = ["1 day", "2 days", "3 days", "1 week"];

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
          "Request for you",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Top Row: Start Date & Class Selection ---
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Start"),
                      const SizedBox(height: 8),
                      // Static Date Input (Visual only for now)
                      _buildStaticInputContainer(
                        text: "2025-11-29",
                        icon: Icons.access_time,
                        isBlueBorder: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // --- CLASS DROPDOWN ---
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Class Selection"),
                      const SizedBox(height: 8),
                      _buildDropdown(
                        hint: "Select Class",
                        value: selectedClass,
                        items: classOptions,
                        onChanged: (newValue) {
                          setState(() {
                            selectedClass = newValue;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // --- NUMBER DROPDOWN ---
            _buildLabel("Number"),
            const SizedBox(height: 8),
            _buildDropdown(
              hint: "Select Duration",
              value: selectedDuration,
              items: durationOptions,
              onChanged: (newValue) {
                setState(() {
                  selectedDuration = newValue;
                });
              },
            ),

            const SizedBox(height: 20),

            // --- Teachers List ---
            _buildLabel("Teachers"),
            const SizedBox(height: 12),

            _buildTeacherCard(
              name: "Khy",
              details: "English Grade 12 || 9:00 - 11:00",
            ),
            _buildTeacherCard(
              name: "Khy",
              details: "English Grade 11 || 2:00 - 5:00",
            ),

            const SizedBox(height: 20),

            // --- Reason Button ---
            Container(
              width: double.infinity,
              height: 55,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryBlue),
              ),
              alignment: Alignment.center,
              child: Text(
                "Reason for absent",
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // --- Confirm Button ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "Confirm",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: textDark,
      ),
    );
  }

  // --- NEW: Helper for Functional Dropdown ---
  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryBlue, width: 1), // Blue border
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: GoogleFonts.poppins(color: textDark, fontSize: 14),
          ),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
          isExpanded: true,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: GoogleFonts.poppins(color: textDark, fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // Helper for Static Inputs (like the Date, for now)
  Widget _buildStaticInputContainer({
    required String text,
    required IconData icon,
    bool isBlueBorder = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isBlueBorder ? primaryBlue : Colors.grey.shade400,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text, style: GoogleFonts.poppins(color: textDark, fontSize: 14)),
          Icon(icon, size: 20, color: Colors.black54),
        ],
      ),
    );
  }

  Widget _buildTeacherCard({required String name, required String details}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
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
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Colors.teal,
            child: Icon(Icons.person, color: Colors.white),
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
                    fontSize: 15,
                    color: textDark,
                  ),
                ),
                Text(
                  details,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.phone_in_talk_outlined,
            size: 28,
            color: Colors.black,
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
