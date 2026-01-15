// lib/data/providers/study_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../core/utils/question_selector.dart';
import '../../services/study_service.dart';
import '../models/study_session.dart';
import 'database_providers.dart';
import 'question_providers.dart';

// ============================================================
// Core Providers
// ============================================================

/// QuestionSelector 제공
final questionSelectorProvider = Provider<QuestionSelector>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final questionRepo = ref.watch(questionRepositoryProvider);
  return QuestionSelector(db, questionRepo);
});

/// StudyService 제공
final studyServiceProvider = Provider<StudyService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final questionRepo = ref.watch(questionRepositoryProvider);
  return StudyService(db, questionRepo);
});

// ============================================================
// Session Providers
// ============================================================

/// 현재 학습 세션 (StateProvider로 관리)
final currentSessionProvider = StateProvider<StudySession?>((ref) => null);

/// 세션 생성 (FutureProvider)
final createSessionProvider = FutureProvider.family<StudySession, int>(
  (ref, dailyGoal) async {
    final studyService = ref.watch(studyServiceProvider);
    return studyService.createDailySession(dailyGoal: dailyGoal);
  },
);

// ============================================================
// Summary & Stats Providers
// ============================================================

/// 오늘의 학습 요약
final todaySummaryProvider = FutureProvider<TodaySummary>((ref) async {
  final studyService = ref.watch(studyServiceProvider);
  return studyService.getTodaySummary();
});

/// 전체 진행률
final overallProgressProvider = FutureProvider<double>((ref) async {
  final studyService = ref.watch(studyServiceProvider);
  return studyService.getOverallProgress();
});

/// 시대별 진행률
final eraProgressProvider =
    FutureProvider<Map<String, EraProgress>>((ref) async {
  final studyService = ref.watch(studyServiceProvider);
  return studyService.getEraProgress();
});

/// 복습 필요 문제 수
final reviewDueCountProvider = FutureProvider<int>((ref) async {
  final selector = ref.watch(questionSelectorProvider);
  return selector.getReviewDueCount();
});

/// 학습 가능한 총 문제 수
final availableQuestionCountProvider = FutureProvider<int>((ref) async {
  final selector = ref.watch(questionSelectorProvider);
  return selector.getAvailableQuestionCount();
});

// ============================================================
// Allocation Preview Providers
// ============================================================

/// 일일 문제 배분 미리보기
final dailyAllocationPreviewProvider =
    FutureProvider.family<DailyAllocation, int>((ref, dailyGoal) async {
  final selector = ref.watch(questionSelectorProvider);
  final db = ref.watch(appDatabaseProvider);
  final questionRepo = ref.watch(questionRepositoryProvider);

  final wrongAnswers = await db.wrongAnswersDao.getUncorrectedWrongAnswers();
  final spacedReviewRecords =
      await db.studyRecordsDao.getSpacedReviewQuestions();
  final allRecords = await db.studyRecordsDao.getAllRecords();
  final allQuestionMeta = await questionRepo.loadMeta();

  final studiedIds = allRecords.map((r) => r.questionId).toSet();
  final unstudiedCount =
      allQuestionMeta.where((m) => !studiedIds.contains(m.id)).length;

  return selector.calculateAllocation(
    dailyGoal: dailyGoal,
    availableWrongCount: wrongAnswers.length,
    availableReviewCount: spacedReviewRecords.length,
    availableNewCount: unstudiedCount,
  );
});

/// 일일 문제 선택 미리보기
final dailySelectionPreviewProvider =
    FutureProvider.family<DailyQuestionSelection, int>((ref, dailyGoal) async {
  final selector = ref.watch(questionSelectorProvider);
  return selector.selectDailyQuestions(dailyGoal: dailyGoal);
});
