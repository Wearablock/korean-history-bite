// lib/core/utils/question_selector.dart

import 'dart:math';
import '../../data/database/app_database.dart';
import '../../data/repositories/question_repository.dart';

/// 일일 문제 배분 결과
class DailyAllocation {
  final int wrongReview;
  final int spacedReview;
  final int newLearning;

  const DailyAllocation({
    required this.wrongReview,
    required this.spacedReview,
    required this.newLearning,
  });

  int get total => wrongReview + spacedReview + newLearning;

  @override
  String toString() {
    return 'DailyAllocation(wrong: $wrongReview, spaced: $spacedReview, new: $newLearning, total: $total)';
  }
}

/// 일일 문제 선택 결과
class DailyQuestionSelection {
  final List<String> wrongReviewIds;
  final List<String> spacedReviewIds;
  final List<String> newQuestionIds;
  final List<String> newChapterIds;

  /// 챕터별 신규 문제 ID (챕터 순서대로)
  final Map<String, List<String>> newQuestionsByChapter;

  const DailyQuestionSelection({
    required this.wrongReviewIds,
    required this.spacedReviewIds,
    required this.newQuestionIds,
    required this.newChapterIds,
    required this.newQuestionsByChapter,
  });

  List<String> get allQuestionIds => [
        ...wrongReviewIds,
        ...spacedReviewIds,
        ...newQuestionIds,
      ];

  int get totalCount => allQuestionIds.length;

  bool get isEmpty => totalCount == 0;

  @override
  String toString() {
    return 'DailyQuestionSelection(wrong: ${wrongReviewIds.length}, spaced: ${spacedReviewIds.length}, new: ${newQuestionIds.length})';
  }
}

class QuestionSelector {
  final AppDatabase _db;
  final QuestionRepository _questionRepository;

  QuestionSelector(this._db, this._questionRepository);

  /// 일일 문제 배분 계산
  DailyAllocation calculateAllocation({
    required int dailyGoal,
    required int availableWrongCount,
    required int availableReviewCount,
    required int availableNewCount,
  }) {
    // 오답 복습: 최대 10개 또는 목표의 1/3
    final maxWrong = min(10, dailyGoal ~/ 3);
    var wrongAllocation = min(availableWrongCount, maxWrong);

    // 망각곡선 복습: 최대 10개 또는 목표의 1/3
    final maxReview = min(10, dailyGoal ~/ 3);
    var spacedAllocation = min(availableReviewCount, maxReview);

    // 신규 학습: 나머지 (최소 5개 보장)
    var newAllocation = dailyGoal - wrongAllocation - spacedAllocation;

    // 신규 학습이 최소 5개는 되도록 조정
    if (newAllocation < 5 && dailyGoal >= 15 && availableNewCount >= 5) {
      final shortage = 5 - newAllocation;
      // 복습에서 줄여서 신규에 배분
      if (spacedAllocation >= shortage) {
        spacedAllocation -= shortage;
        newAllocation = 5;
      } else if (wrongAllocation >= shortage) {
        wrongAllocation -= shortage;
        newAllocation = 5;
      }
    }

    // 가용 신규 문제 수로 제한
    newAllocation = min(newAllocation, availableNewCount);

    // 신규 문제가 부족하면 복습 문제로 채움
    if (newAllocation < (dailyGoal - wrongAllocation - spacedAllocation)) {
      final remaining =
          dailyGoal - wrongAllocation - spacedAllocation - newAllocation;
      // 추가로 복습 문제 배분
      final additionalReview =
          min(remaining, availableReviewCount - spacedAllocation);
      spacedAllocation += additionalReview;
    }

    return DailyAllocation(
      wrongReview: wrongAllocation,
      spacedReview: spacedAllocation,
      newLearning: newAllocation,
    );
  }

