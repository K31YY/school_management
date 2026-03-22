import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Your original imports - Ensure these paths are correct in your project
import 'package:ungthoung_app/login_user.dart';
import 'package:ungthoung_app/menu/views_student.dart';
import 'package:ungthoung_app/teachers/attandance.dart';
import 'package:ungthoung_app/teachers/teacher.class.dart';
import 'package:ungthoung_app/teachers/add_score.dart';
import 'package:ungthoung_app/teachers/report.dart';
import 'package:ungthoung_app/menu/change_password.dart';
import 'package:ungthoung_app/teachers/teach_notify.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _userName = "Loading...";
  String _userRole = "Loading...";

  // Professional constants for your original color palette
  static const Color primaryBlue = Color(0xFF4A5BF6);
  static const Color backgroundGrey = Color(0xFFF0F0F0);
  static const Color salmonRed = Color(0xFFFF6B6B);
  static const Color brightGreen = Color(0xFF2ECC71);

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Rigorous data loading with safety checks
  Future<void> _loadUserData() async {
    final sp = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _userName = sp.getString('FULLNAME') ?? "No Name";
      _userRole = sp.getString('ROLE') ?? "No Role";
    });
  }

  // Professional Navigation Helper
  void _navigateTo(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  Future<void> _handleLogout() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Logout",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: const Text("Do you really want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final sp = await SharedPreferences.getInstance();
      await sp.clear();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginUser()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: backgroundGrey,
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          // Header Blue Background
          Container(
            height: 240,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: primaryBlue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  _buildTopBar(),
                  const SizedBox(height: 24),
                  _buildProfileCard(),
                  const SizedBox(height: 20),
                  _buildStatsRow(),
                  const SizedBox(height: 24),
                  _buildSectionHeader(
                    "Latest Admission",
                    Icons.groups_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildHorizontalAdmissionList(),
                  const SizedBox(height: 24),
                  _buildSectionHeader(
                    "Absent Students",
                    Icons.arrow_forward_ios,
                    isIconSmall: true,
                  ),
                  Text(
                    "List of students with low attendance",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Student List Items
                  const _StudentListItem(name: "Neat Tina", grade: "Grade 10"),
                  const _StudentListItem(name: "Reun Rin", grade: "Grade 10"),
                  const _StudentListItem(name: "Rom Sarun", grade: "Grade 10"),
                  const _StudentListItem(name: "Yum Danet", grade: "Grade 10"),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- REUSABLE COMPONENTS (Logic Cleaned, UI Preserved) ---

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.menu, color: Colors.white, size: 28),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        Column(
          children: [
            Text(
              "Ung Thoung Buddhist",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              "High School",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.notifications, color: Colors.white, size: 28),
          onPressed: () => _navigateTo(const NotificationRequestScreen()),
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userName,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  _userRole,
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
          const CircleAvatar(
            radius: 25,
            backgroundColor: Colors.black,
            child: Icon(Icons.person, color: Colors.white, size: 30),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return const Row(
      children: [
        _StatCard(
          color: salmonRed,
          title: "Teachers",
          value: "10",
          icon: Icons.groups,
        ),
        SizedBox(width: 16),
        _StatCard(
          color: brightGreen,
          title: "Class Attendance",
          value: "0.0%",
          icon: Icons.bar_chart,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    String title,
    IconData icon, {
    bool isIconSmall = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Icon(
          icon,
          color: isIconSmall ? Colors.black : Colors.grey,
          size: isIconSmall ? 16 : 24,
        ),
      ],
    );
  }

  Widget _buildHorizontalAdmissionList() {
    return const SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: BouncingScrollPhysics(),
      child: Row(
        children: [
          _AvatarItem(name: "I am a\nTeacher"),
          _AvatarItem(name: "Khoeurt\nSokhy"),
          _AvatarItem(name: "Roern\nRin"),
          _AvatarItem(name: "Roern\nRin"),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: primaryBlue),
            accountName: Text(
              _userName,
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(_userRole, style: GoogleFonts.poppins()),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.black, size: 40),
            ),
          ),
          _drawerTile(
            Icons.groups,
            "Students",
            () => _navigateTo(const ViewsStudent()),
          ),
          _drawerTile(
            Icons.assignment,
            "Attendance",
            () => _navigateTo(const MakeAttendanceScreen()),
          ),
          _drawerTile(
            Icons.class_,
            "My Classes",
            () => _navigateTo(const MyTimeClassroomScreen()),
          ),
          const Divider(),
          _drawerTile(
            Icons.score,
            "Add Score",
            () => _navigateTo(const AddScoreScreen()),
          ),
          _drawerTile(
            Icons.repartition,
            "Report",
            () => _navigateTo(const AdvancedReportingScreen()),
          ),

          _drawerTile(
            Icons.change_circle,
            "Change Password",
            () => _navigateTo(const ChangePasswordScreen()),
          ),

          const Divider(),
          _drawerTile(Icons.logout, "Logout", _handleLogout, color: Colors.red),
        ],
      ),
    );
  }

  Widget _drawerTile(
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: color,
          fontWeight: color != null ? FontWeight.w600 : null,
        ),
      ),
      onTap: onTap,
    );
  }
}

// --- EXTRACTED PRIVATE WIDGET CLASSES (Rigorous Professional Approach) ---

class _StatCard extends StatelessWidget {
  final Color color;
  final String title, value;
  final IconData icon;
  const _StatCard({
    required this.color,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        height: 120,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Icon(icon, color: Colors.white, size: 40),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarItem extends StatelessWidget {
  final String name;
  const _AvatarItem({required this.name});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.teal[200],
            child: const Icon(Icons.person, color: Colors.teal, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 11, height: 1.2),
          ),
        ],
      ),
    );
  }
}

class _StudentListItem extends StatelessWidget {
  final String name, grade;
  const _StudentListItem({required this.name, required this.grade});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  grade,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.phone, size: 20, color: Colors.black),
        ],
      ),
    );
  }
}
