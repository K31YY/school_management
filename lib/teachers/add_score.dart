// ignore_for_file: curly_braces_in_flow_control_structures, avoid_print

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddScoreScreen extends StatefulWidget {
  const AddScoreScreen({super.key});

  @override
  State<AddScoreScreen> createState() => _AddScoreScreenState();
}

class _AddScoreScreenState extends State<AddScoreScreen> {
  final String baseUrl = "http://10.0.2.2:8000/api";
  List students = [], subjects = [], years = [];
  Map<String, dynamic>? existingScore; // for storing existing score data if found

  int? selectedStu, selectedSub, selectedYear, selectedSem;

  final Map<String, TextEditingController> _ctrls = {
    'Quiz': TextEditingController(),
    'Homework': TextEditingController(),
    'Attendance': TextEditingController(),
    'Participation': TextEditingController(),
    'Midterm': TextEditingController(),
    'Final': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  // get data for dropdowns (students, subjects, years)
  Future<void> _fetchInitialData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('TOKEN');
      final headers = {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      };

      final responses = await Future.wait([
        http.get(Uri.parse("$baseUrl/students"), headers: headers),
        http.get(Uri.parse("$baseUrl/subjects"), headers: headers),
        http.get(Uri.parse("$baseUrl/academic-years"), headers: headers),
      ]);

      if (responses.every((r) => r.statusCode == 200)) {
        setState(() {
          students = json.decode(responses[0].body)['data'];
          subjects = json.decode(responses[1].body)['data'];
          years = json.decode(responses[2].body)['data'];
        });
      }
    } catch (e) {
      EasyLoading.showError("Error loading data");
    }
  }

  // function to check if score already exists for selected student, subject, year, semester
  Future<void> _checkExistingScore() async {
    if (selectedStu == null || selectedSub == null || selectedSem == null)
      return;

    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('TOKEN');

      final response = await http.get(
        Uri.parse(
          "$baseUrl/studies/check?StuID=$selectedStu&SubID=$selectedSub&Semester=$selectedSem",
        ),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final resData = json.decode(response.body);
        setState(() {
          existingScore = resData['success'] ? resData['data'] : null;
        });
      }
    } catch (e) {
      print("Check error: $e");
    }
  }

  // show modal bottom sheet for entering/updating scores
  void _showScoreSheet() {
    // if score exists, populate text fields for easy editing or updating
    if (existingScore != null) {
      _ctrls['Quiz']!.text = existingScore!['Quiz'].toString();
      _ctrls['Homework']!.text = existingScore!['Homework'].toString();
      _ctrls['Attendance']!.text = existingScore!['AttendanceScore'].toString();
      _ctrls['Participation']!.text = existingScore!['Participation']
          .toString();
      _ctrls['Midterm']!.text = existingScore!['Midterm'].toString();
      _ctrls['Final']!.text = existingScore!['Final'].toString();
    } else {
      _ctrls.forEach((k, v) => v.clear());
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              existingScore != null ? "Update Score" : "Add New Score",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildScoreGrid(),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: existingScore != null
                      ? Colors.blue
                      : const Color(0xFF4A5BF6),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  if (existingScore != null) {
                    _handleUpdate(); // if score exists, call update function instead of save
                  } else {
                    _handleSave(); // if no score exists, call save function
                  }
                },
                child: Text(
                  existingScore != null ? "UPDATE" : "SAVE",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // function to save new score to database (POST request)
  Future<void> _handleSave() async {
    EasyLoading.show(status: 'Saving...');
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('TOKEN');

      final body = {
        "StuID": selectedStu,
        "SubID": selectedSub,
        "YearID": selectedYear,
        "Semester": selectedSem,
        "Quiz": double.tryParse(_ctrls['Quiz']!.text) ?? 0,
        "Homework": double.tryParse(_ctrls['Homework']!.text) ?? 0,
        "AttendanceScore": double.tryParse(_ctrls['Attendance']!.text) ?? 0,
        "Participation": double.tryParse(_ctrls['Participation']!.text) ?? 0,
        "Midterm": double.tryParse(_ctrls['Midterm']!.text) ?? 0,
        "Final": double.tryParse(_ctrls['Final']!.text) ?? 0,
      };

      final res = await http.post(
        Uri.parse("$baseUrl/studies"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      if (res.statusCode == 201) {
        EasyLoading.showSuccess("Save successful!");
        _checkExistingScore();
      } else if (res.statusCode == 409) {
        // show error message from backend
        final msg = json.decode(res.body)['message'];
        EasyLoading.showError(msg);
      } else {
        EasyLoading.showError("Failed ${res.statusCode}");
      }
    } catch (e) {
      EasyLoading.showError("Error: $e");
    }
  }

  // function to update existing score in database (PUT request)
  Future<void> _handleUpdate() async {
    EasyLoading.show(status: 'Updating...');
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('TOKEN');
      int studyId = existingScore!['StudyID']; // get id of existing score record to update

      final res = await http.put(
        Uri.parse("$baseUrl/studies/$studyId"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "Quiz": double.tryParse(_ctrls['Quiz']!.text) ?? 0,
          "Homework": double.tryParse(_ctrls['Homework']!.text) ?? 0,
          "AttendanceScore": double.tryParse(_ctrls['Attendance']!.text) ?? 0,
          "Participation": double.tryParse(_ctrls['Participation']!.text) ?? 0,
          "Midterm": double.tryParse(_ctrls['Midterm']!.text) ?? 0,
          "Final": double.tryParse(_ctrls['Final']!.text) ?? 0,
        }),
      );

      if (res.statusCode == 200) {
        EasyLoading.showSuccess("Update successful!");
        _checkExistingScore();
      }
    } catch (e) {
      EasyLoading.showError("Update Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Add Score"),
        backgroundColor: const Color(0xFF4A5BF6),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildMainDropdown(
              "Select Student",
              students,
              selectedStu,
              "StuID",
              "StuNameEN",
              (v) {
                setState(() => selectedStu = v);
                _checkExistingScore();
              },
            ),
            Row(
              children: [
                Expanded(
                  child: _buildMainDropdown(
                    "Year",
                    years,
                    selectedYear,
                    "YearID",
                    "YearName",
                    (v) => setState(() => selectedYear = v),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: _buildSemesterDropdown()),
              ],
            ),
            _buildMainDropdown(
              "Select Subject",
              subjects,
              selectedSub,
              "SubID",
              "SubName",
              (v) {
                setState(() => selectedSub = v);
                _checkExistingScore();
              },
            ),
            const SizedBox(height: 20),

            // bottom modal
            _buildScoreEntryButton(),

            const SizedBox(height: 30),
            if (existingScore != null) _buildExistingScoreCard(),
          ],
        ),
      ),
    );
  }

  // --- UI Helpers ---
  Widget _buildScoreEntryButton() {
    return InkWell(
      onTap: _showScoreSheet,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              existingScore != null
                  ? "View/Edit Current Scores"
                  : "Click to Enter Scores",
              style: TextStyle(
                color: existingScore != null ? Colors.blue : Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(
              existingScore != null ? Icons.edit : Icons.add_chart,
              color: existingScore != null ? Colors.blue : Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExistingScoreCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.green),
      ),
      child: Column(
        children: [
          const Text(
            "SCORE RECORDED",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const Divider(),
          Text(
            "Total: ${existingScore!['TotalScore']}",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            "Quiz: ${existingScore!['Quiz']} | Mid: ${existingScore!['Midterm']} | Final: ${existingScore!['Final']}",
          ),
        ],
      ),
    );
  }

  Widget _buildMainDropdown(
    String hint,
    List items,
    dynamic val,
    String idKey,
    String nameKey,
    Function(dynamic) onChange,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          hint: Text(hint),
          value: val,
          items: items
              .map(
                (i) => DropdownMenuItem<int>(
                  value: i[idKey],
                  child: Text(i[nameKey].toString()),
                ),
              )
              .toList(),
          onChanged: onChange,
        ),
      ),
    );
  }

  Widget _buildSemesterDropdown() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          hint: const Text("Semester"),
          value: selectedSem,
          items: [1, 2]
              .map(
                (s) =>
                    DropdownMenuItem<int>(value: s, child: Text("Semester $s")),
              )
              .toList(),
          onChanged: (v) {
            setState(() => selectedSem = v);
            _checkExistingScore();
          },
        ),
      ),
    );
  }

  Widget _buildScoreGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 12,
      children: _ctrls.entries
          .map(
            (e) => TextField(
              controller: e.value,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: e.key,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                contentPadding: const EdgeInsets.all(10),
              ),
            ),
          )
          .toList(),
    );
  }
}
