// lib/data/models/study_session.dart

/// 세션 단계
enum SessionPhase {
  wrongReview,    // 오답 복습 (퀴즈만)
  spacedReview,   // 망각곡선 복습 (퀴즈만)
  newLearning,    // 신규 학습 (이론 + 퀴즈)
  completed,      // 완료
}

/// 세션 내 현재 아이템 유형
enum SessionItemType {
  theory,   // 이론 카드
  quiz,     // 퀴즈
}

/// 세션 아이템 (이론 또는 퀴즈)
class SessionItem {
  final SessionItemType type;
  final SessionPhase phase;
  final String? chapterId;     // 이론일 경우
  final String? questionId;    // 퀴즈일 경우

  const SessionItem({
    required this.type,
    required this.phase,
    this.chapterId,
    this.questionId,
  });

  bool get isTheory => type == SessionItemType.theory;
  bool get isQuiz => type == SessionItemType.quiz;

  @override
  String toString() {
    if (isTheory) {
      return 'SessionItem(theory, chapter: $chapterId)';
    }
    return 'SessionItem(quiz, question: $questionId, phase: $phase)';
  }
}

/// 퀴즈 결과
class QuizResult {
  final String questionId;
  final bool isCorrect;
  final String? selectedAnswer;
  final DateTime answeredAt;

  const QuizResult({
    required this.questionId,
    required this.isCorrect,
    this.selectedAnswer,
    required this.answeredAt,
  });

  @override
  String toString() {
    return 'QuizResult(question: $questionId, correct: $isCorrect)';
  }
}

/// 학습 세션
class StudySession {
  final String id;
  final DateTime startedAt;
  DateTime? completedAt;

  // 문제 ID 목록 (각 단계별)
  final List<String> wrongReviewIds;
  final List<String> spacedReviewIds;
  final List<String> newQuestionIds;
  final List<String> newChapterIds;

  // 세션 아이템 목록 (순서대로 진행)
  final List<SessionItem> items;

  // 현재 상태
  int _currentIndex;
  SessionPhase _currentPhase;

  // 결과
  final List<QuizResult> results;

  /// 챕터별 신규 문제 매핑
  final Map<String, List<String>> newQuestionsByChapter;

  StudySession({
    required this.id,
    required this.startedAt,
    required this.wrongReviewIds,
    required this.spacedReviewIds,
    required this.newQuestionIds,
    required this.newChapterIds,
    required this.newQuestionsByChapter,
  })  : items = _buildItems(
          wrongReviewIds,
          spacedReviewIds,
          newChapterIds,
          newQuestionsByChapter,
        ),
        _currentIndex = 0,
        _currentPhase = _determineInitialPhase(
          wrongReviewIds,
          spacedReviewIds,
          newQuestionIds,
        ),
        results = [];

  /// 세션 아이템 목록 생성
  static List<SessionItem> _buildItems(
    List<String> wrongReviewIds,
    List<String> spacedReviewIds,
    List<String> newChapterIds,
    Map<String, List<String>> newQuestionsByChapter,
  ) {
    final items = <SessionItem>[];

    // 1. 오답 복습 (퀴즈만)
    for (final qId in wrongReviewIds) {
      items.add(SessionItem(
        type: SessionItemType.quiz,
        phase: SessionPhase.wrongReview,
        questionId: qId,
      ));
    }

    // 2. 망각곡선 복습 (퀴즈만)
    for (final qId in spacedReviewIds) {
      items.add(SessionItem(
        type: SessionItemType.quiz,
        phase: SessionPhase.spacedReview,
        questionId: qId,
      ));
    }

    // 3. 신규 학습 (챕터별: 이론 → 해당 챕터 퀴즈)
    for (final chapterId in newChapterIds) {
      // 챕터 이론 카드
      items.add(SessionItem(
        type: SessionItemType.theory,
        phase: SessionPhase.newLearning,
        chapterId: chapterId,
      ));

      // 해당 챕터의 퀴즈들
      final chapterQuestions = newQuestionsByChapter[chapterId] ?? [];
      for (final qId in chapterQuestions) {
        items.add(SessionItem(
          type: SessionItemType.quiz,
          phase: SessionPhase.newLearning,
          questionId: qId,
        ));
      }
    }

    return items;
  }

  /// 초기 단계 결정
  static SessionPhase _determineInitialPhase(
    List<String> wrongReviewIds,
    List<String> spacedReviewIds,
    List<String> newQuestionIds,
  ) {
    if (wrongReviewIds.isNotEmpty) return SessionPhase.wrongReview;
    if (spacedReviewIds.isNotEmpty) return SessionPhase.spacedReview;
    if (newQuestionIds.isNotEmpty) return SessionPhase.newLearning;
    return SessionPhase.completed;
  }

