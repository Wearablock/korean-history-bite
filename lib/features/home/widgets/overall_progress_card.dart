// lib/features/home/widgets/overall_progress_card.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/study_service.dart';

class OverallProgressCard extends StatelessWidget {
  final TodaySummary summary;

  const OverallProgressCard({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final progress = summary.overallProgress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '전체 진행률',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 진행률 바
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 12,
                          backgroundColor: AppColors.dividerLight,
                          valueColor: const AlwaysStoppedAnimation(
                            AppColors.progressMastered,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.progressMastered,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // 상세 정보
                Text(
                  '${summary.totalQuestions}문제 중 ${summary.masteredCount}문제 완전 습득',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
