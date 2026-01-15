// lib/features/study/study_session_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/chapter_providers.dart';
import 'controllers/study_session_controller.dart';
import 'study_result_screen.dart';
import 'widgets/theory_card.dart';
import 'widgets/quiz_card.dart';
import 'widgets/session_progress_bar.dart';

class StudySessionScreen extends ConsumerStatefulWidget {
  /// 복습 전용 세션인지 여부
  final bool isReviewOnly;

  const StudySessionScreen({
    super.key,
    this.isReviewOnly = false,
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
      if (widget.isReviewOnly) {
        controller.startReviewSession();
      } else {
        controller.startSession();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(studySessionControllerProvider);

    return PopScope(
      canPop: state.status != StudySessionStatus.inProgress,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && state.status == StudySessionStatus.inProgress) {
          final shouldExit = await _showExitConfirmDialog();
          if (shouldExit == true && mounted) {
            ref.read(studySessionControllerProvider.notifier).cancelSession();
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(state.appBarTitle),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _handleClose(state),
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
        body: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(StudySessionState state) {
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
                  '오류가 발생했습니다',
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
                  child: const Text('다시 시도'),
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
            SessionProgressBar(progress: state.progress),
            Expanded(
              child: state.isTheory
                  ? _buildTheoryContent(state)
                  : _buildQuizContent(state),
            ),
          ],
        );
    }
  }

  Widget _buildTheoryContent(StudySessionState state) {
    final chapterId = state.currentItem?.chapterId;
    if (chapterId == null) return const SizedBox.shrink();

    final chapterAsync = ref.watch(chapterByIdProvider(chapterId));

    return chapterAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('오류: $error')),
      data: (chapter) {
        if (chapter == null) {
          return const Center(child: Text('챕터를 찾을 수 없습니다.'));
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

  Future<bool?> _showExitConfirmDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('학습 중단'),
        content: const Text('학습을 중단하시겠습니까?\n현재까지의 진행 상황은 저장됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('계속 학습'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('중단'),
          ),
        ],
      ),
    );
  }

  void _handleClose(StudySessionState state) async {
    if (state.status == StudySessionStatus.inProgress) {
      final shouldExit = await _showExitConfirmDialog();
      if (shouldExit == true) {
        ref.read(studySessionControllerProvider.notifier).cancelSession();
        if (mounted) Navigator.pop(context);
      }
    } else {
      Navigator.pop(context);
    }
  }
}
