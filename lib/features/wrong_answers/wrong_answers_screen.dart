// lib/features/wrong_answers/wrong_answers_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:korean_history_bite/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/collapsing_app_bar_scaffold.dart';
import '../../data/database/app_database.dart';
import '../../data/models/question.dart';
import '../../data/providers/database_providers.dart';
import '../../data/providers/question_providers.dart';
import '../../data/repositories/question_repository.dart';

/// 오답과 문제 정보를 결합한 모델
class WrongAnswerWithQuestion {
  final WrongAnswer wrongAnswer;
  final Question question;

  const WrongAnswerWithQuestion({
    required this.wrongAnswer,
    required this.question,
  });
}

/// 오답 목록 (최신순, 미해결만) + 문제 정보 결합 Provider
/// locale 파라미터를 받아 해당 언어로 문제 로드
final wrongAnswersWithQuestionsProvider = FutureProvider.autoDispose
    .family<List<WrongAnswerWithQuestion>, String>((ref, locale) async {
  final dao = ref.watch(wrongAnswersDaoProvider);
  final questionRepo = ref.watch(questionRepositoryProvider);

  // 미해결 오답만 조회 (correctedAt이 null인 것들, 최신 틀린 순)
  final allWrongAnswers = await dao.getAllWrongAnswers();
  final wrongAnswers = allWrongAnswers
      .where((w) => w.correctedAt == null)
      .toList()
    ..sort((a, b) => b.wrongAt.compareTo(a.wrongAt));

  if (wrongAnswers.isEmpty) return [];

  // 문제 ID 목록 추출
  final questionIds = wrongAnswers.map((w) => w.questionId).toList();

  // 문제 정보 조회 (현재 로케일)
  final questions = await questionRepo.getQuestionsByIds(questionIds, locale);

  // 결합
  final result = <WrongAnswerWithQuestion>[];
  for (final wrongAnswer in wrongAnswers) {
    final question = questions.firstWhere(
      (q) => q.id == wrongAnswer.questionId,
      orElse: () => Question(
        id: wrongAnswer.questionId,
        chapterId: wrongAnswer.chapterId,
        order: 0,
        difficulty: 1,
        type: QuestionType.text,
        question: wrongAnswer.questionId,
        correct: '',
        wrong: [],
        explanation: '',
      ),
    );
    result.add(WrongAnswerWithQuestion(
      wrongAnswer: wrongAnswer,
      question: question,
    ));
  }

  return result;
});

class WrongAnswersScreen extends ConsumerWidget {
  const WrongAnswersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final wrongAnswersAsync = ref.watch(wrongAnswersWithQuestionsProvider(locale));

    return CollapsingAppBarScaffold(
      title: l10n.wrongAnswers,
      body: wrongAnswersAsync.when(
        data: (wrongAnswers) {
          if (wrongAnswers.isEmpty) {
            return _buildEmptyState(context, l10n);
          }
          return _buildWrongAnswersList(context, l10n, wrongAnswers);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text(l10n.error(error.toString())),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.celebration_outlined,
              size: 80,
              color: isDark ? AppColors.accentLight : AppColors.accent,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noWrongAnswers,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.accentLight : AppColors.accent,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.noWrongAnswersDesc,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWrongAnswersList(
    BuildContext context,
    AppLocalizations l10n,
    List<WrongAnswerWithQuestion> wrongAnswers,
  ) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: wrongAnswers.length,
      itemBuilder: (context, index) {
        final item = wrongAnswers[index];
        return _WrongAnswerCard(
          wrongAnswer: item.wrongAnswer,
          question: item.question,
          l10n: l10n,
        );
      },
    );
  }
}

class _WrongAnswerCard extends StatefulWidget {
  final WrongAnswer wrongAnswer;
  final Question question;
  final AppLocalizations l10n;

  const _WrongAnswerCard({
    required this.wrongAnswer,
    required this.question,
    required this.l10n,
  });

  @override
  State<_WrongAnswerCard> createState() => _WrongAnswerCardState();
}

class _WrongAnswerCardState extends State<_WrongAnswerCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final eraName = _getEraName(widget.wrongAnswer.eraId, widget.l10n);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 (문제)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 상단: 시대 태그 + 틀린 횟수
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          eraName,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.wrong.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.l10n.wrongCount(widget.wrongAnswer.wrongCount),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.wrong,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 문제
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.question.question,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: AppColors.textSecondaryLight,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 확장된 내용 (정답, 내 답, 해설)
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: _buildExpandedContent(context, isDark),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedContent(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.backgroundDark
            : AppColors.signBackground,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          ),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 정답
          _buildAnswerRow(
            context,
            label: widget.l10n.correctAnswer,
            answer: widget.question.correct,
            color: AppColors.correct,
            icon: Icons.check_circle,
          ),

          const SizedBox(height: 12),

          // 내가 고른 답
          if (widget.wrongAnswer.lastWrongAnswer != null)
            _buildAnswerRow(
              context,
              label: widget.l10n.yourAnswer,
              answer: widget.wrongAnswer.lastWrongAnswer!,
              color: AppColors.wrong,
              icon: Icons.cancel,
            ),

          if (widget.wrongAnswer.lastWrongAnswer != null)
            const SizedBox(height: 16),

          // 해설
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 16,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.l10n.explanation,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.question.explanation,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerRow(
    BuildContext context, {
    required String label,
    required String answer,
    required Color color,
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                answer,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getEraName(String eraId, AppLocalizations l10n) {
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
