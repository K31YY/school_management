import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class MyTimeClassroomScreen extends StatefulWidget {
  const MyTimeClassroomScreen({super.key});

  @override
  State<MyTimeClassroomScreen> createState() => _MyTimeClassroomScreenState();
}

class _MyTimeClassroomScreenState extends State<MyTimeClassroomScreen> {
  // Colors
  final Color primaryBlue = const Color(0xFF0055FF);
  final Color backgroundGrey = const Color(0xFFF0F0F0);
  final Color borderGreen = const Color(
    0xFF2ECC71,
  ); // For the selected day border
  final Color textDark = const Color(0xFF333333);

  // State
  int selectedDayIndex = 0; // Default to Mon
  final List<String> days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGrey,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "My Time Classroom",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- 1. Day Selector ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(days.length, (index) {
                  return _buildDayItem(index);
                }),
              ),
            ),

            const SizedBox(height: 20),

            // --- 2. Schedule List ---
            _buildClassCard(
              subject: "English Grade 10",
              classroom: "Classroom 01",
              startTime: "7:00 AM",
              endTime: "8:00 AM",
            ),
            _buildClassCard(
              subject: "English Grade 10",
              classroom: "Classroom 02",
              startTime: "8:00 AM",
              endTime: "9:00 AM",
            ),
            _buildClassCard(
              subject: "English Grade 10",
              classroom: "Classroom 03",
              startTime: "2:00 PM",
              endTime: "3:00 PM",
            ),
            _buildClassCard(
              subject: "English Grade 10",
              classroom: "Classroom 04",
              startTime: "3:00 PM",
              endTime: "4:00 PM",
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildDayItem(int index) {
    bool isSelected = selectedDayIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDayIndex = index;
        });
      },
      child: Container(
        width: 45,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(
                  color: borderGreen,
                  width: 2,
                ) // Green border for selected
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          days[index],
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildClassCard({
    required String subject,
    required String classroom,
    required String startTime,
    required String endTime,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Side: Text Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subject,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: textDark,
                ),
              ),
              Text(
                classroom,
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
            ],
          ),

          // Right Side: Time Badges
          Row(
            children: [
              _buildTimeBadge(startTime, isDark: true),
              _buildTimeBadge(endTime, isDark: false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeBadge(String time, {required bool isDark}) {
    return Container(
      // Ensure badges touch each other or have minimal spacing based on design
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      width: 65,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF555555) : const Color(0xFFE0E0E0),
        borderRadius: isDark
            ? const BorderRadius.horizontal(
                left: Radius.circular(4),
              ) // Rounded left only
            : const BorderRadius.horizontal(
                right: Radius.circular(4),
              ), // Rounded right only
      ),
      child: Text(
        time,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isDark
              ? Colors.white
              : Colors.white, // In image both look white text
        ),
      ),
    );
  }
}
