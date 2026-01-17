// lib/features/progress/widgets/level_distribution_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:korean_history_bite/l10n/app_localizations.dart';
import '../../../core/config/constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers/study_providers.dart';

class LevelDistributionCard extends ConsumerWidget {
  const LevelDistributionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final distributionAsync = ref.watch(levelDistributionProvider);
    final totalQuestionsAsync = ref.watch(availableQuestionCountProvider);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bar_chart, color: AppColors.accent),
                const SizedBox(width: 8),
                Text(
                  l10n.levelDistribution,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            distributionAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => Text(l10n.error(e.toString())),
              data: (distribution) => totalQuestionsAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (e, _) => Text(l10n.error(e.toString())),
                data: (totalQuestions) {
                  // 학습된 문제 총계
                  final studiedTotal = distribution.values
                      .fold<int>(0, (sum, count) => sum + count);
                  final unstudied = totalQuestions - studiedTotal;

                  // 최대값 계산 (바 너비 비율용)
                  final allCounts = [...distribution.values, unstudied];
                  final maxCount = allCounts.isEmpty
                      ? 1
                      : allCounts.reduce((a, b) => a > b ? a : b);

                  return Column(
                    children: [
                      // 레벨 5 ~ 0 역순으로 표시
                      for (int level = StudyConstants.masteryLevel;
                          level >= 0;
                          level--)
                        _LevelBar(
                          level: level,
                          count: distribution[level] ?? 0,
                          maxCount: maxCount == 0 ? 1 : maxCount,
                          color: _getLevelColor(level),
                          label: _getLevelLabel(level, l10n),
                        ),

                      const Divider(height: 24),

                      // 미학습 문제
                      _LevelBar(
                        level: -1,
                        count: unstudied,
                        maxCount: maxCount == 0 ? 1 : maxCount,
                        color: Colors.grey.shade400,
                        label: l10n.unstudied,
                      ),

                      const SizedBox(height: 16),

                      // 범례
                      _buildLegend(context, studiedTotal, totalQuestions, l10n),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context, int studied, int total, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _LegendItem(
            color: AppColors.progressMastered,
            label: l10n.fullyMastered,
          ),
          _LegendItem(
            color: AppColors.progressLearning,
            label: l10n.learning,
          ),
          _LegendItem(
            color: AppColors.wrong,
            label: l10n.wrong,
          ),
          Text(
            '$studied / $total',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Color _getLevelColor(int level) {
    switch (level) {
      case 5:
        return AppColors.progressMastered;
      case 4:
        return AppColors.correct.withValues(alpha: 0.8);
      case 3:
        return AppColors.accent;
      case 2:
        return AppColors.progressLearning;
      case 1:
        return AppColors.secondary.withValues(alpha: 0.7);
      case 0:
        return AppColors.wrong;
      default:
        return Colors.grey;
    }
  }

  String _getLevelLabel(int level, AppLocalizations l10n) {
    switch (level) {
      case 5:
        return l10n.fullyMastered;
      case 4:
        return l10n.reviewLevel4;
      case 3:
        return l10n.reviewLevel3;
      case 2:
        return l10n.reviewLevel2;
      case 1:
        return l10n.reviewLevel1;
      case 0:
        return l10n.wrongOrReset;
      default:
        return l10n.unknown;
    }
  }
}

class _LevelBar extends StatelessWidget {
  final int level;
  final int count;
  final int maxCount;
  final Color color;
  final String label;

  const _LevelBar({
    required this.level,
    required this.count,
    required this.maxCount,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = maxCount > 0 ? count / maxCount : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // 레벨 라벨
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),

          // 바
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: ratio.clamp(0.0, 1.0),
                  child: Container(
                    height: 20,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 개수
          SizedBox(
            width: 50,
            child: Text(
              '$count',
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
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
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
