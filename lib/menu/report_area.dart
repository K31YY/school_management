import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ReportingScreen(),
    ),
  );
}

class ReportingScreen extends StatelessWidget {
  const ReportingScreen({super.key});

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
            // --- Section 1: Attendance Report ---
            _buildSectionHeader("Attendance Report"),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // From / To Date Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildLabeledDateInput("From", "2025-11-29"),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildLabeledDateInput("To", "2025-11-29"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Class Dropdown
                  _buildDropdownInput("10 - A"),
                ],
              ),
            ),

            const SizedBox(height: 16),
            _buildExportButton(),

            const SizedBox(height: 30),

            // --- Section 2: Score Report ---
            _buildSectionHeader("Score Report"),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildDropdownInput("Select the class", isPlaceholder: true),
                  const SizedBox(height: 16),
                  _buildDropdownInput("Select Month", isPlaceholder: true),
                ],
              ),
            ),

            const SizedBox(height: 16),
            _buildExportButton(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- Reusable Widgets ---

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.grey[700],
      ),
    );
  }

  Widget _buildLabeledDateInput(String label, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: primaryBlue, width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: GoogleFonts.poppins(
                  color: Colors.grey[700],
                  fontSize: 13,
                ),
              ),
              Icon(Icons.access_time, size: 18, color: Colors.grey[500]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownInput(String text, {bool isPlaceholder = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: primaryBlue, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: isPlaceholder ? null : text,
          hint: isPlaceholder
              ? Text(
                  text,
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                )
              : null,
          icon: const Icon(Icons.keyboard_arrow_down),
          isExpanded: true,
          items: isPlaceholder
              ? []
              : [text].map((String item) {
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

  Widget _buildExportButton() {
    return SizedBox(
      width: double.infinity,
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
        child: Text(
          "Export Report",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
