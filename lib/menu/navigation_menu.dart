import 'package:flutter/material.dart';
import 'package:ungthoung_app/login_user.dart';
import 'package:ungthoung_app/menu/add_student.dart';
import 'package:ungthoung_app/menu/teacher/add_teacher.dart';
import 'package:ungthoung_app/menu/assign_schedule.dart';
import 'package:ungthoung_app/menu/change_password.dart';
import 'package:ungthoung_app/menu/report_area.dart';
import 'package:ungthoung_app/student_list.dart';
import 'package:ungthoung_app/teacher_list.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Padding(
        padding: EdgeInsets.zero,
        child: ListView(
          children: <Widget>[
            // Drawer Header
            Container(
              height: 180, // Adjust height as needed
              width: double.infinity,
              child: Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 300, // Make it bigger
                  height: 300,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            IntrinsicHeight(
              child: Row(
                children: const <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 16.0,
                    ),
                    child: Text(
                      'Teacher',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Colors.black,
                      thickness: 1,
                      // indent: 5,
                      // endIndent: 16,
                    ),
                  ),
                ],
              ),
            ),

            // Teacher Section
            _buildMenuItem(
              'View Teacher',
              Icons.list,
              () => _navigateTo(context, TeacherList()),
            ),
            _buildMenuItem(
              'Add Teacher',
              Icons.person_add,
              () => _navigateTo(context, AddTeacher()),
            ),
            _buildMenuItem(
              'Assign Schedule',
              Icons.edit_note,
              () => _navigateTo(context, AssignSchedule()),
            ),

            // Students Section
            IntrinsicHeight(
              child: Row(
                children: const <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 16.0,
                    ),
                    child: Text(
                      'Student',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Colors.black,
                      thickness: 1,
                      indent: 16,
                      endIndent: 16,
                    ),
                  ),
                ],
              ),
            ),
            _buildMenuItem(
              'View Student',
              Icons.list,
              () => _navigateTo(context, StudentList()),
            ),
            _buildMenuItem(
              'Add Student',
              Icons.person_add,
              () => _navigateTo(context, AddStudent()),
            ),

            // Setting Section
            IntrinsicHeight(
              child: Row(
                children: const <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 16.0,
                    ),
                    child: Text(
                      'Setting',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Colors.black,
                      thickness: 1,
                      indent: 16,
                      endIndent: 16,
                    ),
                  ),
                ],
              ),
            ),
            _buildMenuItem(
              'Report Area',
              Icons.area_chart,
              () => _navigateTo(context, ReportArea()),
            ),
            _buildMenuItem(
              'Change Password',
              Icons.lock,
              () => _navigateTo(context, ChangePassword()),
            ),

            Spacer(), // Pushes logout to bottom

            Divider(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: ListTile(
                leading: Icon(Icons.exit_to_app, color: Colors.red),
                title: Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  // Add logout logic
                  _showLogoutDialog(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, size: 22),
      title: Text(title, style: TextStyle(fontSize: 16)),
      contentPadding: EdgeInsets.only(left: 20, right: 20),
      minLeadingWidth: 0,
      onTap: onTap,
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Perform logout and navigate to login page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginUser()),
              );
            },
            child: Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