  /// 오늘의 학습 문제 선택
  Future<DailyQuestionSelection> selectDailyQuestions({
    required int dailyGoal,
  }) async {
    // 1. 가용 문제 수 조회
    final wrongAnswers =
        await _db.wrongAnswersDao.getUncorrectedWrongAnswers();
    final spacedReviewRecords =
        await _db.studyRecordsDao.getSpacedReviewQuestions();
    final allStudiedIds = await _getAllStudiedQuestionIds();
    final allQuestionMeta = await _questionRepository.loadMeta();
    final allQuestionIds = allQuestionMeta.map((m) => m.id).toSet();
    final unstudiedIds = allQuestionIds.difference(allStudiedIds);

    // 2. 배분 계산
    final allocation = calculateAllocation(
      dailyGoal: dailyGoal,
      availableWrongCount: wrongAnswers.length,
      availableReviewCount: spacedReviewRecords.length,
      availableNewCount: unstudiedIds.length,
    );

    // 3. 오답 문제 선택 (많이 틀린 순)
    final wrongReviewIds = wrongAnswers
        .take(allocation.wrongReview)
        .map((w) => w.questionId)
        .toList();

    // 4. 망각곡선 복습 문제 선택 (레벨 낮은 순)
    final spacedReviewIds = spacedReviewRecords
        .take(allocation.spacedReview)
        .map((r) => r.questionId)
        .toList();

    // 5. 신규 문제 선택 (챕터 순서대로)
    final sortedUnstudied = allQuestionMeta
        .where((m) => unstudiedIds.contains(m.id))
        .toList();
    // 이미 order로 정렬되어 있음

    final newQuestionIds = sortedUnstudied
        .take(allocation.newLearning)
        .map((m) => m.id)
        .toList();

    // 6. 신규 문제의 챕터 ID 추출 및 챕터별 그룹화
    final newChapterIds = <String>[];
    final seenChapters = <String>{};
    final newQuestionsByChapter = <String, List<String>>{};

    for (final meta in sortedUnstudied.take(allocation.newLearning)) {
      // 챕터 ID 순서 유지
      if (!seenChapters.contains(meta.chapterId)) {
        seenChapters.add(meta.chapterId);
        newChapterIds.add(meta.chapterId);
        newQuestionsByChapter[meta.chapterId] = [];
      }
      // 챕터별로 문제 그룹화
      newQuestionsByChapter[meta.chapterId]!.add(meta.id);
    }

    return DailyQuestionSelection(
      wrongReviewIds: wrongReviewIds,
      spacedReviewIds: spacedReviewIds,
      newQuestionIds: newQuestionIds,
      newChapterIds: newChapterIds,
      newQuestionsByChapter: newQuestionsByChapter,
    );
  }

  /// 학습한 모든 문제 ID 조회
  Future<Set<String>> _getAllStudiedQuestionIds() async {
    final records = await _db.studyRecordsDao.getAllRecords();
    return records.map((r) => r.questionId).toSet();
  }

  /// 특정 챕터의 신규 문제 선택
  Future<List<String>> selectNewQuestionsFromChapter(
    String chapterId, {
    int? limit,
  }) async {
    final studiedRecords = await _db.studyRecordsDao.getByChapterId(chapterId);
    final studiedIds = studiedRecords.map((r) => r.questionId).toSet();

    final chapterQuestionIds =
        await _questionRepository.getQuestionIdsByChapter(chapterId);

    final unstudiedIds =
        chapterQuestionIds.where((id) => !studiedIds.contains(id)).toList();

    if (limit != null) {
      return unstudiedIds.take(limit).toList();
    }
    return unstudiedIds;
  }

  /// 복습이 필요한 총 문제 수 (중복 제외)
  Future<int> getReviewDueCount() async {
    // 오답 복습 대상
    final wrongAnswers = await _db.wrongAnswersDao.getUncorrectedWrongAnswers();
    final wrongIds = wrongAnswers.map((w) => w.questionId).toSet();

    // 망각곡선 복습 대상 (오답과 중복 제외)
    final spacedRecords = await _db.studyRecordsDao.getSpacedReviewQuestions(limit: 1000);
    final spacedOnlyCount = spacedRecords
        .where((r) => !wrongIds.contains(r.questionId))
        .length;

    return wrongIds.length + spacedOnlyCount;
  }

