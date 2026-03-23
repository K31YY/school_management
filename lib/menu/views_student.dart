// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ungthoung_app/menu/add_student.dart';
import 'package:ungthoung_app/menu/update_student.dart';

class ViewsStudent extends StatefulWidget {
  const ViewsStudent({super.key});

  @override
  State<ViewsStudent> createState() => _ViewsStudentState();
}

class _ViewsStudentState extends State<ViewsStudent> {
  List<dynamic> _allStudents = [];
  List<dynamic> _filteredStudents = [];
  bool _isLoading = true;
  final String apiUrl = 'http://10.0.2.2:8000/api/students';

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token =
          prefs.getString('TOKEN') ??
          "45|ExnLDDVzgQTUgxm9lEdkkJ6ulK4r152L8ksG2JJe24a49b3a";

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);
        if (decodedData['success'] == true) {
          setState(() {
            _allStudents = decodedData['data'];
            _filteredStudents = _allStudents;
          });
        }
      }
    } catch (e) {
      debugPrint("Fetch Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteStudent(String id) async {
    EasyLoading.show(status: 'Deleting...');
    final response = await http.delete(
      Uri.parse('$apiUrl/$id'),
      headers: {
        "Authorization":
            "Bearer 45|ExnLDDVzgQTUgxm9lEdkkJ6ulK4r152L8ksG2JJe24a49b3a",
      },
    );
    EasyLoading.dismiss();
    if (response.statusCode == 200) {
      EasyLoading.showSuccess("Deleted");
      _fetchStudents();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0066FF),
        title: const Text(
          "Student Lists",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddStudent()),
            ).then((_) => _fetchStudents()),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSearchBar(),
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredStudents.length,
                    itemBuilder: (context, index) {
                      final s = _filteredStudents[index];
                      // --- FIX ID NULL ---
                      final String studentId = (s['id'] ?? s['StuID'] ?? '')
                          .toString();
                      final String nameEN = s['StuNameEN'] ?? "Unknown";
                      final String nameKH = s['StuNameKH'] != null
                          ? " (${s['StuNameKH']})"
                          : "";

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFF0066FF),
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          // --- SHOW NAME KHMER LIKE OLD FORM ---
                          title: Text.rich(
                            TextSpan(
                              text: nameEN,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              children: [
                                TextSpan(
                                  text: nameKH,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          subtitle: Text("ID: $studentId"),
                          trailing: PopupMenuButton<String>(
                            onSelected: (val) {
                              if (val == 'edit') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UpdateStudentScreen(
                                      student: s,
                                      apiUrl: apiUrl,
                                    ),
                                  ),
                                ).then(
                                  (res) => {if (res == true) _fetchStudents()},
                                );
                              } else if (val == 'delete') {
                                _deleteStudent(studentId);
                              }
                            },
                            itemBuilder: (ctx) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Text(
                                  "Update",
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text(
                                  "Delete",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (val) {
          setState(() {
            _filteredStudents = _allStudents.where((s) {
              final nEN = (s['StuNameEN'] ?? "").toString().toLowerCase();
              final nKH = (s['StuNameKH'] ?? "").toString().toLowerCase();
              return nEN.contains(val.toLowerCase()) ||
                  nKH.contains(val.toLowerCase());
            }).toList();
          });
        },
        decoration: InputDecoration(
          hintText: "Search student...",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
