// lib/features/study/controllers/study_session_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../data/models/study_session.dart';
import '../../../data/models/question.dart';
import '../../../data/providers/premium_provider.dart';
import '../../../data/providers/study_providers.dart';
import '../../../data/providers/question_providers.dart';
import '../../../data/providers/chapter_providers.dart';
import '../../../data/providers/database_providers.dart';
import '../../../services/ad_service.dart';
import '../../wrong_answers/wrong_answers_screen.dart';

/// 세션 상태
enum StudySessionStatus {
  initial,
  loading,
  inProgress,
  completed,
  error,
}

/// 세션 상태 클래스
class StudySessionState {
  final StudySessionStatus status;
  final StudySession? session;
  final Question? currentQuestion;
  final String? errorMessage;

  const StudySessionState({
    this.status = StudySessionStatus.initial,
    this.session,
    this.currentQuestion,
    this.errorMessage,
  });

  StudySessionState copyWith({
    StudySessionStatus? status,
    StudySession? session,
    Question? currentQuestion,
    String? errorMessage,
  }) {
    return StudySessionState(
      status: status ?? this.status,
      session: session ?? this.session,
      currentQuestion: currentQuestion,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// 현재 아이템
  SessionItem? get currentItem => session?.currentItem;

  /// 이론 카드인지
  bool get isTheory => currentItem?.isTheory ?? false;

  /// 퀴즈인지
  bool get isQuiz => currentItem?.isQuiz ?? false;

  /// 진행률
  double get progress => session?.progress ?? 0.0;

  /// 현재 인덱스 (1-based)
  int get currentIndex => (session?.currentIndex ?? 0) + 1;

  /// 전체 아이템 수
  int get totalItems => session?.totalItems ?? 0;

  /// 현재 단계
  SessionPhase get currentPhase =>
      session?.currentPhase ?? SessionPhase.completed;
}

/// 세션 컨트롤러
class StudySessionController extends StateNotifier<StudySessionState> {
  final Ref _ref;

  StudySessionController(this._ref) : super(const StudySessionState());

  /// 세션 시작 (사용자 설정 챕터 수)
  Future<void> startSession() async {
    state = state.copyWith(status: StudySessionStatus.loading);

    try {
      final studyService = _ref.read(studyServiceProvider);
      final userSettingsDao = _ref.read(userSettingsDaoProvider);

      // 사용자 설정 챕터 수 조회
      final chapterCount = await userSettingsDao.getDailyGoal();

      // 설정된 챕터 수로 세션 생성
      final session = await studyService.createDailySession(
        chapterCount: chapterCount,
      );

      if (session.isEmpty) {
        state = state.copyWith(
          status: StudySessionStatus.completed,
          session: session,
        );
        return;
      }

      state = state.copyWith(
        status: StudySessionStatus.inProgress,
        session: session,
      );

      // 첫 번째 아이템이 퀴즈면 문제 로드
      await _loadCurrentQuestion();
    } catch (e) {
      state = state.copyWith(
        status: StudySessionStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// 복습 세션 시작
  Future<void> startReviewSession() async {
    state = state.copyWith(status: StudySessionStatus.loading);

    try {
      final studyService = _ref.read(studyServiceProvider);
      final session = await studyService.createReviewSession();

      if (session.isEmpty) {
        state = state.copyWith(
          status: StudySessionStatus.completed,
          session: session,
        );
        return;
      }

      state = state.copyWith(
        status: StudySessionStatus.inProgress,
        session: session,
      );

      // 첫 번째 아이템이 퀴즈면 문제 로드
      await _loadCurrentQuestion();
    } catch (e) {
      state = state.copyWith(
        status: StudySessionStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// 현재 퀴즈 문제 로드
  Future<void> _loadCurrentQuestion() async {
    final item = state.currentItem;
    if (item == null || !item.isQuiz) {
      state = state.copyWith(currentQuestion: null);
      return;
    }

    final questionRepository = _ref.read(questionRepositoryProvider);
    final locale = _ref.read(currentLocaleProvider);
    final question = await questionRepository.getQuestionById(
      item.questionId!,
      locale,
    );

    state = state.copyWith(currentQuestion: question);
  }

  /// 이론 학습 완료
  Future<void> completeTheory() async {
    final session = state.session;
    if (session == null) return;

    // 이론 완료 후 퀴즈로 넘어가기 전 전면 광고 표시 (프리미엄 사용자 제외)
    final isPremium = _ref.read(isPremiumProvider);
    if (!isPremium) {
      await AdService().showInterstitialAd();
    }

    session.moveNext();

    if (session.isCompleted) {
      await _completeSession();
    } else {
      // 다음 아이템이 퀴즈면 문제 로드
      await _loadCurrentQuestion();
      // _loadCurrentQuestion이 이미 state를 업데이트함
      // session 변경을 반영하기 위해 상태 재설정
      state = StudySessionState(
        status: StudySessionStatus.inProgress,
        session: session,
        currentQuestion: state.currentQuestion,
        errorMessage: state.errorMessage,
      );
    }
  }

  /// 퀴즈 정답 처리
  Future<void> answerCorrect() async {
    final session = state.session;
    final question = state.currentQuestion;

    if (session == null || question == null) return;

    final studyService = _ref.read(studyServiceProvider);
    await studyService.processCorrectAnswer(
      session: session,
      question: question,
    );

    // 상태 갱신을 위해 providers 무효화
    _invalidateProgressProviders();
  }

  /// 퀴즈 오답 처리
  Future<void> answerWrong(String selectedAnswer) async {
    final session = state.session;
    final question = state.currentQuestion;

    if (session == null || question == null) return;

    final studyService = _ref.read(studyServiceProvider);
    await studyService.processWrongAnswer(
      session: session,
      question: question,
      selectedAnswer: selectedAnswer,
    );

    // 상태 갱신을 위해 providers 무효화
    _invalidateProgressProviders();
  }

  /// 다음 문제로 이동
  Future<void> moveNext() async {
    final session = state.session;
    if (session == null) return;

    session.moveNext();

    if (session.isCompleted) {
      await _completeSession();
    } else {
      // 다음 아이템이 퀴즈면 문제 로드
      await _loadCurrentQuestion();
      // session 변경을 반영하기 위해 상태 재설정
      state = StudySessionState(
        status: StudySessionStatus.inProgress,
        session: session,
        currentQuestion: state.currentQuestion,
        errorMessage: state.errorMessage,
      );
    }
  }

  /// 세션 완료 처리
  Future<void> _completeSession() async {
    final session = state.session;
    if (session == null) return;

    final studyService = _ref.read(studyServiceProvider);
    await studyService.completeSession(session);

    // 상태 갱신을 위해 providers 무효화
    _invalidateProgressProviders();

    state = state.copyWith(
      status: StudySessionStatus.completed,
      session: session,
    );
  }

  /// 진행률 관련 providers 무효화
  /// appStatsProvider를 invalidate하면 파생 providers(todaySummary, overallProgress, eraProgress)도 갱신됨
  void _invalidateProgressProviders() {
    _ref.invalidate(appStatsProvider);
    // 오답 노트 갱신을 위해 wrongAnswersWithQuestionsProvider도 무효화
    final locale = _ref.read(currentLocaleProvider);
    _ref.invalidate(wrongAnswersWithQuestionsProvider(locale));
  }

  /// 세션 중단
  void cancelSession() {
    state = const StudySessionState();
  }
}

/// Provider
final studySessionControllerProvider =
    StateNotifierProvider<StudySessionController, StudySessionState>((ref) {
  return StudySessionController(ref);
});
