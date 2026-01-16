// lib/features/progress/progress_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/collapsing_app_bar_scaffold.dart';
import '../../data/providers/study_providers.dart';
import 'widgets/era_progress_list.dart';
import 'widgets/level_distribution_card.dart';
import 'widgets/overall_stats_card.dart';
import 'widgets/streak_card.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CollapsingAppBarScaffold(
      title: '진행률',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 전체 진행률 헤더
          const _OverallProgressHeader(),

          // 2. 전체 통계 (7-2)
          const OverallStatsCard(),

          // 3. 스트릭 (7-3)
          const StreakCard(),
          const SizedBox(height: 16),

          // 4. 레벨 분포 (7-4)
          const LevelDistributionCard(),

          // 5. 시대별 진행률 (7-1)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '시대별 진행률',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const Card(
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: EraProgressList(),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _OverallProgressHeader extends ConsumerWidget {
  const _OverallProgressHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(overallProgressProvider);
    final summaryAsync = ref.watch(todaySummaryProvider);

    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                '전체 진행률',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              progressAsync.when(
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('$e'),
                data: (progress) => Text(
                  '${(progress * 100).toInt()}%',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: 8),
              summaryAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (summary) => Text(
                  '${summary.masteredCount} / ${summary.totalQuestions} 문제 완전 습득',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
