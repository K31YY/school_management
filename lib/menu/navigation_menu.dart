
import 'package:flutter/material.dart';
import 'package:ungthoung_app/app_colors.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Padding(
        padding: EdgeInsets.zero,
        child: ListView(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text('Yuom Danet'),
              accountEmail: Text('Yuom_da@net.bbu.edu.kh'),
              currentAccountPicture: CircleAvatar(
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/c.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              decoration: BoxDecoration(color: AppColors.bgColor),
            ),
          ],
        ),
      ),
    );
  }
}