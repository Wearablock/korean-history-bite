// lib/features/wrong_answers/wrong_answers_screen.dart

import 'package:flutter/material.dart';
import '../../core/widgets/collapsing_app_bar_scaffold.dart';

class WrongAnswersScreen extends StatelessWidget {
  const WrongAnswersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CollapsingAppBarScaffold(
      title: '오답노트',
      body: Center(
        child: Text('오답노트 화면 (구현 예정)'),
      ),
    );
  }
}
