// lib/features/study/widgets/explanation_card.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ExplanationCard extends StatelessWidget {
  final String explanation;
  final bool isCorrect;

  const ExplanationCard({
    super.key,
    required this.explanation,
    required this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect ? AppColors.correctLight : AppColors.wrongLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.lightbulb : Icons.info,
                size: 20,
                color: isCorrect ? AppColors.correct : AppColors.wrong,
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect ? '정답입니다!' : '오답입니다',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isCorrect ? AppColors.correct : AppColors.wrong,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            explanation,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
