// lib/features/study/quiz_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/question_providers.dart';
import 'widgets/quiz_card.dart';
import 'widgets/session_progress_bar.dart';

class QuizScreen extends ConsumerWidget {
  final String questionId;
  final int currentIndex;
  final int totalItems;
  final VoidCallback? onCompleted;
  final void Function(bool isCorrect, String? selectedAnswer)? onAnswered;

  const QuizScreen({
    super.key,
    required this.questionId,
    this.currentIndex = 1,
    this.totalItems = 1,
    this.onCompleted,
    this.onAnswered,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionAsync = ref.watch(questionByIdProvider(questionId));
    final progress = totalItems > 0 ? currentIndex / totalItems : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('신규 학습'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '$currentIndex/$totalItems',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          SessionProgressBar(progress: progress),
          Expanded(
            child: questionAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('오류: $error')),
              data: (question) {
                if (question == null) {
                  return const Center(child: Text('문제를 찾을 수 없습니다.'));
                }
                return QuizCard(
                  question: question,
                  onAnswered: (isCorrect, selectedAnswer) {
                    onAnswered?.call(isCorrect, selectedAnswer);
                  },
                  onNext: () {
                    if (onCompleted != null) {
                      onCompleted!();
                    } else {
                      Navigator.pop(context);
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
