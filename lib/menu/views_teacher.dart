import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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

  final String apiUrl = 'http://10.0.2.2:8000/api/teachers';
  final String bearerToken =
      "45|ExnLDDVzgQTUgxm9lEdkkJ6ulK4r152L8ksG2JJe24a49b3a";

  @override
  void initState() {
    super.initState();
    _fetchTeachers();
  }

  Future<void> _fetchTeachers() async {
    // Only call setState if the widget is still in the tree
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
      } else {  
        debugPrint("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching teachers: $e");
    } finally {
      // CRITICAL FIX: Always check mounted before ending loading state
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterLogic() {
    if (!mounted) return;
    setState(() {
      _filteredTeachers = _allTeachers.where((teacher) {
        final name = (teacher['TeacherName'] ?? "").toString().toLowerCase();
        final matchesSearch = name.contains(_searchQuery.toLowerCase());
        return matchesSearch;
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
          Padding(
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
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchTeachers,
                    child: _filteredTeachers.isEmpty
                        ? ListView(
                            // Use ListView so RefreshIndicator still works
                            children: const [
                              SizedBox(height: 100),
                              Center(child: Text("Not found any teacher")),
                            ],
                          )
                        : ListView.builder(
                            itemCount: _filteredTeachers.length,
                            padding: const EdgeInsets.only(bottom: 20),
                            itemBuilder: (context, index) {
                              final t = _filteredTeachers[index];
                              return _buildTeacherCard(
                                t['TeacherName'] ?? 'No Name',
                                t['TeacherID']?.toString() ?? 'N/A',
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherCard(String name, String id) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Color(0xFFE5E5EA)),
      ),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFF0066FF), // Success green
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text("ID: $id", style: TextStyle(color: Colors.grey[600])),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Colors.grey,
        ),
        onTap: () {
          // Add navigation to Teacher Details here if needed
        },
      ),
    );
  }
}
