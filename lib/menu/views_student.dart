import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ungthoung_app/menu/add_student.dart';

class ViewsStudent extends StatefulWidget {
  const ViewsStudent({super.key});

  @override
  State<ViewsStudent> createState() => _ViewsStudentState();
}

class _ViewsStudentState extends State<ViewsStudent> {
  List<dynamic> _allStudents = [];
  List<dynamic> _filteredStudents = [];
  bool _isLoading = true;
  String _searchQuery = "";

  // Configuration
  final String apiUrl = 'http://10.0.2.2:8000/api/students';
  final String bearerToken =
      "45|ExnLDDVzgQTUgxm9lEdkkJ6ulK4r152L8ksG2JJe24a49b3a";

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  // GET: Fetch all students
  Future<void> _fetchStudents() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $bearerToken",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);
        if (decodedData['success'] == true && mounted) {
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

  // PUT: Update student details (Example logic)
  Future<void> _updateStudent(String id, String newNameEN) async {
    try {
      EasyLoading.show(status: 'Updating...');
      final response = await http.put(
        Uri.parse('$apiUrl/$id'),
        headers: {
          "Authorization": "Bearer $bearerToken",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"StuNameEN": newNameEN}),
      );

      EasyLoading.dismiss();
      if (response.statusCode == 200) {
        EasyLoading.showSuccess("Updated!");
        _fetchStudents();
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError("Update failed");
    }
  }

  // DELETE: Remove student
  Future<void> _deleteStudent(String id) async {
    try {
      EasyLoading.show(status: 'Deleting...');
      final response = await http.delete(
        Uri.parse('$apiUrl/$id'),
        headers: {
          "Authorization": "Bearer $bearerToken",
          "Accept": "application/json",
        },
      );

      EasyLoading.dismiss();
      if (response.statusCode == 200) {
        _fetchStudents();
        EasyLoading.showSuccess("Deleted");
      }
    } catch (e) {
      EasyLoading.dismiss();
    }
  }

  void _filterLogic() {
    if (!mounted) return;
    setState(() {
      _filteredStudents = _allStudents.where((student) {
        final nameEN = (student['StuNameEN'] ?? "").toString().toLowerCase();
        final nameKH = (student['StuNameKH'] ?? "").toString().toLowerCase();
        final query = _searchQuery.toLowerCase();
        return nameEN.contains(query) || nameKH.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0066FF),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Student Lists",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.person_add_alt_1,
              color: Colors.white,
              size: 28,
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddStudent()),
            ).then((_) => _fetchStudents()),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchStudents,
                    child: _filteredStudents.isEmpty
                        ? _buildEmptyState()
                        : _buildStudentList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 25, 16, 10),
      child: TextField(
        onChanged: (val) {
          _searchQuery = val;
          _filterLogic();
        },
        decoration: InputDecoration(
          hintText: "Search student name...",
          prefixIcon: const Icon(Icons.search),
          fillColor: Colors.white,
          filled: true,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: const [
        SizedBox(height: 100),
        Center(child: Text("No students found")),
      ],
    );
  }

  Widget _buildStudentList() {
    return ListView.builder(
      itemCount: _filteredStudents.length,
      padding: const EdgeInsets.only(bottom: 20),
      itemBuilder: (context, index) {
        return _buildStudentCard(_filteredStudents[index]);
      },
    );
  }

  Widget _buildStudentCard(dynamic student) {
    final String nameEN = student['StuNameEN'] ?? "Unknown";
    final String nameKH = student['StuNameKH'] != null
        ? " (${student['StuNameKH']})"
        : "";
    final String id = student['StuID']?.toString() ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Color(0xFFE5E5EA)),
      ),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFF0066FF),
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text.rich(
          TextSpan(
            text: nameEN,
            style: const TextStyle(fontWeight: FontWeight.bold),
            children: [
              TextSpan(
                text: nameKH,
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
        subtitle: Text("ID: $id"),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.grey),
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showUpdateDialog(id, nameEN);
                break;
              case 'delete':
                _showDeleteDialog(id, nameEN);
                break;
              case 'score': /* Navigate to score screen */
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text("Update")),
            const PopupMenuItem(value: 'score', child: Text("Add Score")),
            const PopupMenuItem(
              value: 'delete',
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateDialog(String id, String currentName) {
    final TextEditingController editController = TextEditingController(
      text: currentName,
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Update Student"),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(labelText: "English Name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateStudent(id, editController.text.trim());
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(String id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: Text("Delete student $name?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteStudent(id);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
