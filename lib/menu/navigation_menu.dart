import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ungthoung_app/providers/auth_provider.dart';
import 'package:ungthoung_app/menu/add_student.dart';
import 'package:ungthoung_app/menu/add_teacher.dart';
import 'package:ungthoung_app/menu/assign_schedule.dart';
import 'package:ungthoung_app/menu/change_password.dart';
import 'package:ungthoung_app/menu/report_area.dart';
import 'package:ungthoung_app/menu/views_student.dart';
import 'package:ungthoung_app/menu/views_teacher.dart';

class NavigationMenu extends ConsumerWidget {
  const NavigationMenu({super.key});

  /// Shows logout confirmation dialog
  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
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
            onPressed: () {
              Navigator.of(dialogContext).pop(true);
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (isLogout == true) {
      await ref.read(authProvider.notifier).logout();
      // Navigation happens automatically via main.dart
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildDrawerHeader(auth),
            const SizedBox(height: 8),
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
            const SizedBox(height: 8),
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
             _buildMenuItem(
              context,
              Icons.bar_chart_outlined,
              () => _navigateTo(context, const ReportingScreen()),
              title: 'Report Area',
            ),
            const SizedBox(height: 8),
            _buildSectionHeader('Setting'),
            _buildMenuItem(
              context,
              Icons.lock_outline,
              () => _navigateTo(context, const ChangePasswordScreen()),
              title: 'Change Password',
            ),
            const SizedBox(height: 16),
            _buildMenuItem(
              context,
              Icons.logout,
              () => _confirmLogout(context, ref),
              title: 'Logout',
              color: Colors.red.shade700,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 13,
              color: Colors.grey.shade600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Divider(
              color: Colors.grey.shade300, 
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(AuthState auth) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4A5BF6),
            Color(0xFF6B7BFF),
          ],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
            ),
            child: const CircleAvatar(
              radius: 42,
              backgroundColor: Colors.white,
              child: Icon(Icons.school, size: 44, color: Color(0xFF4A5BF6)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            auth.fullName ?? 'Guest User',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            auth.role ?? 'BUDDHIST HIGH SCHOOL',
            style: TextStyle(
              fontSize: 12, 
              color: Colors.white.withOpacity(0.85),
              letterSpacing: 0.5,
            ),
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
    Color color = const Color(0xFF374151),
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color == Colors.red.shade700 
                        ? Colors.red.shade50
                        : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon, 
                    color: color == Colors.red.shade700 
                        ? Colors.red.shade700 
                        : const Color(0xFF4A5BF6),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title ?? '',
                    style: TextStyle(
                      color: color, 
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }
}
