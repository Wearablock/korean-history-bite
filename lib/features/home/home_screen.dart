// lib/features/home/home_screen.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:korean_history_bite/l10n/app_localizations.dart';
import '../../core/widgets/collapsing_app_bar_scaffold.dart';
import '../../data/providers/study_providers.dart';
import '../../services/study_service.dart';
import '../study/study_session_screen.dart';
import 'widgets/today_study_card.dart';
import 'widgets/study_cta_button.dart';
import 'widgets/overall_progress_card.dart';
import 'widgets/review_alert_card.dart';
import '../../debug/debug_panel.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final todaySummaryAsync = ref.watch(todaySummaryProvider);

    return CollapsingAppBarScaffold(
      title: l10n.appTitle,
      automaticallyImplyLeading: false,
      body: todaySummaryAsync.when(
        loading: () => const SizedBox(
          height: 200,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => SizedBox(
          height: 200,
          child: Center(child: Text(l10n.error(error.toString()))),
        ),
        data: (summary) => _buildContent(context, ref, summary),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, TodaySummary summary) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 복습 알림 (복습할 문제가 있을 때만 표시)
          if (summary.reviewDueCount > 0) ...[
            ReviewAlertCard(
              count: summary.reviewDueCount,
              onTap: () => _startReviewSession(context, ref),
            ),
            const SizedBox(height: 16),
          ],

          // 오늘의 학습 카드
          TodayStudyCard(summary: summary),

          const SizedBox(height: 24),

          // 학습 시작 버튼
          StudyCtaButton(
            summary: summary,
            onPressed: () => _startStudySession(context, ref),
          ),

          const SizedBox(height: 24),

          const Divider(),

          const SizedBox(height: 16),

          // 전체 진행률
          OverallProgressCard(summary: summary),

          // 디버그 패널 (개발 모드에서만 표시)
          if (kDebugMode) ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            DebugPanel(
              onRefresh: () => ref.invalidate(appStatsProvider),
            ),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _startStudySession(BuildContext context, WidgetRef ref) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const StudySessionScreen(),
      ),
    );
  }

  Future<void> _startReviewSession(BuildContext context, WidgetRef ref) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const StudySessionScreen(isReviewOnly: true),
      ),
    );
  }
}
