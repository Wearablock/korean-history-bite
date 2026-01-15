// lib/services/study_service.dart

import 'package:drift/drift.dart';
import '../core/utils/debug_utils.dart';
import '../core/utils/question_selector.dart';
import '../data/database/app_database.dart';
import '../data/models/question.dart';
import '../data/models/study_session.dart';
import '../data/repositories/question_repository.dart';

class StudyService {
  final AppDatabase _db;
  final QuestionRepository _questionRepository;
  late final QuestionSelector _questionSelector;

  StudyService(this._db, this._questionRepository) {
    _questionSelector = QuestionSelector(_db, _questionRepository);
  }

  /// QuestionSelector 접근자
  QuestionSelector get questionSelector => _questionSelector;

  /// 오늘의 학습 세션 생성
  Future<StudySession> createDailySession({int dailyGoal = 30}) async {
    final selection = await _questionSelector.selectDailyQuestions(
      dailyGoal: dailyGoal,
    );

    return StudySession(
      id: DebugUtils.now.millisecondsSinceEpoch.toString(),
      startedAt: DebugUtils.now,
      wrongReviewIds: selection.wrongReviewIds,
      spacedReviewIds: selection.spacedReviewIds,
      newQuestionIds: selection.newQuestionIds,
      newChapterIds: selection.newChapterIds,
      newQuestionsByChapter: selection.newQuestionsByChapter,
    );
  }

  /// 단일 챕터 학습 세션 생성
  Future<StudySession> createSingleChapterSession() async {
    final selection = await _questionSelector.selectSingleChapterQuestions();

    return StudySession(
      id: DebugUtils.now.millisecondsSinceEpoch.toString(),
      startedAt: DebugUtils.now,
      wrongReviewIds: selection.wrongReviewIds,
      spacedReviewIds: selection.spacedReviewIds,
      newQuestionIds: selection.newQuestionIds,
      newChapterIds: selection.newChapterIds,
      newQuestionsByChapter: selection.newQuestionsByChapter,
    );
  }

  /// 복습 전용 세션 생성
  Future<StudySession> createReviewSession() async {
    final selection = await _questionSelector.selectReviewQuestions();

    return StudySession(
      id: DebugUtils.now.millisecondsSinceEpoch.toString(),
      startedAt: DebugUtils.now,
      wrongReviewIds: selection.wrongReviewIds,
      spacedReviewIds: selection.spacedReviewIds,
      newQuestionIds: [],
      newChapterIds: [],
      newQuestionsByChapter: {},
    );
  }

  /// 복습 필요 여부 확인
  Future<bool> hasReviewDue() async {
    final count = await _questionSelector.getReviewDueCount();
    return count > 0;
  }

  /// 정답 처리
  Future<void> processCorrectAnswer({
    required StudySession session,
    required Question question,
  }) async {
    // 1. 세션에 결과 기록
    session.recordQuizResult(
      questionId: question.id,
      isCorrect: true,
    );

    // 2. 기존 학습 기록 조회
    final existingRecord =
        await _db.studyRecordsDao.getByQuestionId(question.id);

    final eraId = _getEraIdFromChapter(question.chapterId);

    if (existingRecord == null) {
      // 3a. 신규 문제: 새 레코드 생성 (레벨 1)
      await _db.studyRecordsDao.upsertRecord(StudyRecordsCompanion.insert(
        questionId: question.id,
        chapterId: question.chapterId,
        eraId: eraId,
        level: const Value(1),
        correctCount: const Value(1),
        lastStudiedAt: Value(DebugUtils.now),
        nextReviewAt: Value(DebugUtils.now.add(const Duration(days: 1))),
      ));
    } else {
      // 3b. 기존 문제: 레벨 업, 다음 복습일 계산
      await _db.studyRecordsDao.markCorrect(question.id);
    }

    // 4. 오답 풀에서 정답 처리 (있으면)
    await _db.wrongAnswersDao.markCorrected(question.id);

    // 5. 일일 통계 업데이트
    final isNew = existingRecord == null;
    await _db.dailyStatsDao.recordCorrectAnswer(isNewQuestion: isNew);
  }