  // ============================================================
  // Getters
  // ============================================================

  /// 현재 인덱스
  int get currentIndex => _currentIndex;

  /// 현재 단계
  SessionPhase get currentPhase => _currentPhase;

  /// 현재 아이템
  SessionItem? get currentItem {
    if (_currentIndex >= items.length) return null;
    return items[_currentIndex];
  }

  /// 세션 완료 여부
  bool get isCompleted => _currentPhase == SessionPhase.completed;

  /// 세션이 비어있는지 (문제가 없는지)
  bool get isEmpty => items.isEmpty;

  /// 전체 아이템 수
  int get totalItems => items.length;

  /// 전체 퀴즈 수
  int get totalQuizzes => items.where((i) => i.isQuiz).length;

  /// 전체 이론 수
  int get totalTheories => items.where((i) => i.isTheory).length;

  /// 완료한 아이템 수
  int get completedItems => _currentIndex;

  /// 진행률 (0.0 ~ 1.0)
  double get progress {
    if (items.isEmpty) return 1.0;
    return _currentIndex / items.length;
  }

  /// 정답 수
  int get correctCount => results.where((r) => r.isCorrect).length;

  /// 오답 수
  int get wrongCount => results.where((r) => !r.isCorrect).length;

  /// 정답률
  double get accuracy {
    if (results.isEmpty) return 0.0;
    return correctCount / results.length;
  }

  /// 각 단계별 퀴즈 수
  int get wrongReviewQuizCount => wrongReviewIds.length;
  int get spacedReviewQuizCount => spacedReviewIds.length;
  int get newLearningQuizCount => newQuestionIds.length;

  /// 각 단계별 완료 수
  int get wrongReviewCompletedCount =>
      results.where((r) => wrongReviewIds.contains(r.questionId)).length;
  int get spacedReviewCompletedCount =>
      results.where((r) => spacedReviewIds.contains(r.questionId)).length;
  int get newLearningCompletedCount =>
      results.where((r) => newQuestionIds.contains(r.questionId)).length;

  /// 현재 단계의 진행 상황 문자열
  String get currentPhaseProgress {
    switch (_currentPhase) {
      case SessionPhase.wrongReview:
        return '오답 복습 ${wrongReviewCompletedCount + 1}/${wrongReviewQuizCount}';
      case SessionPhase.spacedReview:
        return '복습 ${spacedReviewCompletedCount + 1}/${spacedReviewQuizCount}';
      case SessionPhase.newLearning:
        return '신규 학습 ${newLearningCompletedCount + 1}/${newLearningQuizCount}';
      case SessionPhase.completed:
        return '완료';
    }
  }

  // ============================================================
  // Actions
  // ============================================================

  /// 다음 아이템으로 이동
  void moveNext() {
    if (_currentIndex < items.length) {
      _currentIndex++;
    }

    // 단계 업데이트
    if (_currentIndex >= items.length) {
      _currentPhase = SessionPhase.completed;
      completedAt = DateTime.now();
    } else {
      _currentPhase = items[_currentIndex].phase;
    }
  }

  /// 퀴즈 결과 기록
  void recordQuizResult({
    required String questionId,
    required bool isCorrect,
    String? selectedAnswer,
  }) {
    results.add(QuizResult(
      questionId: questionId,
      isCorrect: isCorrect,
      selectedAnswer: selectedAnswer,
      answeredAt: DateTime.now(),
    ));
  }

  /// 세션 완료 처리
  void complete() {
    _currentPhase = SessionPhase.completed;
    completedAt = DateTime.now();
  }

  /// 세션 소요 시간 (초)
  int get durationSeconds {
    final end = completedAt ?? DateTime.now();
    return end.difference(startedAt).inSeconds;
  }

  /// 세션 소요 시간 (포맷팅)
  String get durationFormatted {
    final seconds = durationSeconds;
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (minutes > 0) {
      return '$minutes분 $remainingSeconds초';
    }
    return '$remainingSeconds초';
  }

  // ============================================================
  // Serialization
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'wrong_review_ids': wrongReviewIds,
      'spaced_review_ids': spacedReviewIds,
      'new_question_ids': newQuestionIds,
      'new_chapter_ids': newChapterIds,
      'new_questions_by_chapter': newQuestionsByChapter,
      'current_index': _currentIndex,
      'results': results
          .map((r) => {
                'question_id': r.questionId,
                'is_correct': r.isCorrect,
                'selected_answer': r.selectedAnswer,
                'answered_at': r.answeredAt.toIso8601String(),
              })
          .toList(),
    };
  }

  @override
  String toString() {
    return 'StudySession(id: $id, phase: $_currentPhase, progress: ${(progress * 100).toStringAsFixed(1)}%)';
  }
}
