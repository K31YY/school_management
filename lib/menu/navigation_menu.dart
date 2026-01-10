import 'package:flutter/material.dart';
import 'package:ungthoung_app/teachers/add_teacher.dart';
import 'package:ungthoung_app/menu/views_teacher.dart';

// Widget សម្រាប់ Drawer ទាំងមូល
class NavigetionMenu extends StatelessWidget {
  const NavigetionMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(),
          // Section: Teacher
          IntrinsicHeight(
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsetsGeometry.symmetric(
                    vertical: 10,
                    horizontal: 16,
                  ),
                  child: Text(
                    'Teacher',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
          _buildMenuItem(
            Icons.view_list_outlined,
            () => _NavigateTo(context, ViewsTeacher()),
            title: 'Views Teacher',
          ),
          _buildMenuItem(
            Icons.person_add_outlined,
            () => _NavigateTo(context, AddTeacher()),
            title: 'Add Teacher',
          ),
          _buildMenuItem(Icons.calendar_today_outlined, 'Assign Schedule'),

          // Section: Students
          IntrinsicHeight(
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsetsGeometry.symmetric(
                    vertical: 10,
                    horizontal: 16,
                  ),
                  child: Text(
                    'Students',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
          _buildMenuItem(Icons.view_list_outlined, 'Views Student'),
          _buildMenuItem(Icons.group_add_outlined, 'Add Student'),

          // Section: Setting
          IntrinsicHeight(
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsetsGeometry.symmetric(
                    vertical: 10,
                    horizontal: 16,
                  ),
                  child: Text(
                    'Setting',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
          _buildMenuItem(Icons.bar_chart_outlined, 'Report Area'),
          _buildMenuItem(Icons.lock_outline, 'Change Password'),
          _buildMenuItem(Icons.logout, 'Logout', color: Colors.red),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      child: Column(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: Colors.grey.shade200,
            child: const Icon(Icons.school, size: 50, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          const Text(
            'UNG THOUNG',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF003366),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'BUDDHIST HIGH SCHOOL',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Divider(height: 1, color: Colors.grey.shade300),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    dynamic titleOrCallback, {
    String? title,
    Color color = Colors.black87,
  }) {
    String displayTitle =
        title ?? (titleOrCallback is String ? titleOrCallback : '');
    VoidCallback onTapCallback = titleOrCallback is VoidCallback
        ? titleOrCallback as VoidCallback
        : () {};

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(displayTitle, style: TextStyle(color: color, fontSize: 15)),
      onTap: onTapCallback,
    );
  }

  void _NavigateTo(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }
}
