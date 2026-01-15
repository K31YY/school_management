import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ungthoung_app/teachers/add_teacher.dart';
import 'package:ungthoung_app/menu/views_teacher.dart';

class NavigetionMenu extends StatefulWidget {
  const NavigetionMenu({super.key});

  @override
  State<NavigetionMenu> createState() => _NavigetionMenuState();
}

class _NavigetionMenuState extends State<NavigetionMenu> {
  String? fullname;
  String? email;
  Future<void> _logOut() async {
    final sp = await SharedPreferences.getInstance();
    await sp.clear();
    await FirebaseAuth.instance.signOut();
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final sp = await SharedPreferences.getInstance();
    setState(() {
      fullname = sp.getString("FULLNAME");
      email = sp.getString("EMAIL");
    });
  }

  Future<void> _confirmLogout(BuildContext context) async {
    Navigator.pop(context);
    final isLogiut = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Center(child: const Text('Confirm Logout')),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (isLogiut == true) {
      _logOut();
    }
  }

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
            context,
            Icons.view_list_outlined,
            () => _NavigateTo(context, ViewsTeacher()),
            title: 'Views Teacher',
          ),
          _buildMenuItem(
            context,
            Icons.person_add_outlined,
            () => _NavigateTo(context, AddTeacher()),
            title: 'Add Teacher',
          ),
          _buildMenuItem(
            context,
            Icons.calendar_today_outlined,
            'Assign Schedule',
          ),

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
          _buildMenuItem(context, Icons.view_list_outlined, 'Views Student'),
          _buildMenuItem(context, Icons.group_add_outlined, 'Add Student'),

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
          _buildMenuItem(context, Icons.bar_chart_outlined, 'Report Area'),
          _buildMenuItem(context, Icons.lock_outline, 'Change Password'),
          _buildMenuItem(context, Icons.logout, 'Logout', color: Colors.red),
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

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    dynamic titleOrCallback, {
    String? title,
    Color color = Colors.black87,
  }) {
    String displayTitle =
        title ?? (titleOrCallback is String ? titleOrCallback : '');
    VoidCallback onTapCallback = titleOrCallback is VoidCallback
        ? titleOrCallback
        : () {
            _confirmLogout(context);
          };

    return Center(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(displayTitle, style: TextStyle(color: color, fontSize: 15)),
        onTap: onTapCallback,
      ),
    );
  }

  void _NavigateTo(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }
}
