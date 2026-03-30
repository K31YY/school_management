// ignore_for_file: deprecated_member_use, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Ensure these imports match your project file names exactly
import 'package:ungthoung_app/module/auth/login_user.dart';
import 'package:ungthoung_app/menu/change_password.dart';
import 'package:ungthoung_app/students/my_result.dart';
import 'package:ungthoung_app/students/schedule.dart';
import 'package:ungthoung_app/students/stu_absent.dart';
import 'package:ungthoung_app/students/stu_attandance.dart';
import 'package:ungthoung_app/students/stu_class.dart';

void main() {
  runApp(const StudentDashboard());
}

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SchoolApp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily:
            'KantumruyPro', // Make sure this font is in your pubspec.yaml
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String userName = "Loading...";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final sp = await SharedPreferences.getInstance();
    setState(() {
      userName = sp.getString('FULLNAME') ?? "No Name";
    });
  }

  // --- THE FIXED LOGOUT DIALOG ---
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "Confirm Logout",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Are you sure you want to logout?",
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Closes the dialog
              child: Text(
                "Cancel",
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                final sp = await SharedPreferences.getInstance();
                await sp.clear(); // Clear user session

                // Navigate to Login and prevent going back
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginUser()),
                  (route) => false,
                );
              },
              child: Text(
                "Logout",
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  String getGreeting() {
    int hour = DateTime.now().hour;
    if (hour >= 12 && hour < 17) return 'Good Afternoon!';
    if (hour >= 17 && hour <= 24) return 'Good Evening!';
    return 'Good Morning!';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF4F6F8),
      drawer: _buildDrawer(),
      body: SingleChildScrollView(
        child: Column(children: [_buildHeader(context), _buildBody(context)]),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF4A5BF6)),
            accountName: Text(
              userName,
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text("Student Account", style: GoogleFonts.poppins()),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.black),
            ),
          ),
          _drawerItem(
            Icons.assessment_outlined,
            "View My Results",
            const MyProfileScreen(),
          ),
          _drawerItem(
            Icons.calendar_view_day_outlined,
            "View My Schedule",
            const ViewSchedule(),
          ),
          _drawerItem(
            Icons.fact_check_outlined,
            "View My Attendance",
            const MyAttendanceScreen(),
          ),
          const Divider(),
          _drawerItem(
            Icons.history_edu,
            "My Absent Requests",
            const RequestForYouScreen(),
          ),
          _drawerItem(
            Icons.lock_outline,
            "Change Password",
            const ChangePasswordScreen(),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(
              "Logout",
              style: GoogleFonts.poppins(color: Colors.red),
            ),
            onTap: _showLogoutDialog, // Triggers the dialog
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, Widget target) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: GoogleFonts.poppins()),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => target),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            height: 180,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF4A5BF6),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.menu,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    ),
                    const Text(
                      'Ung Thoung Buddhist\nHigh School',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Icon(
                      Icons.notifications,
                      color: Colors.white,
                      size: 30,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 120,
            left: 20,
            right: 20,
            child: _buildGreetingCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildGreetingCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
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
                  getGreeting(),
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const CircleAvatar(
            radius: 30,
            backgroundColor: Color(0xFFE3E6FD),
            child: Icon(Icons.person, size: 35, color: Color(0xFF4A5BF6)),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _infoCard(
                  'My Status',
                  'Active',
                  Icons.school,
                  const Color(0xFF4CFF50),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _infoCard(
                  'Year',
                  '2026',
                  Icons.event_note,
                  const Color(0xFFFF6B6B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            children: [
              _gridItem(
                'Results',
                Icons.analytics_outlined,
                const Color(0xFFD4F8E6),
                const Color(0xFF34C759),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyProfileScreen(),
                  ),
                ),
              ),
              _gridItem(
                'Schedule',
                Icons.auto_stories_outlined,
                const Color(0xFFE3E6FD),
                const Color(0xFF4A5BF6),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ViewSchedule()),
                ),
              ),
              _gridItem(
                'Attendance',
                Icons.rule_folder_outlined,
                const Color(0xFFFEF4DB),
                const Color(0xFFFF9500),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyAttendanceScreen(),
                  ),
                ),
              ),
              _gridItem(
                'Request',
                Icons.edit_note,
                const Color(0xFFE6DFFB),
                const Color(0xFF9059FF),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RequestForYouScreen(),
                  ),
                ),
              ),
              _gridItem(
                'Change Password',
                Icons.manage_accounts_outlined,
                const Color(0xFFD9EEFD),
                const Color(0xFF5AC8FA),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChangePasswordScreen(),
                  ),
                ),
              ),
              _gridItem(
                'Logout',
                Icons.logout,
                const Color(0xFFFEDDE4),
                const Color(0xFFFF3B30),
                onTap: _showLogoutDialog,
              ), // Triggers the dialog
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _gridItem(
    String label,
    IconData icon,
    Color bgColor,
    Color iconColor, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
