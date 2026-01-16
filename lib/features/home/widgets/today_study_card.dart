// lib/features/home/widgets/today_study_card.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/question_repository.dart';
import '../../../services/study_service.dart';

class TodayStudyCard extends StatelessWidget {
  final TodaySummary summary;

  const TodayStudyCard({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Text(
              '오늘의 학습',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.secondary,
              ),
            ),

            const SizedBox(height: 16),

            // 다음 챕터 정보 또는 완료 메시지
            if (summary.allChaptersCompleted)
              _buildAllCompletedMessage(context)
            else if (summary.hasNextChapter)
              _buildNextChapterInfo(context)
            else
              _buildTodayProgress(context),

            const SizedBox(height: 16),

            // 전체 진행률
            _buildOverallProgress(context),

            const SizedBox(height: 16),

            // 스트릭
            if (summary.streak > 0) _buildStreakRow(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAllCompletedMessage(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.emoji_events, color: AppColors.accent, size: 24),
            const SizedBox(width: 8),
            Text(
              '모든 챕터 학습 완료!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '복습을 통해 실력을 더욱 쌓아보세요.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildNextChapterInfo(BuildContext context) {
    final chapterName = _formatChapterId(summary.nextChapterId!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '다음 챕터',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          chapterName,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${summary.nextChapterQuestionCount}문제',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTodayProgress(BuildContext context) {
    return Text(
      '오늘 ${summary.questionsStudied}문제 학습 완료',
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }

  Widget _buildOverallProgress(BuildContext context) {
    final progress = summary.overallProgress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '전체 진행률',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              '${summary.masteredCount}/${summary.totalQuestions} 완전 습득',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: AppColors.dividerLight,
            valueColor: AlwaysStoppedAnimation(_getProgressColor(progress)),
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${(progress * 100).toInt()}%',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStreakRow(BuildContext context) {
    return Text(
      '연속 ${summary.streak}일째 학습 중!',
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.secondary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 1.0) return AppColors.correct;
    if (progress >= 0.5) return AppColors.accent;
    if (progress > 0) return AppColors.secondary;
    return AppColors.textSecondaryLight;
  }

  /// 챕터 ID를 사람이 읽기 쉬운 형태로 변환
  /// ch_prehistoric_01 -> 선사시대 01
  String _formatChapterId(String chapterId) {
    // ch_ 접두사 제거
    final withoutPrefix = chapterId.replaceFirst('ch_', '');

    // 시대 ID와 번호 분리
    final parts = withoutPrefix.split('_');
    if (parts.isEmpty) return chapterId;

    // 마지막이 숫자인 경우 번호로 처리
    final lastPart = parts.last;
    final isNumber = int.tryParse(lastPart) != null;

    String eraId;
    String? number;

    if (isNumber && parts.length > 1) {
      eraId = parts.sublist(0, parts.length - 1).join('_');
      number = lastPart;
    } else {
      eraId = withoutPrefix;
    }

    // 시대 ID를 한글로 변환 (중앙 집중 매핑 사용)
    final eraName = EraIds.toKorean(eraId);

    if (number != null) {
      return '$eraName $number';
    }
    return eraName;
  }
}
