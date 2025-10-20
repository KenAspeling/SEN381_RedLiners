import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Color.fromARGB(225, 172, 30, 84),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Help & Support Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}