  /// 오늘 남은 학습량 계산
  Future<int> getRemainingDailyCount({required int dailyGoal}) async {
    final todayStudied = await _db.studyRecordsDao.getTodayStudiedCount();
    return max(0, dailyGoal - todayStudied);
  }

  /// 학습 가능한 총 문제 수 (신규 + 복습)
  Future<int> getAvailableQuestionCount() async {
    final wrongAnswers =
        await _db.wrongAnswersDao.getUncorrectedWrongAnswers();
    final spacedReviewRecords =
        await _db.studyRecordsDao.getSpacedReviewQuestions();
    final allStudiedIds = await _getAllStudiedQuestionIds();
    final allQuestionMeta = await _questionRepository.loadMeta();
    final unstudiedCount = allQuestionMeta
        .where((m) => !allStudiedIds.contains(m.id))
        .length;

    return wrongAnswers.length + spacedReviewRecords.length + unstudiedCount;
  }

  /// 복습 전용 문제 선택
  /// 오답 복습 + 망각곡선 복습만 선택 (신규 학습 없음)
  /// 중복 제거: 오답 복습에 포함된 문제는 망각곡선 복습에서 제외
  Future<DailyQuestionSelection> selectReviewQuestions({
    int maxWrong = 10,
    int maxSpaced = 10,
  }) async {
    // 1. 오답 문제 (많이 틀린 순)
    final wrongAnswers =
        await _db.wrongAnswersDao.getUncorrectedWrongAnswers(limit: maxWrong);
    final wrongReviewIds = wrongAnswers.map((w) => w.questionId).toList();
    final wrongIdSet = wrongReviewIds.toSet();

    // 2. 망각곡선 복습 (레벨 낮은 순, 복습일 오래된 순)
    // 오답 복습에 이미 포함된 문제는 제외
    final spacedRecords =
        await _db.studyRecordsDao.getSpacedReviewQuestions(limit: maxSpaced + wrongIdSet.length);
    final spacedReviewIds = spacedRecords
        .map((r) => r.questionId)
        .where((id) => !wrongIdSet.contains(id))
        .take(maxSpaced)
        .toList();

    return DailyQuestionSelection(
      wrongReviewIds: wrongReviewIds,
      spacedReviewIds: spacedReviewIds,
      newQuestionIds: [],
      newChapterIds: [],
      newQuestionsByChapter: {},
    );
  }

  /// 단일 챕터 문제 선택 (신규 학습용)
  /// 학습하지 않은 첫 번째 챕터의 모든 문제를 선택
  Future<DailyQuestionSelection> selectSingleChapterQuestions() async {
    final allStudiedIds = await _getAllStudiedQuestionIds();
    final allQuestionMeta = await _questionRepository.loadMeta();

    // 학습하지 않은 첫 번째 챕터 찾기
    String? targetChapterId;
    for (final meta in allQuestionMeta) {
      if (!allStudiedIds.contains(meta.id)) {
        targetChapterId = meta.chapterId;
        break;
      }
    }

    // 모든 챕터를 학습한 경우
    if (targetChapterId == null) {
      return const DailyQuestionSelection(
        wrongReviewIds: [],
        spacedReviewIds: [],
        newQuestionIds: [],
        newChapterIds: [],
        newQuestionsByChapter: {},
      );
    }

    // 해당 챕터의 모든 문제 선택
    final chapterQuestions = allQuestionMeta
        .where((m) => m.chapterId == targetChapterId)
        .map((m) => m.id)
        .toList();

    return DailyQuestionSelection(
      wrongReviewIds: [],
      spacedReviewIds: [],
      newQuestionIds: chapterQuestions,
      newChapterIds: [targetChapterId],
      newQuestionsByChapter: {targetChapterId: chapterQuestions},
    );
  }
}
