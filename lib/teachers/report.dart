import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class AdvancedReportingScreen extends StatelessWidget {
  const AdvancedReportingScreen({super.key});

  final Color primaryBlue = const Color(0xFF0055FF);
  final Color backgroundGrey = const Color(0xFFF0F0F0);
  final Color textDark = const Color(0xFF333333);

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
          "Reporting",
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
            // --- SECTION 1: ATTENDANCE REPORT ---
            _buildSectionTitle("Attendance Report"),
            const SizedBox(height: 10),

            // Date Inputs Container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(child: _buildDateInput("From", "2025-11-29")),
                  const SizedBox(width: 16),
                  Expanded(child: _buildDateInput("To", "2025-11-29")),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Class Dropdown
            _buildDropdownInput("10 - A"),
            const SizedBox(height: 16),

            // Top Export Button
            _buildBlueButton("Export Report"),

            const SizedBox(height: 30),

            // --- SECTION 2: SUMMARY (New Feature) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Summary",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "Total Attendance",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                // "View Details" Button
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Text(
                        "View Details",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: textDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Horizontal Stats Cards
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildSummaryCard("Total Student", "150", null),
                  _buildSummaryCard("Student Present", "120", "85 %"),
                  _buildSummaryCard("Student Absent", "30", "15 %"),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Middle Action Buttons
            _buildBlueButton("Export Report"),
            const SizedBox(height: 12),
            _buildBlueButton("Sent notifications"),

            const SizedBox(height: 30),

            // --- SECTION 3: SCORE REPORT ---
            _buildSectionTitle("Score Report"),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildDropdownInput(
                    "Select the class",
                    isPlaceholder: true,
                    hasBorder: false,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(height: 1),
                  ),
                  _buildDropdownInput(
                    "Select Month",
                    isPlaceholder: true,
                    hasBorder: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildBlueButton("Export Report"),

            const SizedBox(height: 20), // Bottom padding
          ],
        ),
      ),
    );
  }

  // --- Widget Helpers ---

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.grey[600],
      ),
    );
  }

  Widget _buildDateInput(String label, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blueAccent),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87),
              ),
              Icon(Icons.access_time, size: 16, color: Colors.grey[500]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownInput(
    String text, {
    bool isPlaceholder = false,
    bool hasBorder = true,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: hasBorder
          ? BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.blueAccent),
              borderRadius: BorderRadius.circular(12),
            )
          : null, // If no border, rely on parent container
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: isPlaceholder ? null : text,
          hint: isPlaceholder
              ? Text(
                  text,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                )
              : null,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
          items: isPlaceholder
              ? []
              : [text]
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
                    )
                    .toList(),
          onChanged: (_) {},
        ),
      ),
    );
  }

  Widget _buildBlueButton(String text) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String mainValue, String? subValue) {
    return Container(
      width: 130, // Fixed width for cards
      height: 90,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            mainValue,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          if (subValue != null)
            Text(
              subValue,
              style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500]),
            ),
        ],
      ),
    );
  }
}
