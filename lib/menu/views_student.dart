import 'package:flutter/material.dart';

class ViewsStudent extends StatefulWidget {
  const ViewsStudent({super.key});

  @override
  State<ViewsStudent> createState() => _ViewsStudentState();
}

class _ViewsStudentState extends State<ViewsStudent> {
  // Colors
  final Color _primaryBlue = const Color(0xFF4A5BF6);
  final Color _bgGray = const Color(0xFFF0F0F0);
  final Color _actionBlue = const Color(0xFF29B6F6); // Lighter blue for buttons

  // Mock Data
  // We keep track of the 'isExpanded' state for each student here
  List<Map<String, dynamic>> students = [
    {
      "name": "Student Name",
      "id": "Student ID",
      "isExpanded": true, // First one is open in the design
    },
    {"name": "Student Name", "id": "Student ID", "isExpanded": false},
    {"name": "Student Name", "id": "Student ID", "isExpanded": false},
    {"name": "Student Name", "id": "Student ID", "isExpanded": false},
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
          "Student Lists",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // 1. Top Filters Row
            Row(
              children: [
                Expanded(child: _buildDropdown(text: "10A - English")),
                const SizedBox(width: 15),
                Expanded(child: _buildDropdown(text: "2025-2026")),
              ],
            ),

            const SizedBox(height: 20),

            // 2. Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: _primaryBlue),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "Search",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  suffixIcon: Icon(Icons.search, color: Colors.black54),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // 3. Student List
            ListView.builder(
              shrinkWrap: true, // Important when inside SingleChildScrollView
              physics: const NeverScrollableScrollPhysics(),
              itemCount: students.length,
              itemBuilder: (context, index) {
                return _buildStudentItem(index);
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
        border: Border.all(color: _primaryBlue),
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
          const Icon(
            Icons.keyboard_arrow_down,
            size: 20,
            color: Colors.black87,
          ),
        ],
      ),
    );
  }

  Widget _buildStudentItem(int index) {
    final student = students[index];
    final bool isExpanded = student['isExpanded'];

    return Column(
      children: [
        // The Main Card
        GestureDetector(
          onTap: () {
            setState(() {
              // Toggle expansion logic
              // Option A: Allow multiple open ->
              student['isExpanded'] = !student['isExpanded'];

              // Option B: Only one open at a time (Accordion style) ->
              // for (var s in students) s['isExpanded'] = false;
              // students[index]['isExpanded'] = true;
            });
          },
          child: Container(
            color: Colors.transparent, // Ensures tap area is full width
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar
                const CircleAvatar(
                  radius: 24,
                  backgroundColor: Color(0xFF009688), // Teal/Green color
                  child: Icon(Icons.person, color: Colors.white),
                  // Use an Image.asset here for the specific vector face if you have it
                ),
                const SizedBox(width: 15),

                // Name & ID
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      student['id'],
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Icon (Changes based on state)
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_down
                      : Icons
                            .chevron_left, // Matches the image style (left arrow)
                  color: Colors.black87,
                ),
              ],
            ),
          ),
        ),

        // The Action Buttons (Only visible if expanded)
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(bottom: 20, top: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildActionButton("View Profile"),
                const SizedBox(width: 8),
                _buildActionButton("Add Score"),
                const SizedBox(width: 8),
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
        height: 36,
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
            fontSize: 11, // Small font to fit 3 in a row
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
