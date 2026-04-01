// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ==========================================
// ផ្នែកទី ១: MODELS (សម្រាប់កាន់ទិន្នន័យ)
// ==========================================

class Attendance {
  final String date;
  final String student;
  final String status;
  Attendance({required this.date, required this.student, required this.status});
}

class StudyScore {
  final String student;
  final double total;
  final String grade;
  StudyScore({required this.student, required this.total, required this.grade});
}

class ScheduleDetail {
  final String subject;
  final String time;
  final String room;
  ScheduleDetail({
    required this.subject,
    required this.time,
    required this.room,
  });
}

// ==========================================
// ផ្នែកទី ២: UI SCREEN
// ==========================================

class ReportingScreen extends StatefulWidget {
  @override
  _ReportingScreenState createState() => _ReportingScreenState();
}

class _ReportingScreenState extends State<ReportingScreen> {
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();
  String? selectedClass;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F2F5),
      appBar: AppBar(
        title: Text(
          "Reporting System",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[800],
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- ផ្នែក Attendance Report ---
            _buildSectionCard(
              title: "Attendance Report",
              icon: Icons.calendar_month,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildDatePicker("From", fromDate)),
                      SizedBox(width: 12),
                      Expanded(child: _buildDatePicker("To", toDate)),
                    ],
                  ),
                  SizedBox(height: 15),
                  _buildDropdown("Select Class", ['10-A', '10-B', '11-C']),
                  SizedBox(height: 15),
                  _buildActionButton("Export Attendance", Colors.blue[700]!),
                ],
              ),
            ),

            // --- ផ្នែក Score Report ---
            _buildSectionCard(
              title: "Score (Study) Report",
              icon: Icons.assignment_turned_in,
              child: Column(
                children: [
                  _buildDropdown("Select Class", ['10-A', '10-B', '11-C']),
                  SizedBox(height: 12),
                  _buildDropdown("Select Month", [
                    'January',
                    'February',
                    'March',
                  ]),
                  SizedBox(height: 15),
                  _buildActionButton(
                    "Generate Score Sheet",
                    Colors.green[600]!,
                  ),
                ],
              ),
            ),

            // --- ផ្នែក Schedule Summary ---
            _buildSectionCard(
              title: "Schedule Details",
              icon: Icons.schedule,
              child: Column(
                children: [
                  _buildDropdown("Select Teacher", ['Mr. John', 'Ms. Savy']),
                  SizedBox(height: 15),
                  _buildActionButton("View Schedule", Colors.orange[700]!),
                ],
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // ផ្នែកទី ៣: REUSABLE WIDGETS (WIDGET ប្រើឡើងវិញ)
  // ==========================================

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue[800]),
              SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Divider(height: 25),
          child,
        ],
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        Container(
          margin: EdgeInsets.only(top: 5),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue.shade100),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('yyyy-MM-dd').format(date),
                style: TextStyle(fontSize: 13),
              ),
              Icon(Icons.access_time, size: 16, color: Colors.blue),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String hint, List<String> items) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue.shade100),
        ),
      ),
      hint: Text(hint, style: TextStyle(fontSize: 14)),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: (val) {},
    );
  }

  Widget _buildActionButton(String label, Color color) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () {},
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
