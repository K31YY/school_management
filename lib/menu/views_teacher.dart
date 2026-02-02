import 'package:flutter/material.dart';

class ViewsTeacher extends StatefulWidget {
  const ViewsTeacher({super.key});

  @override
  State<ViewsTeacher> createState() => _ViewsTeacherState();
}

class _ViewsTeacherState extends State<ViewsTeacher> {
  // Colors
  final Color _primaryBlue = const Color(0xFF0D61FF); // Matches the header blue
  final Color _bgGray = const Color(0xFFF0F0F0);      // Light gray background
  final Color _actionBlue = const Color(0xFF29B6F6);  // Lighter blue for buttons
  
  // Mock Data
  List<Map<String, dynamic>> teachers = [
    {
      "name": "Teacher Name",
      "id": "Teacher ID",
      "isExpanded": true, // First one open by default
    },
    {
      "name": "Teacher Name",
      "id": "Teacher ID",
      "isExpanded": false,
    },
    {
      "name": "Teacher Name",
      "id": "Teacher ID",
      "isExpanded": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgGray,
      appBar: AppBar(
        backgroundColor: _primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Teacher Lists",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          // The 'Add User' icon specific to this screen
          IconButton(
            icon: const Icon(Icons.person_add, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // 1. Top Filters Row
            Row(
              children: [
                Expanded(child: _buildDropdown(text: "10 - A")),
                const SizedBox(width: 15),
                Expanded(child: _buildDropdown(text: "English")),
              ],
            ),

            const SizedBox(height: 20),

            // 2. Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: _primaryBlue.withOpacity(0.3)),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "Search",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  suffixIcon: Icon(Icons.search, color: Colors.black54),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // 3. Teacher List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: teachers.length,
              itemBuilder: (context, index) {
                return _buildTeacherItem(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildDropdown({required String text}) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _primaryBlue.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.black87)
        ],
      ),
    );
  }

  Widget _buildTeacherItem(int index) {
    final teacher = teachers[index];
    final bool isExpanded = teacher['isExpanded'];

    return Column(
      children: [
        // Main Card Row
        GestureDetector(
          onTap: () {
            setState(() {
              teacher['isExpanded'] = !teacher['isExpanded'];
            });
          },
          child: Container(
            color: Colors.transparent, 
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar
                const CircleAvatar(
                  radius: 24,
                  backgroundColor: Color(0xFF009688), // Teal color from image
                  child: Icon(Icons.person_4, color: Colors.white), 
                ),
                const SizedBox(width: 15),
                
                // Name & ID
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teacher['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      teacher['id'],
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                
                const Spacer(),
                
                // Expand Icon
                Icon(
                  isExpanded ? Icons.keyboard_arrow_down : Icons.chevron_left,
                  color: Colors.black87,
                ),
              ],
            ),
          ),
        ),

        // Action Buttons (Only 2 buttons for Teachers)
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(bottom: 20, top: 5),
            child: Row(
              children: [
                _buildActionButton("View Profile"),
                const SizedBox(width: 15), // Wider gap since there are only 2 buttons
                _buildActionButton("View Attendance"),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildActionButton(String label) {
    return Expanded(
      child: Container(
        height: 40, // Slightly taller than the student buttons
        decoration: BoxDecoration(
          color: _actionBlue,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}