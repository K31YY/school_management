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
  List<dynamic> _allTeachers = []; // save all data from API here
  List<dynamic> _filteredTeachers =
      []; // save for display after search/filter logic
  bool _isLoading = true;

  // array for dropdown options (if needed in the future)
  String _searchQuery = "";
  String _selectedClass = "10 - A";
  String _selectedSubject = "English";

  final String apiUrl = 'http://10.0.2.2:8000/api/teachers';
  final String bearerToken =
      "45|ExnLDDVzgQTUgxm9lEdkkJ6ulK4r152L8ksG2JJe24a49b3a"; //

  @override
  void initState() {
    super.initState();
    _fetchTeachers();
  }

  Future<void> _fetchTeachers() async {
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
            _allTeachers = decodedData['data'];
            _filteredTeachers = _allTeachers; // show all data initially
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // Function to filter teachers based on search query and dropdown selections
  void _filterLogic() {
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
        title: Center(
          child: const Text(
            "Teacher Lists",
            style: TextStyle(color: Colors.white),
          ),
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
          // ១. ផ្នែក Select ថ្នាក់ និង មុខវិជ្ជា
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildFilterDropdown(
                    ["10 - A", "11 - B", "12 - C"],
                    _selectedClass,
                    (val) {
                      setState(() => _selectedClass = val!);
                      _filterLogic();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFilterDropdown(
                    ["English", "Math", "Khmer"],
                    _selectedSubject,
                    (val) {
                      setState(() => _selectedSubject = val!);
                      _filterLogic();
                    },
                  ),
                ),
              ],
            ),
          ),

          // ២. ផ្នែក Search
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 10),
            child: TextField(
              onChanged: (value) {
                _searchQuery = value;
                _filterLogic();
              },
              decoration: InputDecoration(
                hintText: "Search",
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

          // ៣. បញ្ជីឈ្មោះគ្រូ
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchTeachers,
                    child: _filteredTeachers.isEmpty
                        ? const Center(child: Text("រកមិនឃើញទិន្នន័យទេ"))
                        : ListView.builder(
                            itemCount: _filteredTeachers.length,
                            itemBuilder: (context, index) {
                              final t = _filteredTeachers[index];
                              return _buildTeacherCard(
                                t['TeacherName'] ?? 'N/A',
                                t['TeacherID'].toString(),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  // Widget សម្រាប់ Select Dropdown
  Widget _buildFilterDropdown(
    List<String> items,
    String currentVal,
    Function(String?) onChange,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentVal,
          isExpanded: true,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChange,
        ),
      ),
    );
  }

  Widget _buildTeacherCard(String name, String id) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFF00A693),
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Teacher ID: $id"),
      ),
    );
  }
}
