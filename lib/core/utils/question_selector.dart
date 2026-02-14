// lib/core/utils/question_selector.dart

import 'dart:math';
import '../config/constants.dart';
import '../../data/database/app_database.dart';
import '../../data/models/question.dart';
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

  /// 챕터별 문제 맵 생성 (O(n) -> O(1) 조회 가능)
  Map<String, List<QuestionMeta>> _buildChapterMap(List<QuestionMeta> allMeta) {
    final chapterMap = <String, List<QuestionMeta>>{};
    for (final meta in allMeta) {
      chapterMap.putIfAbsent(meta.chapterId, () => []).add(meta);
    }
    return chapterMap;
  }

  /// 미학습 챕터 목록 조회 (순서 유지, 챕터맵 활용)
  List<String> _findUnstudiedChapters({
    required List<QuestionMeta> allMeta,
    required Set<String> studiedIds,
  }) {
    final unstudiedChapters = <String>[];
    final seenChapters = <String>{};

    for (final meta in allMeta) {
      if (!studiedIds.contains(meta.id) &&
          !seenChapters.contains(meta.chapterId)) {
        seenChapters.add(meta.chapterId);
        unstudiedChapters.add(meta.chapterId);
      }
    }

    return unstudiedChapters;
  }

  /// 일일 문제 배분 계산
  DailyAllocation calculateAllocation({
    required int dailyGoal,
    required int availableWrongCount,
    required int availableReviewCount,
    required int availableNewCount,
  }) {
    // 복습 총 할당: 최대 maxReviewCount개 또는 목표의 2/3
    final maxReview = min(StudyConstants.maxReviewCount, dailyGoal * 2 ~/ 3);
    // 오답 복습 우선 배분
    var wrongAllocation = min(availableWrongCount, maxReview);
    // 나머지를 망각곡선 복습에 배분
    final remainingReview = maxReview - wrongAllocation;
    var spacedAllocation = min(availableReviewCount, remainingReview);

    // 신규 학습: 나머지 (최소 minNewLearningCount개 보장)
    var newAllocation = dailyGoal - wrongAllocation - spacedAllocation;

    // 신규 학습이 최소 개수는 되도록 조정
    final minDailyGoal = StudyConstants.dailyGoalOptions.first;
    if (newAllocation < StudyConstants.minNewLearningCount &&
        dailyGoal >= minDailyGoal &&
        availableNewCount >= StudyConstants.minNewLearningCount) {
      final shortage = StudyConstants.minNewLearningCount - newAllocation;
      // 복습에서 줄여서 신규에 배분
      if (spacedAllocation >= shortage) {
        spacedAllocation -= shortage;
        newAllocation = StudyConstants.minNewLearningCount;
      } else if (wrongAllocation >= shortage) {
        wrongAllocation -= shortage;
        newAllocation = StudyConstants.minNewLearningCount;
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
    // 1. 가용 문제 수 조회 (통합된 복습 시스템)
    final reviewRecords = await _db.studyRecordsDao.getReviewQuestions(limit: 1000);
    final wrongRecords = reviewRecords.where((r) => r.level == 0).toList();
    final spacedRecords = reviewRecords.where((r) => r.level > 0).toList();

    final allStudiedIds = await _getAllStudiedQuestionIds();
    final allQuestionMeta = await _questionRepository.loadMeta();
    final allQuestionIds = allQuestionMeta.map((m) => m.id).toSet();
    final unstudiedIds = allQuestionIds.difference(allStudiedIds);

    // 2. 배분 계산
    final allocation = calculateAllocation(
      dailyGoal: dailyGoal,
      availableWrongCount: wrongRecords.length,
      availableReviewCount: spacedRecords.length,
      availableNewCount: unstudiedIds.length,
    );

    // 3. 오답 문제 선택 (레벨 0)
    final wrongReviewIds = wrongRecords
        .take(allocation.wrongReview)
        .map((r) => r.questionId)
        .toList();

    // 4. 망각곡선 복습 문제 선택 (레벨 1+)
    final spacedReviewIds = spacedRecords
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

  /// 복습이 필요한 총 문제 수
  /// study_records에서 레벨 기반으로 통합 조회
  Future<int> getReviewDueCount() async {
    final reviewRecords = await _db.studyRecordsDao.getReviewQuestions(limit: 1000);
    return reviewRecords.length;
  }

  /// 오늘 남은 학습량 계산
  Future<int> getRemainingDailyCount({required int dailyGoal}) async {
    final todayStudied = await _db.studyRecordsDao.getTodayStudiedCount();
    return max(0, dailyGoal - todayStudied);
  }

  /// 학습 가능한 총 문제 수 (신규 + 복습)
  Future<int> getAvailableQuestionCount() async {
    // 병렬로 데이터 로드
    final results = await Future.wait([
      _db.studyRecordsDao.getReviewQuestions(limit: 1000),
      _getAllStudiedQuestionIds(),
      _questionRepository.loadMeta(),
    ]);
    final reviewRecords = results[0] as List<StudyRecord>;
    final allStudiedIds = results[1] as Set<String>;
    final allQuestionMeta = results[2] as List<QuestionMeta>;

    final unstudiedCount = allQuestionMeta
        .where((m) => !allStudiedIds.contains(m.id))
        .length;

    return reviewRecords.length + unstudiedCount;
  }

  /// 복습 전용 문제 선택
  /// study_records 테이블에서 레벨 기반으로 통합 조회
  /// 레벨 0: 오답 복습 (오답으로 리셋된 문제)
  /// 레벨 1+: 망각곡선 복습
  Future<DailyQuestionSelection> selectReviewQuestions({
    int? maxTotal,
  }) async {
    maxTotal ??= StudyConstants.maxReviewCount;

    // 복습 대상 문제 조회 (레벨 낮은 순 = 오답 먼저)
    final reviewRecords = await _db.studyRecordsDao.getReviewQuestions(
      limit: maxTotal,
    );

    // 레벨 0 (오답 복습) 우선, 나머지를 망각곡선 복습으로 채움
    final wrongReviewIds = reviewRecords
        .where((r) => r.level == 0)
        .map((r) => r.questionId)
        .toList();

    final remaining = maxTotal - wrongReviewIds.length;
    final spacedReviewIds = reviewRecords
        .where((r) => r.level > 0)
        .take(remaining)
        .map((r) => r.questionId)
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
    return selectMultiChapterQuestions(chapterCount: 1);
  }

  /// 복수 챕터 문제 선택 (일일 학습용)
  /// 학습하지 않은 챕터들에서 순서대로 [chapterCount]개 챕터의 모든 문제를 선택
  Future<DailyQuestionSelection> selectMultiChapterQuestions({
    required int chapterCount,
  }) async {
    // 병렬로 데이터 로드
    final results = await Future.wait([
      _getAllStudiedQuestionIds(),
      _questionRepository.loadMeta(),
    ]);
    final allStudiedIds = results[0] as Set<String>;
    final allQuestionMeta = results[1] as List<QuestionMeta>;

    // 미학습 챕터 찾기 (공통 헬퍼 사용)
    final unstudiedChapters = _findUnstudiedChapters(
      allMeta: allQuestionMeta,
      studiedIds: allStudiedIds,
    );

    // 모든 챕터를 학습한 경우
    if (unstudiedChapters.isEmpty) {
      return const DailyQuestionSelection(
        wrongReviewIds: [],
        spacedReviewIds: [],
        newQuestionIds: [],
        newChapterIds: [],
        newQuestionsByChapter: {},
      );
    }

    // 요청된 챕터 수만큼 선택 (가용 챕터 수 제한)
    final targetChapters = unstudiedChapters.take(chapterCount).toList();

    // 챕터맵 생성하여 O(1) 조회
    final chapterMap = _buildChapterMap(allQuestionMeta);

    // 선택된 챕터들의 문제 수집 (O(n) -> O(챕터수 * 챕터당문제수))
    final newQuestionIds = <String>[];
    final newQuestionsByChapter = <String, List<String>>{};

    for (final chapterId in targetChapters) {
      final chapterMeta = chapterMap[chapterId] ?? [];
      final chapterQuestions = chapterMeta
          .where((m) => !allStudiedIds.contains(m.id))
          .map((m) => m.id)
          .toList();

      newQuestionsByChapter[chapterId] = chapterQuestions;
      newQuestionIds.addAll(chapterQuestions);
    }

    return DailyQuestionSelection(
      wrongReviewIds: [],
      spacedReviewIds: [],
      newQuestionIds: newQuestionIds,
      newChapterIds: targetChapters,
      newQuestionsByChapter: newQuestionsByChapter,
    );
  }

  /// 복습 + 신규 챕터 통합 선택 (일일 학습용)
  /// 복습 문제를 먼저 배분하고, 남은 할당량을 신규 챕터 문제로 채움
  Future<DailyQuestionSelection> selectDailyChapterQuestions({
    required int chapterCount,
  }) async {
    // 1. 복습 문제 선택
    final reviewRecords = await _db.studyRecordsDao.getReviewQuestions(limit: 1000);
    final wrongRecords = reviewRecords.where((r) => r.level == 0).toList();
    final spacedRecords = reviewRecords.where((r) => r.level > 0).toList();

    // 복습 문제 배분 (오답 + 망각곡선 합산 최대 maxReviewCount개, 오답 우선)
    final wrongReviewIds = wrongRecords
        .take(StudyConstants.maxReviewCount)
        .map((r) => r.questionId)
        .toList();

    final remainingSlots = StudyConstants.maxReviewCount - wrongReviewIds.length;
    final spacedReviewIds = spacedRecords
        .take(max(0, remainingSlots))
        .map((r) => r.questionId)
        .toList();

    // 2. 신규 챕터 문제 선택
    final newChapterSelection = await selectMultiChapterQuestions(
      chapterCount: chapterCount,
    );

    return DailyQuestionSelection(
      wrongReviewIds: wrongReviewIds,
      spacedReviewIds: spacedReviewIds,
      newQuestionIds: newChapterSelection.newQuestionIds,
      newChapterIds: newChapterSelection.newChapterIds,
      newQuestionsByChapter: newChapterSelection.newQuestionsByChapter,
    );
  }

  /// 남은 학습 챕터 수 조회
  Future<int> getRemainingChapterCount() async {
    // 병렬로 데이터 로드
    final results = await Future.wait([
      _getAllStudiedQuestionIds(),
      _questionRepository.loadMeta(),
    ]);
    final allStudiedIds = results[0] as Set<String>;
    final allQuestionMeta = results[1] as List<QuestionMeta>;

    // 공통 헬퍼 사용
    return _findUnstudiedChapters(
      allMeta: allQuestionMeta,
      studiedIds: allStudiedIds,
    ).length;
  }

  /// 미학습 챕터 목록 조회 (순서대로)
  Future<List<String>> getUnstudiedChapterIds() async {
    // 병렬로 데이터 로드
    final results = await Future.wait([
      _getAllStudiedQuestionIds(),
      _questionRepository.loadMeta(),
    ]);
    final allStudiedIds = results[0] as Set<String>;
    final allQuestionMeta = results[1] as List<QuestionMeta>;

    // 공통 헬퍼 사용
    return _findUnstudiedChapters(
      allMeta: allQuestionMeta,
      studiedIds: allStudiedIds,
    );
  }

  /// 시대별 문제 선택 (해당 시대의 미학습 챕터에서 1챕터씩)
  Future<DailyQuestionSelection> selectEraQuestions(String eraId) async {
    // 병렬로 데이터 로드
    final results = await Future.wait([
      _questionRepository.loadMetaByEra(eraId),
      _getAllStudiedQuestionIds(),
    ]);
    final eraMeta = results[0] as List<QuestionMeta>;
    final allStudiedIds = results[1] as Set<String>;

    // 시대 내 미학습 챕터 찾기
    final unstudiedChapters = _findUnstudiedChapters(
      allMeta: eraMeta,
      studiedIds: allStudiedIds,
    );

    if (unstudiedChapters.isEmpty) {
      return const DailyQuestionSelection(
        wrongReviewIds: [],
        spacedReviewIds: [],
        newQuestionIds: [],
        newChapterIds: [],
        newQuestionsByChapter: {},
      );
    }

    // 첫 번째 미학습 챕터의 문제 선택
    final targetChapter = unstudiedChapters.first;
    final chapterMap = _buildChapterMap(eraMeta);
    final chapterMeta = chapterMap[targetChapter] ?? [];
    final chapterQuestions = chapterMeta
        .where((m) => !allStudiedIds.contains(m.id))
        .map((m) => m.id)
        .toList();

    return DailyQuestionSelection(
      wrongReviewIds: [],
      spacedReviewIds: [],
      newQuestionIds: chapterQuestions,
      newChapterIds: [targetChapter],
      newQuestionsByChapter: {targetChapter: chapterQuestions},
    );
  }
}
