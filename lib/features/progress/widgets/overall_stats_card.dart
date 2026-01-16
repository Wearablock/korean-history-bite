// lib/features/progress/widgets/overall_stats_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/providers/study_providers.dart';

class OverallStatsCard extends ConsumerWidget {
  const OverallStatsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(overallSummaryProvider);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '전체 학습 통계',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            summaryAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => Text('오류: $e'),
              data: (summary) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                    icon: Icons.quiz_outlined,
                    label: '총 학습',
                    value: '${summary['totalQuestions']}문제',
                    color: AppColors.info,
                  ),
                  _StatItem(
                    icon: Icons.check_circle_outline,
                    label: '정답률',
                    value:
                        '${((summary['averageAccuracy'] as double) * 100).toInt()}%',
                    color: AppColors.correct,
                  ),
                  _StatItem(
                    icon: Icons.calendar_today_outlined,
                    label: '학습일',
                    value: '${summary['totalDays']}일',
                    color: AppColors.secondary,
                  ),
                  _StatItem(
                    icon: Icons.timer_outlined,
                    label: '학습시간',
                    value: Formatters.formatDuration(summary['totalStudyTime'] as int),
                    color: AppColors.accent,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.grey600,
              ),
        ),
      ],
    );
  }
}
