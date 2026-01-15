// lib/features/wrong_answers/wrong_answers_screen.dart

import 'package:flutter/material.dart';

class WrongAnswersScreen extends StatelessWidget {
  const WrongAnswersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('오답노트'),
      ),
      body: const Center(
        child: Text('오답노트 화면 (구현 예정)'),
      ),
    );
  }
}
