import 'package:flutter/material.dart';

class ScanPage extends StatelessWidget {
  const ScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Page'),
      ),
      body: const Center(
        child: Text('Mockup หน้า Scan'),
      ),
    );
  }
}
