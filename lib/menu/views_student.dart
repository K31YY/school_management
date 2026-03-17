import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
  int? _expandedIndex;

  String _searchQuery = "";

  final String apiUrl = 'http://10.0.2.2:8000/api/students';
  final String bearerToken =
      "45|ExnLDDVzgQTUgxm9lEdkkJ6ulK4r152L8ksG2JJe24a49b3a";

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
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
        if (decodedData['success'] == true) {
          setState(() {
            _allStudents = decodedData['data'];
            _filteredStudents = _allStudents;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _filterLogic() {
    setState(() {
      _filteredStudents = _allStudents.where((student) {
        final name = (student['StuName'] ?? "").toString().toLowerCase();
        return name.contains(_searchQuery.toLowerCase());
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Student Lists",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.person_add_alt_1,
              color: Colors.white,
              size: 28,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddStudent()),
              ).then((_) => _fetchStudents());
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 15),
                TextField(
                  onChanged: (val) {
                    _searchQuery = val;
                    _filterLogic();
                  },
                  decoration: InputDecoration(
                    hintText: "Search",
                    suffixIcon: const Icon(Icons.search),
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchStudents,
                    child: ListView.builder(
                      itemCount: _filteredStudents.length,
                      itemBuilder: (context, index) {
                        final student = _filteredStudents[index];
                        bool isExpanded = _expandedIndex == index;
                        return _buildStudentItem(student, index, isExpanded);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentItem(dynamic student, int index, bool isExpanded) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF0066FF),
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text(
              student['StuName'] ?? "Student Name",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text("Student ID: ${student['StuID']}"),
            trailing: Icon(
              isExpanded
                  ? Icons.keyboard_arrow_down
                  : Icons.keyboard_arrow_left,
            ),
            onTap: () =>
                setState(() => _expandedIndex = isExpanded ? null : index),
          ),
        ),
        if (isExpanded)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.only(
              bottom: 12,
              left: 16,
              right: 16,
              top: 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton("View Profile"),
                _buildActionButton("Add Score"),
                _buildActionButton("View Attendance"),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildActionButton(String label) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF29B6F6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
