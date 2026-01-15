// lib/features/home/widgets/study_cta_button.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/study_service.dart';

class StudyCtaButton extends StatelessWidget {
  final TodaySummary summary;
  final VoidCallback onPressed;

  const StudyCtaButton({
    super.key,
    required this.summary,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final buttonText = _getButtonText();
    final isAllCompleted = summary.allChaptersCompleted;

    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isAllCompleted ? AppColors.correct : AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          buttonText,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _getButtonText() {
    if (summary.allChaptersCompleted) {
      return '복습하기';
    }
    if (summary.questionsStudied > 0) {
      return '학습 이어하기';
    }
    return '학습 시작하기';
  }
}
