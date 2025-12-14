import 'package:flutter/material.dart';
import 'package:ungthoung_app/app_colors.dart';
// import 'package:ungthoung_app/cards/category_screen.dart';
// import 'package:ungthoung_app/cards/groups_screen.dart';
// import 'package:ungthoung_app/cards/help_screen.dart';
// import 'package:ungthoung_app/cards/products_screen.dart';
// import 'package:ungthoung_app/cards/setting_screen.dart';
// import 'package:ungthoung_app/cards/teacher.dart';
import 'package:ungthoung_app/menu/navigation_menu.dart';

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
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
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
                      child: Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: <Widget>[
                               Text('Students', style: TextStyle(fontSize: 20)),
                              Icon(
                                Icons.people,
                                size: 40,
                                color: AppColors.button,
                              ),
                              SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: <Widget>[
                               Text('Teachers', style: TextStyle(fontSize: 20)),
                              Icon(
                                Icons.people,
                                size: 40,
                                color: AppColors.button,
                              ),
                              SizedBox(height: 10),
                            ],
                          ),
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
    );
  }
}

