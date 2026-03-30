// ignore_for_file: avoid_print, unnecessary_to_list_in_spreads, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final Color primaryBlue = const Color(0xFF4A5BF6);
  final Color backgroundGrey = const Color(0xFFF0F0F0);
  final Color textDark = const Color(0xFF333333);
  final Color headerCyan = const Color(0xFF00C2FF);

  bool isProfileTab = true;
  bool isLoading = true;
  Map<String, dynamic>? studentData;
  List<dynamic> studiesData = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final sp = await SharedPreferences.getInstance();
    final token = sp.getString('TOKEN');

    // 1. Double-check this URL. Can you open it in your computer's browser?
    const String baseUrl = "http://10.0.2.2:8000/api";

    try {
      final headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };

      print("Attempting to fetch data..."); // Debug Log

      final responses = await Future.wait([
        http
            .get(Uri.parse('$baseUrl/my-profile'), headers: headers)
            .timeout(const Duration(seconds: 10)),
        http
            .get(Uri.parse('$baseUrl/my-results'), headers: headers)
            .timeout(const Duration(seconds: 10)),
      ]);

      if (responses[0].statusCode == 200 && responses[1].statusCode == 200) {
        setState(() {
          studentData = json.decode(responses[0].body)['data'];
          studiesData = json.decode(responses[1].body)['data'];
          isLoading = false; // Stops the loading spinner
        });
        print("Data loaded successfully!");
      } else {
        print(
          "Server Error: Profile(${responses[0].statusCode}) Results(${responses[1].statusCode})",
        );
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("CONNECTION ERROR: $e");
      // If it prints "Connection refused", your Laravel server isn't running.
      // If it prints "Timeout", the IP address is wrong.
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGrey,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          isProfileTab ? "My Profile" : "My Result",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primaryBlue))
          : RefreshIndicator(
              onRefresh: fetchData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderSection(),
                    const SizedBox(height: 10),
                    Divider(color: Colors.grey[400], thickness: 1),
                    const SizedBox(height: 20),
                    _buildTabSwitcher(),
                    const SizedBox(height: 20),
                    isProfileTab
                        ? _buildProfileContent()
                        : _buildResultContent(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeaderSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                // Showing Khmer name if available, otherwise English
                studentData?['StuNameKH'] ??
                    studentData?['StuNameEN'] ??
                    "Unknown",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "ID : ${studentData?['StuID'] ?? 'N/A'}",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const CircleAvatar(
          radius: 30,
          backgroundColor: Colors.black12,
          child: Icon(Icons.person, size: 40, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryBlue),
      ),
      child: Row(
        children: [_tabButton("Profile", true), _tabButton("Result", false)],
      ),
    );
  }

  Widget _tabButton(String title, bool isProfile) {
    bool isActive = (isProfileTab == isProfile);
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => isProfileTab = isProfile),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : primaryBlue,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent() {
    return Column(
      children: [
        _buildInfoItem(
          "Date of Birth",
          studentData?['DOB']?.toString().split('T')[0] ?? "N/A",
        ),
        _buildInfoItem("Gender", studentData?['Gender'] ?? "N/A"),
        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                "Father's Name",
                studentData?['FatherName'] ?? "N/A",
              ),
            ),
            Expanded(
              child: _buildInfoItem("Job", studentData?['FatherJob'] ?? "N/A"),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                "Mother's Name",
                studentData?['MotherName'] ?? "N/A",
              ),
            ),
            Expanded(
              child: _buildInfoItem("Job", studentData?['MotherJob'] ?? "N/A"),
            ),
          ],
        ),
        _buildInfoItem(
          "Contact",
          studentData?['FamilyContact'] ?? studentData?['Phone'] ?? "N/A",
        ),
        _buildInfoItem("Address", studentData?['Address'] ?? "N/A"),
      ],
    );
  }

  Widget _buildResultContent() {
    if (studiesData.isEmpty) {
      return const Center(child: Text("No academic results found."));
    }

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
            "Current Academic Results",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: headerCyan,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _buildCell("Subject", flex: 3, isHeader: true),
                _buildCell("Quiz", isHeader: true),
                _buildCell("HW", isHeader: true),
                _buildCell("Mid", isHeader: true),
                _buildCell("Final", isHeader: true),
                _buildCell("Total", isHeader: true),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ...studiesData.map((item) {
            // FIX: Map accurately to your API response
            return _buildResultRow(
              item['subject']?['SubjectName'] ?? "N/A",
              item['Quiz']?.toString() ?? "0",
              item['Homework']?.toString() ?? "0",
              item['Midterm']?.toString() ?? "0",
              item['Final']?.toString() ?? "0",
              item['TotalScore']?.toString() ?? "0",
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildResultRow(
    String sub,
    String q1,
    String hw,
    String mid,
    String fin,
    String total,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          _buildCell(sub, flex: 3, isBold: true),
          _buildCell(q1),
          _buildCell(hw),
          _buildCell(mid),
          _buildCell(fin),
          _buildCell(total, isBold: true),
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
          fontSize: 10,
          fontWeight: (isHeader || isBold)
              ? FontWeight.bold
              : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: primaryBlue,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: 14, color: textDark),
          ),
        ],
      ),
    );
  }
}
