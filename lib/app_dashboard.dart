import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ungthoung_app/menu/navigation_menu.dart';
import 'package:ungthoung_app/menu/views_teacher.dart';
import 'package:ungthoung_app/students/student_dashboard.dart';

void main() {
  runApp(const AppDashboard());
}

class AppDashboard extends StatefulWidget {
  const AppDashboard({super.key});

  @override
  State<AppDashboard> createState() => _AppDashboardState();
}

class _AppDashboardState extends State<AppDashboard> {
  String? fullname;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final sp = await SharedPreferences.getInstance();
    setState(() {
      fullname = sp.getString("FULLNAME");
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SchoolApp',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'KantumruyPro'),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF4F6F8),
      drawer: const NavigetionMenu(),
      body: SingleChildScrollView(
        child: Column(children: [_buildHeader(context), _buildBody(context)]),
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
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //const Icon(Icons.menu, color: Colors.white, size: 30),
                        IconButton(
                          icon: const Icon(
                            Icons.menu,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: () {
                            _scaffoldKey.currentState?.openDrawer();
                          },
                        ),
                        const Text(
                          'Ung Thoung Buddhist\nHight School',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Stack(
                          children: [
                            const Icon(
                              Icons.notifications,
                              color: Colors.white,
                              size: 30,
                            ),
                            Positioned(
                              right: 2,
                              top: 2,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(6),
                                ),

                                constraints: const BoxConstraints(
                                  minWidth: 8,
                                  minHeight: 8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromRGBO(0, 0, 0, 0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good Evening',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'x',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/images/profile.jpg'),
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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
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
          const SizedBox(height: 20),
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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ViewsTeacher(),
                    ),
                  );
                },
              ),
              _buildGridItem(
                'Student\nLists',
                Icons.people_alt,
                const Color(0xFFE3E6FD),
                const Color(0xFF4A5BF6),
                onTap: () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StudentDashboard(),
                    ),
                  ),
                },
              ),
              _buildGridItem(
                'Subjects',
                Icons.book,
                const Color(0xFFFEF4DB),
                const Color(0xFFFF9500),
              ),
              _buildGridItem(
                'Class',
                Icons.meeting_room,
                const Color(0xFFE6DFFB),
                const Color(0xFF9059FF),
              ),
              _buildGridItem(
                'Reporting',
                Icons.bar_chart,
                const Color(0xFFD9EEFD),
                const Color(0xFF5AC8FA),
              ),
              _buildGridItem(
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
        boxShadow: [
          const BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            spreadRadius: 1,
            blurRadius: 10,
          ),
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
                  color: Colors.black,
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
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 10,
            ),
          ],
        ),
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
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
