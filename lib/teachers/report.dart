import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdvancedReportingScreen extends StatefulWidget {
  const AdvancedReportingScreen({super.key});

  @override
  State<AdvancedReportingScreen> createState() =>
      _AdvancedReportingScreenState();
}

class _AdvancedReportingScreenState extends State<AdvancedReportingScreen> {
  final Color primaryBlue = const Color(0xFF4A5BF6);
  final Color backgroundGrey = const Color(0xFFF0F0F0);
  final Color textDark = const Color(0xFF333333);

  // State variables for dropdown selections
  String? selectedClass;
  String? selectedMonth;

  // State variables for Date Selection
  // Initialized to the date from your design (or use DateTime.now())
  DateTime fromDate = DateTime(2025, 11, 29);
  DateTime toDate = DateTime(2025, 11, 29);

  // Function to show Date Picker
  Future<void> _pickDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate ? fromDate : toDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        // Optional: Customize color to match your app theme
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryBlue,
              onPrimary: Colors.white,
              onSurface: textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isFromDate) {
          fromDate = picked;
        } else {
          toDate = picked;
        }
      });
    }
  }

  // Helper to format date manually as YYYY-MM-DD
  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
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
          onPressed: () => Navigator.pop(context),
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
            _buildSectionTitle("Attendance Report"),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildDateInput(
                      "From",
                      fromDate,
                      () => _pickDate(context, true),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDateInput(
                      "To",
                      toDate,
                      () => _pickDate(context, false),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Fixed: Standard Class Dropdown
            _buildDropdownInput(
              hint: "Select Class",
              value: "10 - A",
              items: ["10 - A", "10 - B", "10 - C"],
              onChanged: (val) {},
            ),

            const SizedBox(height: 16),
            _buildBlueButton("Export Report"),
            const SizedBox(height: 30),

            // --- SUMMARY SECTION ---
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
                      ),
                    ),
                    Text(
                      "Total Attendance",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
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
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right, size: 16),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
            _buildBlueButton("Export Report"),
            const SizedBox(height: 12),
            _buildBlueButton("Sent notifications"),
            const SizedBox(height: 30),

            // --- SCORE REPORT SECTION ---
            _buildSectionTitle("Score Report"),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // Class Selection
                  _buildDropdownInput(
                    hint: "Select the class",
                    value: selectedClass,
                    items: ["Class 10-A", "Class 10-B", "Class 11-A"],
                    hasBorder: false,
                    onChanged: (val) {
                      setState(() => selectedClass = val);
                    },
                  ),
                  const Divider(height: 1),
                  // Month Selection
                  _buildDropdownInput(
                    hint: "Select Month",
                    value: selectedMonth,
                    items: ["January", "February", "March", "April"],
                    hasBorder: false,
                    onChanged: (val) {
                      setState(() => selectedMonth = val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildBlueButton("Export Report"),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildDropdownInput({
    required String hint,
    required List<String> items,
    String? value,
    ValueChanged<String?>? onChanged,
    bool hasBorder = true,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: hasBorder
          ? BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.blueAccent),
              borderRadius: BorderRadius.circular(12),
            )
          : null,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
          ),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: GoogleFonts.poppins(color: Colors.black87),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

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

  // UPDATED: Now accepts DateTime and onTap callback
  Widget _buildDateInput(String label, DateTime date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors
                  .transparent, // Ensures the click passes through if needed, though GestureDetector handles it
              border: Border.all(color: Colors.blueAccent),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(date),
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
                Icon(
                  Icons.access_time, // Or Icons.calendar_today
                  size: 16,
                  color: Colors.grey[500],
                ),
              ],
            ),
          ),
        ],
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
      width: 130,
      height: 100,
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
          ),
          const SizedBox(height: 4),
          Text(
            mainValue,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
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
