import 'package:flutter/material.dart';
import 'package:ungthoung_app/app_colors.dart';
import 'package:ungthoung_app/class.dart';
// import 'package:ungthoung_app/cards/category_screen.dart';
// import 'package:ungthoung_app/cards/groups_screen.dart';
// import 'package:ungthoung_app/cards/help_screen.dart';
// import 'package:ungthoung_app/cards/products_screen.dart';
// import 'package:ungthoung_app/cards/setting_screen.dart';
// import 'package:ungthoung_app/cards/teacher.dart';
import 'package:ungthoung_app/menu/navigation_menu.dart';
import 'package:ungthoung_app/report.dart';
import 'package:ungthoung_app/schedule.dart';
import 'package:ungthoung_app/student_list.dart';
import 'package:ungthoung_app/subject.dart';
import 'package:ungthoung_app/teacher_list.dart';

class AppDashboard extends StatefulWidget {
  const AppDashboard({super.key});

  @override
  State<AppDashboard> createState() => AppDashboardState();
}

class AppDashboardState extends State<AppDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Column(
            children: [
              Text(
                'Ung Thoung Buddhist',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
              ),
              Text(
                'High School',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(icon: Icon(Icons.notifications), onPressed: () {}),
        ],
      ),

      drawer: const NavigationMenu(),
      body: Container(
        color: AppColors.bgHome,
        child: Stack(
          children: <Widget>[
            // background
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.button,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
            ),
            // content
            ListView(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(10),
                  height: 140,
                  child: Card(
                    child: Stack(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.fromLTRB(10, 30, 10, 10),
                          child: Text(
                            'Good Evening',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(10, 70, 10, 10),
                          child: Text(
                            'BBU 212SS',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          bottom: 10,
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: AppColors.bgColor,
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/profile.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => TeacherList(),
                          //   ),
                          // );
                        },
                        child: Card(
                          margin: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: <Widget>[
                                    Text(
                                      'Teachers',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Icon(
                                      Icons.people,
                                      size: 40,
                                      color: AppColors.button,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // Navigator.push(
                          //   // context,
                          //   // MaterialPageRoute(
                          //   //   builder: (context) => const StudentList(),
                          //   // ),
                          // );
                        },
                        child: Card(
                          margin: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Column(
                                  children: <Widget>[
                                    Text(
                                      'Students',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Icon(
                                      Icons.people,
                                      size: 40,
                                      color: AppColors.button,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  children: <Widget>[
                    // Card 1
                    cardBox(
                      'Teacher List',
                      Icons.person,
                      imagePath: 'assets/images/profile.jpg',
                    ),
                    // Card 2
                    cardBox(
                      'Student List',
                      Icons.person_outline,
                      imagePath: '',
                    ),
                    // Card 3
                    cardBox('Subject', Icons.report, imagePath: ''),
                    // Card 4
                    cardBox('Class', Icons.class_, imagePath: ''),
                    // Card 5
                    cardBox(
                      'Report',
                      Icons.warning_amber_rounded,
                      imagePath: '',
                    ),
                    // Card 6
                    cardBox('Schedule', Icons.schedule, imagePath: ''),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget cardBox(
    String title,
    IconData icon, {
    VoidCallback? onTap,
    required String imagePath,
  }) {
    return SizedBox(
      child: Card(
        // InkWell, InkRespone, GestureDetector
        child: InkWell(
          onTap: () {
            if (title == 'Subject') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Subject()),
              );
            } else if (title == 'Class') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Class()),
              );
            } else if (title == 'Report') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Report()),
              );
            } else if (title == 'Schedule') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Schedule()),
              );
            } else if (title == 'Teacher List') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TeacherList()),
              );
            } else if (title == 'Student List') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StudentList()),
              );
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  // color: AppColors.bgColor,
                  borderRadius: BorderRadius.circular(180),
                ),
                child: Icon(icon, size: 55, color: AppColors.blue),
              ),
              SizedBox(height: 10),
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  color: AppColors.bgColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
