import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ungthoung_app/providers/auth_provider.dart';
import 'package:ungthoung_app/menu/views_student.dart';
import 'package:ungthoung_app/students/stu_attandance.dart';
import 'package:ungthoung_app/teachers/teacher.class.dart';
import 'package:ungthoung_app/teachers/add_score.dart';
import 'package:ungthoung_app/teachers/report.dart';
import 'package:ungthoung_app/menu/change_password.dart';
import 'package:ungthoung_app/teachers/teach_notify.dart';

class TeacherDashboard extends ConsumerStatefulWidget {
  const TeacherDashboard({super.key});

  @override
  ConsumerState<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends ConsumerState<TeacherDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Use Constants for your original colors
  static const Color primaryBlue = Color(0xFF4A5BF6);
  static const Color backgroundGrey = Color(0xFFF0F0F0);
  static const Color salmonRed = Color(0xFFFF6B6B);
  static const Color brightGreen = Color(0xFF2ECC71);

  @override
  Widget build(BuildContext context) {
    // RIGOROUS FIX: Watch the authProvider state for real-time updates
    final auth = ref.watch(authProvider);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: backgroundGrey,
      drawer: _buildDrawer(auth),
      body: Stack(
        children: [
          // Original Blue Header Background
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
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  _buildHeaderActions(),
                  const SizedBox(height: 24),
                  _buildProfileCard(auth),
                  const SizedBox(height: 20),
                  _buildStatsRow(),
                  const SizedBox(height: 24),
                  _buildSectionLabel("Latest Admission", Icons.groups_outlined),
                  const SizedBox(height: 16),
                  _buildAdmissionScroller(),
                  const SizedBox(height: 24),
                  _buildSectionLabel(
                    "Absent Students",
                    Icons.arrow_forward_ios,
                    isSmallIcon: true,
                  ),
                  Text(
                    "List of students with low attendance",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Original List Items
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

  // --- PRIVATE UI METHODS (Keeping your exact layout) ---

  Widget _buildHeaderActions() {
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
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NotificationRequestScreen(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard(AuthState auth) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  auth.fullName ?? "Teacher Name",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  auth.role ?? "Teacher",
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

  Widget _buildSectionLabel(
    String title,
    IconData icon, {
    bool isSmallIcon = false,
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
          color: isSmallIcon ? Colors.black : Colors.grey,
          size: isSmallIcon ? 16 : 24,
        ),
      ],
    );
  }

  Widget _buildAdmissionScroller() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: const [
          _AvatarItem(name: "I am a\nTeacher"),
          _AvatarItem(name: "Khoeurt\nSokhy"),
          _AvatarItem(name: "Roern\nRin"),
          _AvatarItem(name: "Roern\nRin"),
        ],
      ),
    );
  }

  // Inside your _TeacherDashboardState class, replace the _buildDrawer method:

  Widget _buildDrawer(AuthState auth) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: primaryBlue),
            accountName: Text(auth.fullName ?? "User"),
            accountEmail: Text(auth.role ?? "Role"),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.black),
            ),
          ),
          _DrawerTile(
            Icons.groups,
            "Students",
            () => _navigateTo(const ViewsStudent()),
          ),
          _DrawerTile(
            Icons.assignment,
            "Attendance",
            () => _navigateTo(const MyAttendanceScreen()),
          ),
          _DrawerTile(
            Icons.class_,
            "My Classes",
            () => _navigateTo(const MyTimeClassroomScreen()),
          ),
          const Divider(),
          _DrawerTile(
            Icons.score,
            "Add Score",
            () => _navigateTo(const AddScoreScreen()),
          ),
          _DrawerTile(
            Icons.repartition,
            "Report",
            () => _navigateTo(const AdvancedReportingScreen()),
          ),

          _DrawerTile(
            Icons.change_circle,
            "Change Password",
            () => _navigateTo(const ChangePasswordScreen()),
          ),

          const Divider(),
          _DrawerTile(
            Icons.logout,
            "Logout",
            () => ref.read(authProvider.notifier).logout(),
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  // Professional Navigation Helper
  void _navigateTo(Widget destination) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => destination),
    );
  }
}

// --- SUB-WIDGETS (PROPERLY EXTRACTED FOR PROFESSIONAL PERFORMANCE) ---

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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const CircleAvatar(
          backgroundColor: Colors.grey,
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(
          name,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(grade, style: GoogleFonts.poppins(fontSize: 12)),
        trailing: const Icon(Icons.phone, color: Colors.black),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;
  const _DrawerTile(this.icon, this.title, this.onTap, {this.color});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: GoogleFonts.poppins(color: color)),
      onTap: onTap,
    );
  }
}
