import 'package:flutter/material.dart';

class TopNews extends StatelessWidget {
  const TopNews({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Top News'),),
      body: ListView(),
    );
  }
}