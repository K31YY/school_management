import 'package:flutter/material.dart';

class TeacherList extends StatelessWidget {
  const TeacherList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teacher List')),
      body: ListView(),
    );
  }
}
