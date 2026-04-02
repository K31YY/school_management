import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddAttendanceScreen extends StatefulWidget {
  const AddAttendanceScreen({super.key});

  @override
  State<AddAttendanceScreen> createState() => _AddAttendanceScreenState();
}

class _AddAttendanceScreenState extends State<AddAttendanceScreen> {
  final String baseUrl = "http://10.0.2.2:8000/api";
  List scheduleDetails = [];
  List students = [];

  int? selectedDetailID;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  // get data for schedule details and students from API
  Future<void> _fetchInitialData() async {
    EasyLoading.show(status: 'Loading...');
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('TOKEN');
      final headers = {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      };

      final responses = await Future.wait([
        http.get(Uri.parse("$baseUrl/schedule-details"), headers: headers),
        http.get(Uri.parse("$baseUrl/students"), headers: headers),
      ]);

      if (responses[0].statusCode == 200 && responses[1].statusCode == 200) {
        setState(() {
          scheduleDetails = json.decode(responses[0].body)['data'];
          List rawStudents = json.decode(responses[1].body)['data'];

          // generate student list with default attendance
          students = rawStudents.map((s) {
            return {
              "StuID": s['StuID'],
              "StuNameKH": s['StuNameKH'],
              "Status": "P", // P = Present, A = Absent, P_Auth = Permission
              "Reason": "",
            };
          }).toList();
        });
        EasyLoading.dismiss();
      }
    } catch (e) {
      EasyLoading.showError("Error: $e");
    }
  }

  // function to submit attendance data to backend (POST request)
  Future<void> _submitAttendance() async {
    if (selectedDetailID == null) {
      EasyLoading.showInfo("សូមជ្រើសរើសម៉ោងសិក្សា!");
      return;
    }

    EasyLoading.show(status: 'Saving...');
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('TOKEN');

      // generate data for submission to backend
      final body = {
        "attendance_data": students
            .map(
              (s) => {
                "StuID": s['StuID'],
                "DetailID": selectedDetailID,
                "AttDate": selectedDate.toIso8601String().split('T')[0],
                "Status": s['Status'],
                "Reason": s['Reason'],
              },
            )
            .toList(),
      };

      final res = await http.post(
        Uri.parse("$baseUrl/attendances"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      if (res.statusCode == 201) {
        EasyLoading.showSuccess("Attendance saved successfully!");
      } else {
        EasyLoading.showError("Failed: ${res.statusCode}");
      }
    } catch (e) {
      EasyLoading.showError("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Take Attendance"),
        backgroundColor: const Color(0xFF4A5BF6),
        actions: [
          IconButton(
            onPressed: _submitAttendance,
            icon: const Icon(Icons.save, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeaderFilters(),
          Expanded(child: _buildStudentList()),
        ],
      ),
    );
  }

  // UI: Header with dropdown for schedule details and date picker
  Widget _buildHeaderFilters() {
    return Container(
      padding: const EdgeInsets.all(15),
      color: Colors.white,
      child: Column(
        children: [
          DropdownButtonFormField<int>(
            decoration: const InputDecoration(labelText: "Select Class/Time"),
            value: selectedDetailID,
            items: scheduleDetails
                .map(
                  (d) => DropdownMenuItem<int>(
                    value: d['DetailID'],
                    child: Text(
                      "${d['subject']['SubName']} (${d['StartTime']}-${d['EndTime']})",
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => selectedDetailID = v),
          ),
          const SizedBox(height: 10),
          ListTile(
            title: Text("Date: ${selectedDate.toLocal()}".split(' ')[0]),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) setState(() => selectedDate = picked);
            },
          ),
        ],
      ),
    );
  }

  // UI: list student 
  Widget _buildStudentList() {
    return ListView.builder(
      itemCount: students.length,
      itemBuilder: (context, index) {
        var s = students[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            leading: CircleAvatar(child: Text("${index + 1}")),
            title: Text(s['StuNameKH']),
            subtitle: s['Status'] != 'P'
                ? Text("Reason: ${s['Reason']}")
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _statusButton(index, 'P', Colors.green, "P"),
                _statusButton(index, 'A', Colors.red, "A"),
                _statusButton(index, 'P_Auth', Colors.orange, "L"),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget for attendance status buttons (P, A, L)
  Widget _statusButton(int index, String status, Color color, String label) {
    bool isSelected = students[index]['Status'] == status;
    return GestureDetector(
      onTap: () {
        setState(() => students[index]['Status'] = status);
        if (status != 'P') _showReasonDialog(index);
      },
      child: Container(
        margin: const EdgeInsets.only(left: 5),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey[200],
          shape: BoxShape.circle,
        ),
        child: Text(
          label,
          style: TextStyle(color: isSelected ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  // show dailog to enter reason for absence when status is A or L
  void _showReasonDialog(int index) {
    TextEditingController reasonCtrl = TextEditingController(
      text: students[index]['Reason'],
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reason for Absence"),
        content: TextField(
          controller: reasonCtrl,
          decoration: const InputDecoration(hintText: "Enter reason..."),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => students[index]['Reason'] = reasonCtrl.text);
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
