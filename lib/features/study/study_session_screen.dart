// lib/features/study/study_session_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:korean_history_bite/l10n/app_localizations.dart';
import '../../core/widgets/traditional_sign_title.dart';
import '../../data/models/study_session.dart';
import '../../data/providers/chapter_providers.dart';
import 'controllers/study_session_controller.dart';
import 'study_result_screen.dart';
import 'widgets/theory_card.dart';
import 'widgets/quiz_card.dart';
import 'widgets/session_progress_bar.dart';

class StudySessionScreen extends ConsumerStatefulWidget {
  /// 복습 전용 세션인지 여부
  final bool isReviewOnly;

  /// 시대별 학습 시 시대 ID
  final String? eraId;

  const StudySessionScreen({
    super.key,
    this.isReviewOnly = false,
    this.eraId,
  });

  @override
  ConsumerState<StudySessionScreen> createState() => _StudySessionScreenState();
}

class _StudySessionScreenState extends ConsumerState<StudySessionScreen> {
  bool _navigatedToResult = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(studySessionControllerProvider.notifier);
      if (widget.eraId != null) {
        controller.startEraSession(widget.eraId!);
      } else if (widget.isReviewOnly) {
        controller.startReviewSession();
      } else {
        controller.startSession();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(studySessionControllerProvider);

    return PopScope(
      canPop: state.status != StudySessionStatus.inProgress,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && state.status == StudySessionStatus.inProgress) {
          final shouldExit = await _showExitConfirmDialog(l10n);
          if (shouldExit == true && mounted) {
            ref.read(studySessionControllerProvider.notifier).cancelSession();
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 72,
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: TraditionalSignTitle(title: _getLocalizedPhaseTitle(state.currentPhase, l10n)),
          ),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _handleClose(state, l10n),
          ),
          actions: [
            if (state.status == StudySessionStatus.inProgress)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Text(
                    '${state.currentIndex}/${state.totalItems}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: _buildBody(state, l10n),
      ),
    );
  }

  Widget _buildBody(StudySessionState state, AppLocalizations l10n) {
    switch (state.status) {
      case StudySessionStatus.initial:
      case StudySessionStatus.loading:
        return const Center(child: CircularProgressIndicator());

      case StudySessionStatus.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.errorOccurred,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  state.errorMessage ?? '',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    ref
                        .read(studySessionControllerProvider.notifier)
                        .startSession();
                  },
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        );

      case StudySessionStatus.completed:
        if (!_navigatedToResult && state.session != null) {
          _navigatedToResult = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => StudyResultScreen(
                  session: state.session!,
                  isReviewSession: widget.isReviewOnly,
                ),
              ),
            );
          });
        }
        return const Center(child: CircularProgressIndicator());

      case StudySessionStatus.inProgress:
        return Column(
          children: [
            const SizedBox(height: 8),
            SessionProgressBar(progress: state.progress),
            Expanded(
              child: state.isTheory
                  ? _buildTheoryContent(state, l10n)
                  : _buildQuizContent(state),
            ),
          ],
        );
    }
  }

  Widget _buildTheoryContent(StudySessionState state, AppLocalizations l10n) {
    final chapterId = state.currentItem?.chapterId;
    if (chapterId == null) return const SizedBox.shrink();

    final chapterAsync = ref.watch(chapterByIdProvider(chapterId));

    return chapterAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(l10n.error(error.toString()))),
      data: (chapter) {
        if (chapter == null) {
          return Center(child: Text(l10n.chapterNotFound));
        }
        return TheoryCard(
          chapter: chapter,
          onCompleted: () {
            ref.read(studySessionControllerProvider.notifier).completeTheory();
          },
        );
      },
    );
  }

  Widget _buildQuizContent(StudySessionState state) {
    final question = state.currentQuestion;
    if (question == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return QuizCard(
      key: ValueKey(question.id),
      question: question,
      onAnswered: (isCorrect, selectedAnswer) {
        final controller = ref.read(studySessionControllerProvider.notifier);
        if (isCorrect) {
          controller.answerCorrect();
        } else {
          controller.answerWrong(selectedAnswer ?? '');
        }
      },
      onNext: () {
        ref.read(studySessionControllerProvider.notifier).moveNext();
      },
    );
  }

  Future<bool?> _showExitConfirmDialog(AppLocalizations l10n) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.stopStudy),
        content: Text(l10n.stopStudyConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.continueStudyButton),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.stop),
          ),
        ],
      ),
    );
  }

  void _handleClose(StudySessionState state, AppLocalizations l10n) async {
    if (state.status == StudySessionStatus.inProgress) {
      final shouldExit = await _showExitConfirmDialog(l10n);
      if (shouldExit == true) {
        ref.read(studySessionControllerProvider.notifier).cancelSession();
        if (mounted) Navigator.pop(context);
      }
    } else {
      Navigator.pop(context);
    }
  }

  /// 세션 단계에 따른 로컬라이즈된 제목 반환
  String _getLocalizedPhaseTitle(SessionPhase phase, AppLocalizations l10n) {
    switch (phase) {
      case SessionPhase.wrongReview:
        return l10n.wrongReview;
      case SessionPhase.spacedReview:
        return l10n.review;
      case SessionPhase.newLearning:
        return l10n.newLearning;
      case SessionPhase.completed:
        return l10n.studyComplete;
    }
  }
}
