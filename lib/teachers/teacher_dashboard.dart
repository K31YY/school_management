import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ungthoung_app/module/auth/login_user.dart';
import 'package:ungthoung_app/menu/change_password.dart';
import 'package:ungthoung_app/menu/views_student.dart';
import 'package:ungthoung_app/teachers/add_score.dart';
import 'package:ungthoung_app/teachers/attandance.dart';
import 'package:ungthoung_app/teachers/report.dart';
import 'package:ungthoung_app/teachers/teach_notify.dart';
import 'package:ungthoung_app/teachers/teacher.class.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final String baseUrl = "http://10.0.2.2:8000/api";

  String _userName = "Loading...";
  String _userRole = "Loading...";
  String _teacherCount = "0";
  List<dynamic> _recentTeachers = [];
  bool _isLoading = true;

  // Palette
  static const Color primaryBlue = Color(0xFF4A5BF6);
  static const Color backgroundGrey = Color(0xFFF0F0F0);
  static const Color salmonRed = Color(0xFFFF6B6B);
  static const Color brightGreen = Color(0xFF2ECC71);

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _loadUserData();
    await _fetchDashboardStats();
  }

  Future<void> _loadUserData() async {
    final sp = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _userName = sp.getString('FULLNAME') ?? "User";
      _userRole = sp.getString('ROLE') ?? "Teacher";
    });
  }

  Future<void> _fetchDashboardStats() async {
    final sp = await SharedPreferences.getInstance();
    final token = sp.getString('TOKEN');

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/teachers"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'] ?? [];

        setState(() {
          _teacherCount = data.length.toString();
          _recentTeachers = data.reversed.take(5).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Dashboard Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateTo(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    ).then((_) => _fetchDashboardStats()); // Refresh stats on return
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
            child: const Text("No"),
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
      body: RefreshIndicator(
        onRefresh: _fetchDashboardStats,
        child: Stack(
          children: [
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
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    _buildTopBar(),
                    const SizedBox(height: 24),
                    _buildProfileCard(),
                    const SizedBox(height: 20),
                    _buildStatsRow(), // Removed 'const' here
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
                    const SizedBox(height: 16),
                    const _StudentListItem(
                      name: "Neat Tina",
                      grade: "Grade 10",
                    ),
                    const _StudentListItem(name: "Reun Rin", grade: "Grade 10"),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI COMPONENTS ---

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

  // FIXED: No longer const because _teacherCount is dynamic
  Widget _buildStatsRow() {
    return Row(
      children: [
        _StatCard(
          color: salmonRed,
          title: "Teachers",
          value: _teacherCount,
          icon: Icons.groups,
        ),
        const SizedBox(width: 16),
        const _StatCard(
          color: brightGreen,
          title: "Attendance",
          value: "0.0%",
          icon: Icons.bar_chart,
        ),
      ],
    );
  }

  Widget _buildHorizontalAdmissionList() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_recentTeachers.isEmpty) return const Text("No recent teachers found");

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _recentTeachers.map((t) {
          return _AvatarItem(
            name: t['TeacherName'].toString().replaceFirst(' ', '\n'),
          );
        }).toList(),
      ),
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
            "Manage Students",
            () => _navigateTo(const ViewsStudent()),
          ),
          _drawerTile(
            Icons.assignment,
            "Attendance",
            () => _navigateTo(const MakeAttendanceScreen()),
          ),
          // Locate this in your _buildDrawer() method:
          _drawerTile(
            Icons.class_,
            "My Classes",
            () => _navigateTo(
              const MyTimeClassroomScreen(isReadOnly: true),
            ), // Pass the flag
          ),
          const Divider(),
          _drawerTile(
            Icons.score,
            "Add Score",
            () => _navigateTo(const AddScoreScreen()),
          ),
          _drawerTile(
            Icons.report,
            "Report",
            () => _navigateTo(const AdvancedReportingScreen()),
          ),
          _drawerTile(
            Icons.change_circle,
            "Change Password",
            () => _navigateTo(const ChangePasswordScreen()),
          ),
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

// --- HELPER CLASSES ---

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
                fontSize: 13,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                Icon(icon, color: Colors.white, size: 30),
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
