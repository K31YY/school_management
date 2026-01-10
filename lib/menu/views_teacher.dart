import 'package:flutter/material.dart';
import 'package:ungthoung_app/teachers/add_teacher.dart';

// Teacher data model
class Teacher {
  final String name;
  final String id;
  final String? assignedClass;
  final String? subject;
  final IconData icon;

  Teacher({
    required this.name,
    required this.id,
    this.assignedClass,
    this.subject,
    this.icon = Icons.person,
  });
}

class TeacherCard extends StatelessWidget {
  final Teacher teacher;
  final bool showButtons;

  const TeacherCard({
    required this.teacher,
    required this.showButtons,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(teacher.icon, color: Colors.blue),
        title: Text(teacher.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${teacher.id}'),
            if (teacher.assignedClass != null)
              Text('Class: ${teacher.assignedClass}'),
            if (teacher.subject != null) Text('Subject: ${teacher.subject}'),
          ],
        ),
        trailing: showButtons
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.delete), onPressed: () {}),
                ],
              )
            : const Icon(
                Icons.arrow_forward_ios, // Added forward arrow icon
                size: 16,
                color: Colors.grey, // Set color to grey instead of black
              ),
      ),
    );
  }
}

class ViewsTeacher extends StatefulWidget {
  const ViewsTeacher({super.key});

  @override
  State<ViewsTeacher> createState() => _ViewsTeacherState();
}

class _ViewsTeacherState extends State<ViewsTeacher> {
  String? _selectedClass;
  String? _selectedSubject;
  List<Teacher> _allTeachers = [];
  List<Teacher> _filteredTeachers = [];

  @override
  void initState() {
    super.initState();
    // Initialize teacher data
    _allTeachers = [
      Teacher(
        name: 'John Smith',
        id: '982342',
        assignedClass: '10 - A',
        subject: 'Math',
        icon: Icons.person,
      ),
      Teacher(
        name: 'Sarah Johnson',
        id: '887212',
        assignedClass: '11 - B',
        subject: 'English',
        icon: Icons.school,
      ),
      Teacher(
        name: 'Robert Smith',
        id: '452110',
        assignedClass: '12 - C',
        subject: 'Science',
        icon: Icons.face,
      ),
      Teacher(
        name: 'Jasmine Doe',
        id: '123998',
        assignedClass: '10 - A',
        subject: 'Math',
        icon: Icons.work,
      ),
      Teacher(
        name: 'Michael Brown',
        id: '334455',
        assignedClass: '11 - A',
        subject: 'Physics',
        icon: Icons.science,
      ),
      Teacher(
        name: 'Emily Wilson',
        id: '667788',
        assignedClass: '10 - B',
        subject: 'English',
        icon: Icons.book,
      ),
      Teacher(
        name: 'David Lee',
        id: '991122',
        assignedClass: '12 - A',
        subject: 'Computer Science',
        icon: Icons.computer,
      ),
    ];
    _filteredTeachers = List.from(_allTeachers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text(
          'Views Teacher',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // Back arrow
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddTeacher()),
            ),
            icon: const Icon(Icons.person_add, color: Colors.white),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _filterSection(),
            const SizedBox(height: 16),
            _searchBox(),
            const SizedBox(height: 16),
            Expanded(
              child: _filteredTeachers.isEmpty
                  ? const Center(
                      child: Text(
                        'No teachers found',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredTeachers.length,
                      itemBuilder: (context, index) {
                        final teacher = _filteredTeachers[index];
                        return TeacherCard(
                          teacher: teacher,
                          showButtons: index == 0,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterSection() {
    return FutureBuilder(
      future: _loadFilterData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasData) {
          final data = snapshot.data as Map<String, List<String>>;
          return Row(
            children: [
              Expanded(child: _buildClassDropdown(data['classes'] ?? [])),
              const SizedBox(width: 12),
              Expanded(child: _buildSubjectDropdown(data['subjects'] ?? [])),
              const SizedBox(width: 8),
              // Clear filter button
              IconButton(
                icon: const Icon(Icons.filter_alt_off, color: Colors.blue),
                onPressed: _clearFilters,
                tooltip: 'Clear filters',
              ),
            ],
          );
        }

        return const Text('Error loading data');
      },
    );
  }

  Widget _buildClassDropdown(List<String> classes) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: const Text('Select Class'),
          value: _selectedClass,
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('All Classes'),
            ),
            ...classes.map(
              (item) =>
                  DropdownMenuItem<String>(value: item, child: Text(item)),
            ),
          ],
          onChanged: (String? value) {
            setState(() {
              _selectedClass = value;
              _applyFilters();
            });
          },
        ),
      ),
    );
  }

  Widget _buildSubjectDropdown(List<String> subjects) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: const Text('Select Subject'),
          value: _selectedSubject,
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('All Subjects'),
            ),
            ...subjects.map(
              (item) =>
                  DropdownMenuItem<String>(value: item, child: Text(item)),
            ),
          ],
          onChanged: (String? value) {
            setState(() {
              _selectedSubject = value;
              _applyFilters();
            });
          },
        ),
      ),
    );
  }

  // Apply filters based on selected class and subject
  void _applyFilters() {
    setState(() {
      _filteredTeachers = _allTeachers.where((teacher) {
        bool matchesClass = true;
        bool matchesSubject = true;

        // Filter by class if selected
        if (_selectedClass != null) {
          matchesClass = teacher.assignedClass == _selectedClass;
        }

        // Filter by subject if selected
        if (_selectedSubject != null) {
          matchesSubject = teacher.subject == _selectedSubject;
        }

        return matchesClass && matchesSubject;
      }).toList();
    });
  }

  // Clear all filters
  void _clearFilters() {
    setState(() {
      _selectedClass = null;
      _selectedSubject = null;
      _filteredTeachers = List.from(_allTeachers);
    });
  }

  Widget _searchBox() {
    return TextField(
      onChanged: (query) {
        _searchTeachers(query);
      },
      decoration: InputDecoration(
        hintText: 'Search by name or ID',
        suffixIcon: const Icon(Icons.search, color: Colors.blue),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // Search functionality
  void _searchTeachers(String query) {
    if (query.isEmpty) {
      _applyFilters(); // Reapply filters without search
      return;
    }

    setState(() {
      final lowerQuery = query.toLowerCase();
      _filteredTeachers = _allTeachers.where((teacher) {
        final matchesName = teacher.name.toLowerCase().contains(lowerQuery);
        final matchesId = teacher.id.toLowerCase().contains(lowerQuery);
        return matchesName || matchesId;
      }).toList();
    });
  }

  Future<Map<String, List<String>>> _loadFilterData() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return {
      'classes': [
        '10 - A',
        '10 - B',
        '10 - C',
        '11 - A',
        '11 - B',
        '11 - C',
        '12 - A',
        '12 - B',
        '12 - C',
        '9 - A',
        '9 - B',
        '9 - C',
        '8 - A',
        '8 - B',
        '8 - C',
      ],
      'subjects': [
        'English',
        'Math',
        'Science',
        'History',
        'Geography',
        'Physics',
        'Chemistry',
        'Biology',
        'Computer Science',
        'Physical Education',
        'Art',
        'Music',
        'Economics',
      ],
    };
  }
}