  /// 오답 처리
  Future<void> processWrongAnswer({
    required StudySession session,
    required Question question,
    required String selectedAnswer,
  }) async {
    // 1. 세션에 결과 기록
    session.recordQuizResult(
      questionId: question.id,
      isCorrect: false,
      selectedAnswer: selectedAnswer,
    );

    // 2. 기존 학습 기록 조회
    final existingRecord =
        await _db.studyRecordsDao.getByQuestionId(question.id);

    final eraId = _getEraIdFromChapter(question.chapterId);

    if (existingRecord == null) {
      // 3a. 신규 문제: 레벨 0으로 생성, 내일 복습
      final tomorrow = DebugUtils.now.add(const Duration(days: 1));
      await _db.studyRecordsDao.upsertRecord(StudyRecordsCompanion.insert(
        questionId: question.id,
        chapterId: question.chapterId,
        eraId: eraId,
        level: const Value(0),
        wrongCount: const Value(1),
        lastStudiedAt: Value(DebugUtils.now),
        nextReviewAt: Value(tomorrow), // 내일 복습 대상 (같은 날 중복 방지)
      ));
    } else {
      // 3b. 기존 문제: 레벨 다운
      await _db.studyRecordsDao.markWrong(question.id);
    }

    // 4. 오답 풀에 추가
    await _db.wrongAnswersDao.recordWrongAnswer(
      questionId: question.id,
      chapterId: question.chapterId,
      eraId: eraId,
      selectedAnswer: selectedAnswer,
    );

    // 5. 일일 통계 업데이트
    final isNew = existingRecord == null;
    await _db.dailyStatsDao.recordWrongAnswer(isNewQuestion: isNew);
  }

  /// 세션 완료 처리
  Future<void> completeSession(StudySession session) async {
    session.complete();

    // 학습 시간 기록
    await _db.dailyStatsDao.addStudyTime(session.durationSeconds);
  }

  /// 챕터 ID에서 시대 ID 추출
  /// ch_prehistoric_01 -> prehistoric
  String _getEraIdFromChapter(String chapterId) {
    // ch_prehistoric_01 형식에서 시대 ID 추출
    final parts = chapterId.split('_');
    if (parts.length >= 2) {
      // ch_ 다음부터 마지막 숫자 부분 전까지
      // 예: ch_three_kingdoms_01 -> three_kingdoms
      if (parts.length == 3) {
        return parts[1];
      } else if (parts.length > 3) {
        // 언더스코어가 여러 개인 경우
        return parts.sublist(1, parts.length - 1).join('_');
      }
    }
    return 'unknown';
  }

  /// 오늘의 학습 요약 조회
  Future<TodaySummary> getTodaySummary() async {
    final todayStats = await _db.dailyStatsDao.getToday();
    final streak = await _db.dailyStatsDao.getCurrentStreak();
    final reviewDueCount = await _questionSelector.getReviewDueCount();
    final totalQuestionCount = await _questionRepository.getTotalQuestionCount();
    final masteredRecords = await _db.studyRecordsDao.getMasteredQuestions();

    // 다음 학습할 챕터 정보 조회
    final nextChapterInfo = await _getNextChapterInfo();

    return TodaySummary(
      questionsStudied: todayStats?.questionsStudied ?? 0,
      correctAnswers: todayStats?.correctAnswers ?? 0,
      streak: streak,
      reviewDueCount: reviewDueCount,
      totalQuestions: totalQuestionCount,
      masteredCount: masteredRecords.length,
      nextChapterId: nextChapterInfo.chapterId,
      nextChapterQuestionCount: nextChapterInfo.questionCount,
      allChaptersCompleted: nextChapterInfo.allCompleted,
    );
  }

  /// 다음 학습할 챕터 정보 조회
  Future<_NextChapterInfo> _getNextChapterInfo() async {
    final allStudiedIds =
        (await _db.studyRecordsDao.getAllRecords()).map((r) => r.questionId).toSet();
    final allQuestionMeta = await _questionRepository.loadMeta();

    // 학습하지 않은 첫 번째 챕터 찾기
    String? nextChapterId;
    for (final meta in allQuestionMeta) {
      if (!allStudiedIds.contains(meta.id)) {
        nextChapterId = meta.chapterId;
        break;
      }
    }

    // 모든 챕터 완료
    if (nextChapterId == null) {
      return const _NextChapterInfo(
        chapterId: null,
        questionCount: 0,
        allCompleted: true,
      );
    }

    // 해당 챕터의 문제 수 계산
    final chapterQuestionCount = allQuestionMeta
        .where((m) => m.chapterId == nextChapterId)
        .length;

    return _NextChapterInfo(
      chapterId: nextChapterId,
      questionCount: chapterQuestionCount,
      allCompleted: false,
    );
  }

