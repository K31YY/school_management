import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ungthoung_app/login_user.dart';
import 'package:ungthoung_app/menu/views_student.dart';
import 'package:ungthoung_app/teachers/add_score.dart';
import 'package:ungthoung_app/teachers/attandance.dart';
import 'package:ungthoung_app/teachers/report.dart';
import 'package:ungthoung_app/teachers/teach_changepassword.dart';
import 'package:ungthoung_app/teachers/teach_notify.dart';
import 'package:ungthoung_app/teachers/teacher.class.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Variable for storing user data
  String userName = "Loading...";
  String userRole = "Loading...";

  final Color primaryBlue = const Color(0xFF4A5BF6);
  final Color backgroundGrey = const Color(0xFFF0F0F0);
  final Color salmonRed = const Color(0xFFFF6B6B);
  final Color brightGreen = const Color(0xFF2ECC71);

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Function data user from SharedPreferences
  Future<void> _loadUserData() async {
    final sp = await SharedPreferences.getInstance();
    setState(() {
      userName = sp.getString('FULLNAME') ?? "No Name";
      userRole = sp.getString('ROLE') ?? "No Role";
    });
  }

  // Function for Logout
  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Logout Confirmation",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Do you really want to logout?",
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              child: Text("No", style: GoogleFonts.poppins(color: Colors.grey)),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text("Yes", style: GoogleFonts.poppins(color: Colors.red)),
              onPressed: () async {
                final sp = await SharedPreferences.getInstance();
                await sp.clear(); // delete all data in SharedPreferences

                if (!mounted) return;
                // push to login screen and remove all previous routes
                Navigator.pushAndRemoveUntil(
                  // ignore: use_build_context_synchronously
                  context,
                  MaterialPageRoute(builder: (context) => const LoginUser()),
                  (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: backgroundGrey,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: primaryBlue),
              accountName: Text(
                userName,
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(userRole, style: GoogleFonts.poppins()),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.black, size: 40),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.groups),
              title: Text("Students", style: GoogleFonts.poppins()),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ViewsStudent()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment),
              title: Text("Attendance", style: GoogleFonts.poppins()),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MakeAttendanceScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.class_),
              title: Text("My Classes", style: GoogleFonts.poppins()),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyTimeClassroomScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.score),
              title: Text("Add Score", style: GoogleFonts.poppins()),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddScoreScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.repartition),
              title: Text("Report", style: GoogleFonts.poppins()),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdvancedReportingScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.change_circle),
              title: Text("Change Password", style: GoogleFonts.poppins()),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TeachChangepassword(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(
                "Logout",
                style: GoogleFonts.poppins(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: _handleLogout,
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            height: 240,
            width: double.infinity,
            decoration: BoxDecoration(
              color: primaryBlue,
              borderRadius: const BorderRadius.only(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.menu,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: () =>
                            _scaffoldKey.currentState?.openDrawer(),
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
                        icon: const Icon(
                          Icons.notifications,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const NotificationRequestScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Teacher Profile Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          // ignore: deprecated_member_use
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
                                userName,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                userRole,
                                style: GoogleFonts.poppins(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.black,
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          color: salmonRed,
                          title: "Teachers",
                          value: "10",
                          icon: Icons.groups,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          color: brightGreen,
                          title: "Class Attendance",
                          value: "0.0%",
                          icon: Icons.bar_chart,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Latest Admission",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(Icons.groups_outlined, color: Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildAvatarItem("I am a\nTeacher", true),
                        _buildAvatarItem("Khoeurt\nSokhy", false),
                        _buildAvatarItem("Roern\nRin", false),
                        _buildAvatarItem("Roern\nRin", false),
                        _buildAvatarItem("Roern\nRin", false),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Absent Students",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "List of students with low attendance",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.black,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildStudentListItem("Neat Tina", "Grade 10"),
                  _buildStudentListItem("Reun Rin", "Grade 10"),
                  _buildStudentListItem("Rom Sarun", "Grade 10"),
                  _buildStudentListItem("Yum Danet", "Grade 10"),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required Color color,
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
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
    );
  }

  Widget _buildAvatarItem(String name, bool isTeacher) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.teal[200],
            child: Icon(Icons.person, color: Colors.teal[900], size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey[800],
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentListItem(String name, String grade) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.phone, size: 20),
          ),
        ],
      ),
    );
  }
}
