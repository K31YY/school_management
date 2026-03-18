import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ungthoung_app/login_user.dart';
import 'package:ungthoung_app/menu/add_student.dart';
import 'package:ungthoung_app/menu/add_teacher.dart';
import 'package:ungthoung_app/menu/assign_schedule.dart';
import 'package:ungthoung_app/menu/change_password.dart';
import 'package:ungthoung_app/menu/report_area.dart';
import 'package:ungthoung_app/menu/views_student.dart';
import 'package:ungthoung_app/menu/views_teacher.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key});

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  String? fullname;
  String? role;

  /// Clears local data and forces navigation to the Login Screen
  Future<void> _logOut(BuildContext context) async {
    final sp = await SharedPreferences.getInstance();
    await sp.clear();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginUser()),
      (Route<dynamic> route) => false,
    );
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
      role = sp.getString("ROLE");
    });
  }

  /// Shows logout confirmation dialog
  Future<void> _confirmLogout(BuildContext context) async {
    final isLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Center(child: Text('Confirm Logout')),
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

    if (isLogout == true) {
      if (!context.mounted) return;
      await _logOut(context);
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
          _buildSectionHeader('Teacher'),
          _buildMenuItem(
            context,
            Icons.view_list_outlined,
            () => _navigateTo(context, const ViewsTeacher()),
            title: 'Views Teacher',
          ),
          _buildMenuItem(
            context,
            Icons.person_add_outlined,
            () => _navigateTo(context, const AddTeacher()),
            title: 'Add Teacher',
          ),
          _buildMenuItem(
            context,
            Icons.calendar_today_outlined,
            () => _navigateTo(context, const AssignSchedule()),
            title: 'Assign Schedule',
          ),
          _buildSectionHeader('Students'),
          _buildMenuItem(
            context,
            Icons.view_list_outlined,
            () => _navigateTo(context, const ViewsStudent()),
            title: 'Views Student',
          ),
          _buildMenuItem(
            context,
            Icons.group_add_outlined,
            () => _navigateTo(context, const AddStudent()),
            title: 'Add Student',
          ),
          _buildSectionHeader('Setting'),
          _buildMenuItem(
            context,
            Icons.bar_chart_outlined,
            () => _navigateTo(context, const ReportingScreen()),
            title: 'Report Area',
          ),
          _buildMenuItem(
            context,
            Icons.lock_outline,
            () => _navigateTo(context, const ChangePasswordScreen()),
            title: 'Change Password',
          ),
          _buildMenuItem(
            context,
            Icons.logout,
            () => _confirmLogout(context),
            title: 'Logout',
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const Expanded(child: Divider(color: Colors.black, thickness: 1)),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 45,
            backgroundColor: Colors.white,
            child: Icon(Icons.school, size: 50, color: Colors.blue),
          ),
          const SizedBox(height: 16),
          Text(
            fullname ?? 'UNG THOUNG',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF003366),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            role ?? 'BUDDHIST HIGH SCHOOL',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    VoidCallback onTap, {
    String? title,
    Color color = Colors.black87,
  }) {
    return Center(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title ?? '', style: TextStyle(color: color, fontSize: 15)),
        onTap: onTap,
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }
}
