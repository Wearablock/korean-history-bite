// lib/features/home/widgets/overall_progress_card.dart

import 'package:flutter/material.dart';
import 'package:korean_history_bite/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final studiedProgress = summary.studiedProgress;
    final masteredProgress = summary.overallProgress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.overallProgress,
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
                // 이중 프로그레스 바 (1회 학습 + 완전 습득)
                _buildDualProgressBar(
                  studiedProgress: studiedProgress,
                  masteredProgress: masteredProgress,
                ),

                const SizedBox(height: 16),

                // 범례
                Row(
                  children: [
                    _buildLegendItem(
                      context,
                      color: AppColors.progressMastered,
                      label: l10n.mastered,
                      count: summary.masteredCount,
                    ),
                    const SizedBox(width: 16),
                    _buildLegendItem(
                      context,
                      color: AppColors.progressMastered.withValues(alpha: 0.3),
                      label: l10n.studiedOnce,
                      count: summary.studiedCount,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // 상세 정보
                Text(
                  l10n.totalQuestions(summary.totalQuestions),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 이중 프로그레스 바 (겹쳐서 표시)
  Widget _buildDualProgressBar({
    required double studiedProgress,
    required double masteredProgress,
  }) {
    return SizedBox(
      height: 16,
      child: Stack(
        children: [
          // 배경
          Container(
            decoration: BoxDecoration(
              color: AppColors.dividerLight,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          // 1회 이상 학습 (옅은색)
          FractionallySizedBox(
            widthFactor: studiedProgress,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.progressMastered.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          // 완전 습득 (짙은색)
          FractionallySizedBox(
            widthFactor: masteredProgress,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.progressMastered,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          // 퍼센트 표시
          Positioned(
            right: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: Text(
                '${(masteredProgress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: masteredProgress > 0.5
                      ? Colors.white
                      : AppColors.progressMastered,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 범례 아이템
  Widget _buildLegendItem(
    BuildContext context, {
    required Color color,
    required String label,
    required int count,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label $count',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