  /// 전체 진행률 조회
  Future<double> getOverallProgress() async {
    final totalQuestionCount = await _questionRepository.getTotalQuestionCount();
    if (totalQuestionCount == 0) return 0.0;

    final masteredRecords = await _db.studyRecordsDao.getMasteredQuestions();
    return masteredRecords.length / totalQuestionCount;
  }

  /// 시대별 진행률 조회
  Future<Map<String, EraProgress>> getEraProgress() async {
    final allRecords = await _db.studyRecordsDao.getAllRecords();
    final allQuestionMeta = await _questionRepository.loadMeta();

    // 시대별 총 문제 수 계산
    final eraQuestionCounts = <String, int>{};
    for (final meta in allQuestionMeta) {
      final eraId = _getEraIdFromChapter(meta.chapterId);
      eraQuestionCounts[eraId] = (eraQuestionCounts[eraId] ?? 0) + 1;
    }

    // 시대별 학습/완전습득 문제 수 계산
    final eraStudiedCounts = <String, int>{};
    final eraMasteredCounts = <String, int>{};
    for (final record in allRecords) {
      final eraId = record.eraId;
      eraStudiedCounts[eraId] = (eraStudiedCounts[eraId] ?? 0) + 1;
      if (record.level >= 5) {
        eraMasteredCounts[eraId] = (eraMasteredCounts[eraId] ?? 0) + 1;
      }
    }

    // 결과 생성
    final result = <String, EraProgress>{};
    for (final eraId in eraQuestionCounts.keys) {
      final total = eraQuestionCounts[eraId]!;
      final studied = eraStudiedCounts[eraId] ?? 0;
      final mastered = eraMasteredCounts[eraId] ?? 0;

      result[eraId] = EraProgress(
        eraId: eraId,
        totalQuestions: total,
        studiedQuestions: studied,
        masteredQuestions: mastered,
      );
    }

    return result;
  }
}

/// 오늘의 학습 요약
class TodaySummary {
  final int questionsStudied;
  final int correctAnswers;
  final int streak;
  final int reviewDueCount;
  final int totalQuestions;
  final int masteredCount;

  /// 다음 학습할 챕터 정보
  final String? nextChapterId;
  final int nextChapterQuestionCount;

  /// 모든 챕터 완료 여부
  final bool allChaptersCompleted;

  const TodaySummary({
    required this.questionsStudied,
    required this.correctAnswers,
    required this.streak,
    required this.reviewDueCount,
    required this.totalQuestions,
    required this.masteredCount,
    this.nextChapterId,
    this.nextChapterQuestionCount = 0,
    this.allChaptersCompleted = false,
  });

  /// 오늘의 정답률
  double get todayAccuracy {
    if (questionsStudied == 0) return 0.0;
    return correctAnswers / questionsStudied;
  }

  /// 전체 진행률 (완전 습득 비율)
  double get overallProgress {
    if (totalQuestions == 0) return 0.0;
    return masteredCount / totalQuestions;
  }

  /// 학습할 챕터가 있는지
  bool get hasNextChapter => nextChapterId != null && !allChaptersCompleted;

  @override
  String toString() {
    return 'TodaySummary(studied: $questionsStudied, streak: $streak, mastered: $masteredCount/$totalQuestions, nextChapter: $nextChapterId)';
  }
}

/// 시대별 진행률
class EraProgress {
  final String eraId;
  final int totalQuestions;
  final int studiedQuestions;
  final int masteredQuestions;

  const EraProgress({
    required this.eraId,
    required this.totalQuestions,
    required this.studiedQuestions,
    required this.masteredQuestions,
  });

  /// 학습 진행률
  double get studiedProgress {
    if (totalQuestions == 0) return 0.0;
    return studiedQuestions / totalQuestions;
  }

  /// 완전 습득 진행률
  double get masteredProgress {
    if (totalQuestions == 0) return 0.0;
    return masteredQuestions / totalQuestions;
  }

  /// 남은 문제 수
  int get remainingQuestions => totalQuestions - studiedQuestions;

  @override
  String toString() {
    return 'EraProgress($eraId: studied $studiedQuestions/$totalQuestions, mastered $masteredQuestions)';
  }
}

/// 다음 학습할 챕터 정보 (내부 사용)
class _NextChapterInfo {
  final String? chapterId;
  final int questionCount;
  final bool allCompleted;

  const _NextChapterInfo({
    required this.chapterId,
    required this.questionCount,
    required this.allCompleted,
  });
}
