// lib/features/progress/progress_screen.dart

import 'package:flutter/material.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('진행률'),
      ),
      body: const Center(
        child: Text('진행률 화면 (구현 예정)'),
      ),
    );
  }
}
