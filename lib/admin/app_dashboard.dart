import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// Navigation Imports
import 'package:ungthoung_app/menu/assign_schedule.dart';
import 'package:ungthoung_app/menu/navigation_menu.dart';
import 'package:ungthoung_app/menu/report_area.dart';
import 'package:ungthoung_app/menu/subject_screen.dart';
import 'package:ungthoung_app/menu/views_student.dart';
import 'package:ungthoung_app/menu/views_teacher.dart';
import 'package:ungthoung_app/admin/notification_screen.dart';
import 'package:ungthoung_app/teachers/teacher.class.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _teacherCount = 0;
  int _studentCount = 0;
  bool _isLoading = true;
  String _displayName = "Admin";
  String _userRole = ""; // Added to track role

  @override
  void initState() {
    super.initState();
    _initializeDashboard();
  }

  Future<void> _initializeDashboard() async {
    await _loadUserData();
    if (_userRole.toLowerCase().contains('admin')) {
      await _fetchDashboardData();
    } else {
      debugPrint(
        "Warning: User is accessing AdminDashboard with role: $_userRole",
      );
    }
  }

  Future<void> _loadUserData() async {
    final sp = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _displayName = sp.getString('FULLNAME') ?? "Admin User";
      _userRole = sp.getString('ROLE') ?? ""; // Load role from storage
    });
  }

  Future<void> _fetchDashboardData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('TOKEN');

      final response = await http
          .get(
            Uri.parse('http://10.0.2.2:8000/api/dashboard-counts'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _teacherCount = data['teachers'] ?? 0;
          _studentCount = data['students'] ?? 0;
          _isLoading = false;
        });
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Dashboard Fetch Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Helper for Clean Navigation
  void _navigateTo(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF4F6F8),
      drawer: const NavigationMenu(),
      body: RefreshIndicator(
        onRefresh: _fetchDashboardData,
        color: const Color(0xFF4A5BF6),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(children: [_buildHeader(), _buildBody()]),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final hour = DateTime.now().hour;
    String greeting = hour < 12
        ? 'Good Morning!'
        : hour < 17
        ? 'Good Afternoon!'
        : 'Good Evening!';

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
                    IconButton(
                      icon: const Icon(
                        Icons.notifications,
                        size: 28,
                        color: Colors.white,
                      ),
                      onPressed: () => _navigateTo(const NotificationScreen()),
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
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 5),
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
                          greeting,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _displayName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const CircleAvatar(
                    radius: 25,
                    backgroundColor: Color(0xFF4A5BF6),
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  'Teachers',
                  _isLoading ? '...' : '$_teacherCount',
                  Icons.groups,
                  const Color(0xFFE3E6FD),
                  const Color(0xFF4A5BF6),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildInfoCard(
                  'Students',
                  _isLoading ? '...' : '$_studentCount',
                  Icons.school,
                  const Color(0xFFE3E6FD),
                  const Color(0xFF4A5BF6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            children: [
              _buildGridItem(
                'Teacher\nLists',
                Icons.cast_for_education,
                const Color(0xFFD4F8E6),
                const Color(0xFF34C759),
                () => _navigateTo(const ViewsTeacher()),
              ),
              _buildGridItem(
                'Student\nLists',
                Icons.people_alt,
                const Color(0xFFE3E6FD),
                const Color(0xFF4A5BF6),
                () => _navigateTo(const ViewsStudent()),
              ),
              _buildGridItem(
                'Subjects',
                Icons.book,
                const Color(0xFFFEF4DB),
                const Color(0xFFFF9500),
                () => _navigateTo(const ViewsSubject()),
              ),
              _buildGridItem(
                'Class',
                Icons.meeting_room,
                const Color(0xFFE6DFFB),
                const Color(0xFF9059FF),
                () => _navigateTo(const MyTimeClassroomScreen()),
              ),
              _buildGridItem(
                'Reporting',
                Icons.bar_chart,
                const Color(0xFFD9EEFD),
                const Color(0xFF5AC8FA),
                () => _navigateTo(ReportingScreen()),
              ),
              _buildGridItem(
                'Schedule',
                Icons.calendar_today,
                const Color(0xFFFEDDE4),
                const Color(0xFFFF3B30),
                () => _navigateTo(const AssignSchedule()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    String title,
    String count,
    IconData icon,
    Color bgColor,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 5),
              Text(
                count,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(
    String label,
    IconData icon,
    Color bgColor,
    Color iconColor,
    VoidCallback onTap,
  ) {
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
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
