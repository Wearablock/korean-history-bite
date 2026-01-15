// lib/features/study/study_result_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/study_session.dart';
import '../../data/providers/study_providers.dart';
import 'controllers/study_session_controller.dart';
import 'study_session_screen.dart';

class StudyResultScreen extends ConsumerStatefulWidget {
  final StudySession session;
  final bool isReviewSession;

  const StudyResultScreen({
    super.key,
    required this.session,
    this.isReviewSession = false,
  });

  @override
  ConsumerState<StudyResultScreen> createState() => _StudyResultScreenState();
}

class _StudyResultScreenState extends ConsumerState<StudyResultScreen> {
  @override
  void initState() {
    super.initState();
    // 세션 완료 후 최신 데이터를 가져오기 위해 provider 새로고침
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(todaySummaryProvider);
    });
  }

  // session getter for convenience
  StudySession get session => widget.session;
  bool get isReviewSession => widget.isReviewSession;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('학습 완료'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 완료 아이콘
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.correctLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                size: 48,
                color: AppColors.correct,
              ),
            ),

            const SizedBox(height: 24),

            // 축하 메시지
            Text(
              _getCompletionMessage(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            Text(
              '수고하셨습니다',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 32),

            // 결과 카드
            _buildResultCard(context),

            const SizedBox(height: 24),

            // 단계별 결과
            if (_hasPhaseResults()) _buildPhaseResults(context),

            const SizedBox(height: 32),

            // 버튼 영역
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final summaryAsync = ref.watch(todaySummaryProvider);

    return summaryAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => isReviewSession
          ? _buildHomeButton(context)
          : _buildDefaultButtons(context),
      data: (summary) {
        final remainingReview = summary.reviewDueCount;

        // 복습 세션인 경우
        if (isReviewSession) {
          // 남은 복습 문제가 있으면
          if (remainingReview > 0) {
            return Column(
              children: [
                // 이어서 복습하기 버튼
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      ref.invalidate(studySessionControllerProvider);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const StudySessionScreen(isReviewOnly: true),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      '이어서 복습하기 ($remainingReview개 남음)',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 홈으로 버튼
                _buildHomeButton(context),
              ],
            );
          }

          // 복습 세션이고 남은 복습이 없으면 홈으로만
          return _buildHomeButton(context);
        }

        // 일반 학습 세션: 추가 학습하기 + 홈으로
        return _buildDefaultButtons(context);
      },
    );
  }

  Widget _buildDefaultButtons(BuildContext context) {
    return Column(
      children: [
        // 추가 학습하기 버튼
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              ref.invalidate(studySessionControllerProvider);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const StudySessionScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              '추가 학습하기',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // 홈으로 버튼
        _buildHomeButton(context),
      ],
    );
  }

  Widget _buildHomeButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: () {
          Navigator.popUntil(context, (route) => route.isFirst);
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          '홈으로',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  String _getCompletionMessage() {
    if (session.totalQuizzes == 0) {
      return '오늘의 학습이 완료되었어요!';
    }
    final accuracy = session.accuracy;
    if (accuracy >= 0.9) {
      return '훌륭해요!\n오늘의 학습을 완료했어요!';
    } else if (accuracy >= 0.7) {
      return '잘했어요!\n오늘의 학습을 완료했어요!';
    } else {
      return '오늘의 학습을 완료했어요!';
    }
  }

  Widget _buildResultCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 정답률
            if (session.totalQuizzes > 0) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${(session.accuracy * 100).toInt()}',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const Text(
                    '%',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const Text(
                '정답률',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),
            ],

            // 상세 결과
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (session.totalQuizzes > 0) ...[
                  _buildStatItem(
                    icon: Icons.check_circle,
                    color: AppColors.correct,
                    value: '${session.correctCount}',
                    label: '정답',
                  ),
                  _buildStatItem(
                    icon: Icons.cancel,
                    color: AppColors.wrong,
                    value: '${session.wrongCount}',
                    label: '오답',
                  ),
                ],
                _buildStatItem(
                  icon: Icons.timer,
                  color: AppColors.secondary,
                  value: session.durationFormatted,
                  label: '소요 시간',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  bool _hasPhaseResults() {
    return session.wrongReviewIds.isNotEmpty ||
        session.spacedReviewIds.isNotEmpty ||
        session.newQuestionIds.isNotEmpty;
  }

  Widget _buildPhaseResults(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '단계별 결과',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            if (session.wrongReviewIds.isNotEmpty)
              _buildPhaseRow(
                label: '오답 복습',
                count: session.wrongReviewQuizCount,
                completed: session.wrongReviewCompletedCount,
              ),
            if (session.spacedReviewIds.isNotEmpty)
              _buildPhaseRow(
                label: '망각곡선 복습',
                count: session.spacedReviewQuizCount,
                completed: session.spacedReviewCompletedCount,
              ),
            if (session.newQuestionIds.isNotEmpty)
              _buildPhaseRow(
                label: '신규 학습',
                count: session.newLearningQuizCount,
                completed: session.newLearningCompletedCount,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseRow({
    required String label,
    required int count,
    required int completed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            '$completed/$count',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: completed == count ? AppColors.correct : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
