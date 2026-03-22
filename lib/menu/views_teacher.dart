import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ungthoung_app/menu/add_teacher.dart';

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

  // Configuration - Ensure 10.0.2.2 is correct for Android Emulator
  final String apiUrl = 'http://10.0.2.2:8000/api/teachers';
  final String bearerToken =
      "45|ExnLDDVzgQTUgxm9lEdkkJ6ulK4r152L8ksG2JJe24a49b3a";

  @override
  void initState() {
    super.initState();
    _fetchTeachers();
  }

  // GET: Fetch all teachers
  Future<void> _fetchTeachers() async {
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

  // PUT: Update teacher details
  Future<void> _updateTeacher(String id, String newName) async {
    try {
      EasyLoading.show(status: 'Updating...');

      final response = await http.put(
        Uri.parse('$apiUrl/$id'),
        headers: {
          "Authorization": "Bearer $bearerToken",
          "Content-Type": "application/json", // Required for PUT/POST bodies
          "Accept": "application/json",
        },
        body: jsonEncode({"TeacherName": newName}),
      );

      EasyLoading.dismiss();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          EasyLoading.showSuccess("Updated!");
          _fetchTeachers(); // Refresh list
        }
      } else {
        EasyLoading.showError("Update failed: ${response.statusCode}");
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError("Connection Error");
    }
  }

  // DELETE: Remove teacher
  Future<void> _deleteTeacher(String id) async {
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
        _fetchTeachers();
        EasyLoading.showSuccess("Deleted");
      }
    } catch (e) {
      EasyLoading.dismiss();
      debugPrint("Delete error: $e");
    }
  }

  void _filterLogic() {
    if (!mounted) return;
    setState(() {
      _filteredTeachers = _allTeachers.where((teacher) {
        final name = (teacher['TeacherName'] ?? "").toString().toLowerCase();
        return name.contains(_searchQuery.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF007AFF),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Teacher Lists",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
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
                    child: _filteredTeachers.isEmpty
                        ? _buildEmptyState()
                        : _buildTeacherList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 25, 12, 10),
      child: TextField(
        onChanged: (value) {
          _searchQuery = value;
          _filterLogic();
        },
        decoration: InputDecoration(
          hintText: "Search teacher name...",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
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
        Center(child: Text("Not found any teacher")),
      ],
    );
  }

  Widget _buildTeacherList() {
    return ListView.builder(
      itemCount: _filteredTeachers.length,
      padding: const EdgeInsets.only(bottom: 20),
      itemBuilder: (context, index) {
        final t = _filteredTeachers[index];
        return _buildTeacherCard(t);
      },
    );
  }

  Widget _buildTeacherCard(dynamic teacher) {
    final String name = teacher['TeacherName'] ?? 'No Name';
    final String id = teacher['TeacherID']?.toString() ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text("ID: $id", style: TextStyle(color: Colors.grey[600])),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.grey),
          onSelected: (value) {
            if (value == 'edit') {
              _showUpdateDialog(id, name);
            } else if (value == 'delete') {
              _showDeleteDialog(id, name);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit, color: Colors.blue, size: 20),
                title: Text("Update"),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red, size: 20),
                title: Text("Delete"),
                contentPadding: EdgeInsets.zero,
              ),
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
        title: const Text("Update Teacher"),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(labelText: "Full Name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateTeacher(id, editController.text.trim());
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
        content: Text("Delete $name permanently?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteTeacher(id);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
