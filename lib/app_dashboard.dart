import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ungthoung_app/menu/assign_schedule.dart';
import 'package:ungthoung_app/menu/navigation_menu.dart';
import 'package:ungthoung_app/menu/report_area.dart';
import 'package:ungthoung_app/menu/views_student.dart';
import 'package:ungthoung_app/menu/views_teacher.dart';
import 'package:ungthoung_app/notification_screen.dart';
import 'package:ungthoung_app/students/student_dashboard.dart';

class AppDashboard extends StatefulWidget {
  const AppDashboard({super.key});

  @override
  State<AppDashboard> createState() => _AppDashboardState();
}

class _AppDashboardState extends State<AppDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // មុខងារទាញឈ្មោះពី SharedPreferences ជំនួស Firebase
  Future<String> _getUserName() async {
    final sp = await SharedPreferences.getInstance();
    // បើរកមិនឃើញឈ្មោះ វានឹងបង្ហាញថា Guest User
    return sp.getString('FULLNAME') ?? "Guest User";
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
      drawer: const NavigetionMenu(),
      body: FutureBuilder<String>(
        future: _getUserName(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ឈ្មោះដែលបានមកពី MySQL (ឧទាហរណ៍៖ admin01)
          String name = snapshot.data ?? "Guest User";
          String welcomeMessage = getGreeting();

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(context, name, welcomeMessage),
                _buildBody(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    String displayName,
    String greetingText,
  ) {
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
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.notifications,
                        size: 28,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationScreen(),
                        ),
                      ),
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
                          greetingText,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // បង្ហាញឈ្មោះពិតដែលទាញបានពី MySQL
                        Text(
                          displayName,
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
                    backgroundImage: NetworkImage(
                      'https://via.placeholder.com/150',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  'Teachers',
                  '10',
                  Icons.groups,
                  const Color(0xFFE3E6FD),
                  const Color(0xFF4A5BF6),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildInfoCard(
                  'Students',
                  '100',
                  Icons.school,
                  const Color(0xFFE3E6FD),
                  const Color(0xFF4A5BF6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            children: [
              _buildGridItem(
                context,
                'Teacher\nLists',
                Icons.cast_for_education,
                const Color(0xFFD4F8E6),
                const Color(0xFF34C759),
              ),
              _buildGridItem(
                context,
                'Student\nLists',
                Icons.people_alt,
                const Color(0xFFE3E6FD),
                const Color(0xFF4A5BF6),
              ),
              _buildGridItem(
                context,
                'Subjects',
                Icons.book,
                const Color(0xFFFEF4DB),
                const Color(0xFFFF9500),
              ),
              _buildGridItem(
                context,
                'Class',
                Icons.meeting_room,
                const Color(0xFFE6DFFB),
                const Color(0xFF9059FF),
              ),
              _buildGridItem(
                context,
                'Reporting',
                Icons.bar_chart,
                const Color(0xFFD9EEFD),
                const Color(0xFF5AC8FA),
              ),
              _buildGridItem(
                context,
                'Schedule',
                Icons.calendar_today,
                const Color(0xFFFEDDE4),
                const Color(0xFFFF3B30),
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
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                count,
                style: const TextStyle(
                  fontSize: 24,
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
            child: Icon(icon, color: iconColor, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(
    BuildContext context,
    String label,
    IconData icon,
    Color bgColor,
    Color iconColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          if (label.contains('Teacher')) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ViewsTeacher()),
            );
          } else if (label.contains('Student')) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ViewsStudent()),
            );
          } else if (label == 'Reporting') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ReportingScreen()),
            );
          } else if (label == 'Schedule') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AssignSchedule()),
            );
          } else if (label == 'Class') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StudentDashboard()),
            );
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
