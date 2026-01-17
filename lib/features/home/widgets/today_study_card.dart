// lib/features/home/widgets/today_study_card.dart

import 'package:flutter/material.dart';
import 'package:korean_history_bite/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Text(
              l10n.todayStudy,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.secondary,
              ),
            ),

            const SizedBox(height: 16),

            // 다음 챕터 정보 또는 완료 메시지
            if (summary.allChaptersCompleted)
              _buildAllCompletedMessage(context, l10n)
            else if (summary.hasNextChapter)
              _buildNextChapterInfo(context, l10n)
            else
              _buildTodayProgress(context, l10n),

            const SizedBox(height: 16),

            // 오늘의 학습 진행률 (일일 목표 대비)
            _buildTodayGoalProgress(context, l10n),

            const SizedBox(height: 16),

            // 스트릭
            if (summary.streak > 0) _buildStreakRow(context, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildAllCompletedMessage(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.emoji_events, color: AppColors.accent, size: 24),
            const SizedBox(width: 8),
            Text(
              l10n.allChaptersCompleted,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          l10n.reviewEncouragement,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildNextChapterInfo(BuildContext context, AppLocalizations l10n) {
    final chapterName = _formatChapterId(summary.nextChapterId!, context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.nextChapter,
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
          l10n.questionsCount(summary.nextChapterQuestionCount),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTodayProgress(BuildContext context, AppLocalizations l10n) {
    return Text(
      l10n.todayQuestionsCompleted(summary.questionsStudied),
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }

  Widget _buildTodayGoalProgress(BuildContext context, AppLocalizations l10n) {
    final progress = summary.todayProgress;
    final isGoalAchieved = summary.isTodayGoalAchieved;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.todayGoal,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Row(
              children: [
                if (isGoalAchieved)
                  const Icon(
                    Icons.check_circle,
                    size: 14,
                    color: AppColors.correct,
                  ),
                if (isGoalAchieved) const SizedBox(width: 4),
                Text(
                  l10n.chaptersProgress(summary.todayStudiedChapters, summary.dailyGoalChapters),
                  style: TextStyle(
                    fontSize: 12,
                    color: isGoalAchieved ? AppColors.correct : Colors.grey[600],
                    fontWeight: isGoalAchieved ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
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
            valueColor: AlwaysStoppedAnimation(
              isGoalAchieved ? AppColors.correct : AppColors.secondary,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${(progress * 100).toInt()}%',
            style: TextStyle(
              fontSize: 12,
              color: isGoalAchieved ? AppColors.correct : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStreakRow(BuildContext context, AppLocalizations l10n) {
    return Text(
      l10n.streakDays(summary.streak),
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.secondary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// 챕터 ID를 사람이 읽기 쉬운 형태로 변환
  /// ch_prehistoric_01 -> Prehistoric 01 / 선사시대 01
  String _formatChapterId(String chapterId, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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

    // 시대 ID를 로컬라이즈된 이름으로 변환
    final eraName = _getLocalizedEraName(eraId, l10n);

    if (number != null) {
      return '$eraName $number';
    }
    return eraName;
  }

  /// 시대 ID를 로컬라이즈된 이름으로 변환
  String _getLocalizedEraName(String eraId, AppLocalizations l10n) {
    switch (eraId) {
      case EraIds.prehistoric:
        return l10n.eraPrehistoric;
      case EraIds.gojoseon:
        return l10n.eraGojoseon;
      case EraIds.threeKingdoms:
        return l10n.eraThreeKingdoms;
      case EraIds.northSouthStates:
        return l10n.eraNorthSouthStates;
      case EraIds.goryeo:
        return l10n.eraGoryeo;
      case EraIds.joseonEarly:
        return l10n.eraJoseonEarly;
      case EraIds.joseonLate:
        return l10n.eraJoseonLate;
      case EraIds.modern:
        return l10n.eraModern;
      case EraIds.japaneseOccupation:
        return l10n.eraJapaneseOccupation;
      case EraIds.contemporary:
        return l10n.eraContemporary;
      default:
        return eraId;
    }
  }
}
