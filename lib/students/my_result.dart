import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  // Colors
  final Color primaryBlue = const Color(0xFF4A5BF6);
  final Color backgroundGrey = const Color(0xFFF0F0F0);
  final Color textDark = const Color(0xFF333333);
  final Color headerCyan = const Color(0xFF00C2FF);

  // State: Default to Profile
  bool isProfileTab = true;

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
          isProfileTab ? "My Profile" : "My Result",
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
            // --- 1. Header Section (Name & Avatar) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "KHOEURT SOKHY",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "ID : CCD001",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
                const CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.black12,
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 50, color: Colors.black),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            Divider(color: Colors.grey[400], thickness: 1),
            const SizedBox(height: 20),

            // --- 2. Custom Tab Switcher (UPDATED) ---
            Container(
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white, // Background of the container
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: primaryBlue,
                ), // Blue border around the whole toggle
              ),
              child: Row(
                children: [
                  // Profile Tab
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => isProfileTab = true),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          // Active = Blue, Inactive = Transparent
                          color: isProfileTab
                              ? primaryBlue
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          "Profile",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            // Active Text = White, Inactive = Black
                            color: isProfileTab ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Result Tab
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => isProfileTab = false),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          // Active = Blue, Inactive = Transparent
                          color: !isProfileTab
                              ? primaryBlue
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          "Result",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            // Active Text = White, Inactive = Black
                            color: !isProfileTab ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- 3. Dynamic Content ---
            // Shows Profile details if isProfileTab is true
            // Shows Result tables if isProfileTab is false
            if (isProfileTab) _buildProfileContent() else _buildResultContent(),
          ],
        ),
      ),
    );
  }

  // --- Profile Tab Content ---
  Widget _buildProfileContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoItem("Date of Birth", "21-07-2003"),
        _buildInfoItem("Gender", "Male"),

        Row(
          children: [
            Expanded(child: _buildInfoItem("Father's name", "LEE")),
            Expanded(child: _buildInfoItem("Job", "Software Engineer")),
          ],
        ),

        Row(
          children: [
            Expanded(child: _buildInfoItem("Mother's name", "MEE")),
            Expanded(child: _buildInfoItem("Job", "Doctor")),
          ],
        ),

        _buildInfoItem("Family Contact", "099999999"),
        _buildInfoItem("Phone number", "012891012"),
        _buildInfoItem(
          "Address",
          "Svay Dangkum, Svay Dangkum, Siem Reap, Siem Reap",
        ),
        _buildInfoItem("Class / Section", "11 / A"),
        _buildInfoItem("Group", "A1"),
        _buildInfoItem("Study Year", "2024-2025"),
      ],
    );
  }

  // --- Result Tab Content ---
  Widget _buildResultContent() {
    return Column(
      children: [
        _buildTermTable("Term 1"),
        const SizedBox(height: 20),
        _buildTermTable("Term 2"),
      ],
    );
  }

  // --- Helper Widgets ---

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildTermTable(String termTitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            termTitle,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),

          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration: BoxDecoration(
              color: headerCyan,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _buildCell("Subject Name", flex: 3, isHeader: true),
                _buildCell("Quiz1", isHeader: true),
                _buildCell("Quiz2", isHeader: true),
                _buildCell("Mid", isHeader: true),
                _buildCell("Final", isHeader: true),
                _buildCell("Total", isHeader: true),
                _buildCell("Grade", isHeader: true),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Table Rows (Mock Data)
          _buildResultRow(
            "English Grade 10",
            "4.0",
            "4.0",
            "5.0",
            "5.0",
            "5.0",
            "A",
          ),
          _buildResultRow(
            "English Grade 10",
            "4.0",
            "4.0",
            "5.0",
            "5.0",
            "5.0",
            "A",
          ),
          _buildResultRow(
            "English Grade 10",
            "4.0",
            "4.0",
            "5.0",
            "5.0",
            "5.0",
            "A",
          ),
          _buildResultRow(
            "English Grade 10",
            "4.0",
            "4.0",
            "5.0",
            "5.0",
            "5.0",
            "A",
          ),
          _buildResultRow(
            "English Grade 10",
            "4.0",
            "4.0",
            "5.0",
            "5.0",
            "5.0",
            "A",
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(
    String subject,
    String q1,
    String q2,
    String mid,
    String fin,
    String total,
    String grade,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: primaryBlue),
      ),
      child: Row(
        children: [
          _buildCell(subject, flex: 3, isHeader: false, isBold: true),
          _buildCell(q1, isHeader: false),
          _buildCell(q2, isHeader: false),
          _buildCell(mid, isHeader: false),
          _buildCell(fin, isHeader: false),
          _buildCell(total, isHeader: false),
          _buildCell(grade, isHeader: false),
        ],
      ),
    );
  }

  Widget _buildCell(
    String text, {
    int flex = 1,
    bool isHeader = false,
    bool isBold = false,
  }) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          fontSize: isHeader ? 10 : 10,
          fontWeight: (isHeader || isBold)
              ? FontWeight.bold
              : FontWeight.normal,
          color: isHeader ? Colors.black : Colors.grey[800],
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
