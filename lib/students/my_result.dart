// ignore_for_file: curly_braces_in_flow_control_structures, unnecessary_to_list_in_spreads

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
  final Color primaryBlue = const Color(0xFF1A73E8);
  bool isProfileTab = true;
  bool isLoading = true;
  Map<String, dynamic>? studentData;
  Map<String, dynamic>? resultsData;

  @override
  void initState() {
    super.initState();
    fetchAllData();
  }

  Future<void> fetchAllData() async {
    final sp = await SharedPreferences.getInstance();
    final token = sp.getString('TOKEN');

    // must have token to proceed, otherwise show error and return
    const String baseUrl = "http://10.0.2.2:8000/api";

    final headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };

    try {
      // get data from 2 APIs in sequence, but even if the first one fails, we still want to try the second one
      final profileRes = await http.get(
        Uri.parse('$baseUrl/my-profile'),
        headers: headers,
      );
      if (profileRes.statusCode == 200) {
        studentData = json.decode(profileRes.body)['data'];
      } else {
        debugPrint("Profile API Error: ${profileRes.statusCode}");
      }

      // get results data
      final resultRes = await http.get(
        Uri.parse('$baseUrl/my-results'),
        headers: headers,
      );
      if (resultRes.statusCode == 200) {
        resultsData = json.decode(resultRes.body)['data'];
      } else {
        // if results API fails, we can still show profile data, so we just set
        resultsData = {};
        debugPrint(
          "Result API Error: ${resultRes.statusCode} - ${resultRes.body}",
        );
      }
    } catch (e) {
      debugPrint("Network Error: $e");
    } finally {
      // if the widget is still mounted, update the loading state to false
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        title: Text(
          "My Profile",
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primaryBlue))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildTabSwitcher(),
                  const SizedBox(height: 20),
                  isProfileTab ? _buildProfileDetails() : _buildResultDetails(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.grey[200],
            child: const Icon(Icons.person, size: 50),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                studentData?['StuNameEN'] ?? "N/A",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "ID : ${studentData?['StuID'] ?? 'N/A'}",
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [_tabButton("Profile", true), _tabButton("Result", false)],
      ),
    );
  }

  Widget _tabButton(String title, bool isProfile) {
    bool active = isProfileTab == isProfile;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => isProfileTab = isProfile),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                color: active ? Colors.white : primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          _infoRow("Name English", studentData?['StuNameEN']),
          _infoRow("Name Khmer", studentData?['StuNameKH']),
          _infoRow("StuName", studentData?['StuName']),
          _infoRow("Gender", studentData?['Gender']),
          // _infoRow("DOB", studentData?['DOB']),
          _infoRow(
            "DOB",
            studentData?['DOB'] != null
                ? studentData!['DOB'].toString().split('T')[0]
                : "N/A",
          ),
          _infoRow("Phone", studentData?['Phone']),
          _infoRow("Email", studentData?['Email']),
          _infoRow("Address", studentData?['Address']),
          _infoRow("Phone", studentData?['Phone']),
          _infoRow("Promotion", studentData?['Promotion']),
        ],
      ),
    );
  }

  Widget _buildResultDetails() {
    if (resultsData == null || resultsData!.isEmpty)
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 50),
          child: Text("No data available"),
        ),
      );

    return Column(
      children: resultsData!.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                "Semester ${entry.key}",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),
            ),
            // change this to table later if you want, but for now just show it as cards
            ...(entry.value as List)
                .map((item) => _buildScoreCard(item))
                .toList(),
            const SizedBox(height: 10),
          ],
        );
      }).toList(),
    );
  }

  // create new widget to show each subject score
  Widget _buildScoreCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item['subject']?['SubName'] ?? 'N/A', // ប្រើ SubName តាម DB
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Grade: ${item['Grade'] ?? '-'}",
                  style: GoogleFonts.poppins(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          // show scores in a row, if the score is null show 0, and if it's total score make it bold
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _scoreItem("Quiz", item['Quiz']),
              _scoreItem("HW", item['Homework']),
              _scoreItem("Att", item['AttendanceScore']),
              _scoreItem("Mid", item['Midterm']),
              _scoreItem("Fin", item['Final']),
              _scoreItem("Total", item['TotalScore'], isBold: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _scoreItem(String label, dynamic value, {bool isBold = false}) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
        ),
        Text(
          "${value ?? 0}",
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isBold ? primaryBlue : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          Text(
            value?.toString() ?? "N/A",
            style: GoogleFonts.poppins(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
