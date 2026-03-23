// ignore_for_file: avoid_print, unused_field, unnecessary_const, curly_braces_in_flow_control_structures
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ungthoung_app/menu/add_teacher.dart';
import 'package:ungthoung_app/menu/update_teacher.dart';

class ViewsTeacher extends StatefulWidget {
  const ViewsTeacher({super.key});

  @override
  State<ViewsTeacher> createState() => _ViewsTeacherState();
}

class _ViewsTeacherState extends State<ViewsTeacher> {
  List<dynamic> _allTeachers = [];
  List<dynamic> _filteredTeachers = [];
  bool _isLoading = true;
  String _searchQuery = "";

  final String apiUrl = 'http://10.0.2.2:8000/api/teachers';

  @override
  void initState() {
    super.initState();
    _fetchTeachers();
  }

  Future<void> _fetchTeachers() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('TOKEN');

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);
        if (decodedData['success'] == true && mounted) {
          setState(() {
            _allTeachers = decodedData['data'];
            _filteredTeachers = _allTeachers;
          });
        }
      }
    } catch (e) {
      debugPrint("Fetch Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteTeacher(String id) async {
    try {
      EasyLoading.show(status: 'Deleting...');
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('TOKEN');

      final response = await http.delete(
        Uri.parse('$apiUrl/$id'),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      EasyLoading.dismiss();
      if (response.statusCode == 200) {
        EasyLoading.showSuccess("Deleted Successfully");
        _fetchTeachers();
      } else {
        EasyLoading.showError("Delete failed");
      }
    } catch (e) {
      EasyLoading.dismiss();
      debugPrint("Delete error: $e");
    }
  }

  void _showDeleteDialog(dynamic teacher) {
    final String id = (teacher['id'] ?? teacher['TeacherID']).toString();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 10),
            Text("Confirm Delete"),
          ],
        ),
        content: Text(
          "Are you sure you want to delete ${teacher['TeacherName']}?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              _deleteTeacher(id);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A5BF6),
        title: const Text(
          "Teacher List",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddTeacher()),
            ).then((_) => _fetchTeachers()),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchTeachers,
                    child: _buildTeacherList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextField(
        onChanged: (val) => setState(() {
          _searchQuery = val;
          _filteredTeachers = _allTeachers
              .where(
                (t) => (t['TeacherName'] ?? "")
                    .toString()
                    .toLowerCase()
                    .contains(val.toLowerCase()),
              )
              .toList();
        }),
        decoration: InputDecoration(
          hintText: "Search by name...",
          prefixIcon: const Icon(Icons.search, color: Color(0xFF4A5BF6)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildTeacherList() {
    if (_filteredTeachers.isEmpty)
      return const Center(child: Text("No records found."));

    return ListView.builder(
      itemCount: _filteredTeachers.length,
      itemBuilder: (context, index) {
        final t = _filteredTeachers[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF4A5BF6).withOpacity(0.1),
              child: const Icon(Icons.person, color: Color(0xFF4A5BF6)),
            ),
            title: Text(
              t['TeacherName'] ?? 'No Name',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text("ID: ${t['id'] ?? t['TeacherID']}"),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              onSelected: (val) {
                if (val == 'edit') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          UpdateTeacherScreen(teacher: t, apiUrl: apiUrl),
                    ),
                  ).then((res) => {if (res == true) _fetchTeachers()});
                } else if (val == 'delete') {
                  _showDeleteDialog(t);
                }
              },
              itemBuilder: (ctx) => [
                // --- UPDATE OPTION ---
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_note_rounded,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Update",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // --- DELETE OPTION ---
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_forever_rounded, color: Colors.red),
                      const SizedBox(width: 10),
                      Text(
                        "Delete",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
