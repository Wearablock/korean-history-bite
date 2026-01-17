// lib/features/study/quiz_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:korean_history_bite/l10n/app_localizations.dart';
import '../../core/widgets/traditional_sign_title.dart';
import '../../data/providers/question_providers.dart';
import 'widgets/quiz_card.dart';
import 'widgets/session_progress_bar.dart';

class QuizScreen extends ConsumerWidget {
  final String questionId;
  final int currentIndex;
  final int totalItems;
  final String? title;
  final VoidCallback? onCompleted;
  final void Function(bool isCorrect, String? selectedAnswer)? onAnswered;

  const QuizScreen({
    super.key,
    required this.questionId,
    this.currentIndex = 1,
    this.totalItems = 1,
    this.title,
    this.onCompleted,
    this.onAnswered,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final questionAsync = ref.watch(questionByIdProvider(questionId));
    final progress = totalItems > 0 ? currentIndex / totalItems : 0.0;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: TraditionalSignTitle(title: title ?? l10n.newLearning),
        ),
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
          const SizedBox(height: 8),
          SessionProgressBar(progress: progress),
          Expanded(
            child: questionAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text(l10n.error(error.toString()))),
              data: (question) {
                if (question == null) {
                  return Center(child: Text(l10n.questionNotFound));
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
