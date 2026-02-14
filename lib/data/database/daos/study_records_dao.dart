import 'package:drift/drift.dart';
import '../../../core/config/constants.dart';
import '../../../core/utils/debug_utils.dart';
import '../app_database.dart';
import '../tables/study_records.dart';

part 'study_records_dao.g.dart';

@DriftAccessor(tables: [StudyRecords])
class StudyRecordsDao extends DatabaseAccessor<AppDatabase>
    with _$StudyRecordsDaoMixin {
  StudyRecordsDao(super.db);

  // ============================================================
  // 기본 CRUD 연산
  // ============================================================

  /// 모든 학습 기록 조회
  Future<List<StudyRecord>> getAllRecords() => select(studyRecords).get();

  /// 문제 ID로 학습 기록 조회
  Future<StudyRecord?> getByQuestionId(String questionId) {
    return (select(studyRecords)
          ..where((t) => t.questionId.equals(questionId)))
        .getSingleOrNull();
  }

  /// 학습 기록 생성 또는 업데이트 (Upsert)
  Future<void> upsertRecord(StudyRecordsCompanion record) {
    return into(studyRecords).insertOnConflictUpdate(record);
  }

  /// 학습 기록 삭제
  Future<int> deleteByQuestionId(String questionId) {
    return (delete(studyRecords)
          ..where((t) => t.questionId.equals(questionId)))
        .go();
  }

  /// 모든 학습 기록 삭제 (초기화)
  Future<int> deleteAll() => delete(studyRecords).go();

  // ============================================================
  // 챕터/시대별 조회
  // ============================================================

  /// 챕터별 학습 기록 조회
  Future<List<StudyRecord>> getByChapterId(String chapterId) {
    return (select(studyRecords)
          ..where((t) => t.chapterId.equals(chapterId)))
        .get();
  }

  /// 시대별 학습 기록 조회
  Future<List<StudyRecord>> getByEraId(String eraId) {
    return (select(studyRecords)..where((t) => t.eraId.equals(eraId))).get();
  }

  // ============================================================
  // 레벨별 조회 (스페이스드 리피티션)
  // ============================================================

  /// 특정 레벨의 문제 조회
  Future<List<StudyRecord>> getByLevel(int level) {
    return (select(studyRecords)..where((t) => t.level.equals(level))).get();
  }

  /// 완전 습득 문제 조회
  Future<List<StudyRecord>> getMasteredQuestions() {
    return (select(studyRecords)
          ..where((t) => t.level.equals(StudyConstants.masteryLevel)))
        .get();
  }

  // ============================================================
  // 복습 대상 문제 조회
  // ============================================================

  /// 복습 문제 조회 (레벨 0~masteryLevel-1, 복습 시간 도래)
  /// 레벨 0: 오답으로 리셋된 문제 (오답 복습)
  /// 레벨 1+: 정상 복습 대상 (망각곡선 복습)
  /// 오늘 이미 학습한 문제는 제외
  Future<List<StudyRecord>> getReviewQuestions({int limit = 100}) {
    final now = DebugUtils.now; // 디버그 모드에서 시간 조작 지원
    final startOfDay = DateTime(now.year, now.month, now.day);
    return (select(studyRecords)
          ..where((t) =>
              t.level.isSmallerThanValue(StudyConstants.masteryLevel) &
              t.nextReviewAt.isSmallerOrEqualValue(now) &
              // 오늘 학습한 문제는 제외 (중복 복습 방지)
              t.lastStudiedAt.isSmallerThanValue(startOfDay))
          ..orderBy([
            (t) => OrderingTerm(expression: t.level), // 레벨 낮은 순 (오답 먼저)
            (t) => OrderingTerm(expression: t.nextReviewAt), // 복습일 오래된 순
          ])
          ..limit(limit))
        .get();
  }

  // ============================================================
  // 학습 결과 업데이트
  // ============================================================

  /// 정답 처리: 레벨 +1, 다음 복습 시간 계산
  Future<void> markCorrect(String questionId) async {
    final record = await getByQuestionId(questionId);
    if (record == null) return;

    final now = DebugUtils.now; // 디버그 모드 지원
    final newLevel = (record.level + 1).clamp(0, StudyConstants.masteryLevel);
    final nextReview = _calculateNextReview(newLevel);

    await (update(studyRecords)
          ..where((t) => t.questionId.equals(questionId)))
        .write(StudyRecordsCompanion(
      level: Value(newLevel),
      correctCount: Value(record.correctCount + 1),
      lastStudiedAt: Value(now),
      nextReviewAt: Value(nextReview),
      updatedAt: Value(now),
    ));
  }

  /// 오답 처리: 레벨 0으로 리셋 (오답 복습으로 이동, 망각곡선 복습에서 제외)
  /// 오답 복습에서 정답 맞추면 레벨 1부터 다시 시작
  Future<void> markWrong(String questionId) async {
    final record = await getByQuestionId(questionId);
    if (record == null) return;

    final now = DebugUtils.now; // 디버그 모드 지원
    // 오답이어도 내일 자정부터 복습하도록 설정 (같은 날 중복 복습 방지)
    final tomorrowMidnight = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));

    await (update(studyRecords)
          ..where((t) => t.questionId.equals(questionId)))
        .write(StudyRecordsCompanion(
      level: const Value(0), // 항상 레벨 0으로 리셋 (망각곡선 복습에서 제외)
      wrongCount: Value(record.wrongCount + 1),
      lastStudiedAt: Value(now),
      nextReviewAt: Value(tomorrowMidnight), // 내일 자정부터 복습 대상
      updatedAt: Value(now),
    ));
  }

  /// 다음 복습 시간 계산 (로컬 자정 기준)
  /// 예: 오늘 오후 3시에 정답 → 레벨1 → 내일 자정(00:00)부터 복습 가능
  DateTime _calculateNextReview(int level) {
    final now = DebugUtils.now; // 디버그 모드 지원
    final days = StudyConstants.reviewIntervals[level.clamp(0, StudyConstants.masteryLevel)];
    // 오늘 자정 + days일 = days일 후 자정
    return DateTime(now.year, now.month, now.day).add(Duration(days: days));
  }

  // ============================================================
  // 통계 쿼리
  // ============================================================

  /// 전체 학습한 문제 수
  Future<int> getTotalStudiedCount() async {
    final count = studyRecords.id.count();
    final query = selectOnly(studyRecords)..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  /// 챕터별 학습 진행률
  Future<Map<String, double>> getChapterProgress() async {
    final records = await getAllRecords();
    final chapterGroups = <String, List<StudyRecord>>{};

    for (final record in records) {
      chapterGroups.putIfAbsent(record.chapterId, () => []).add(record);
    }

    return chapterGroups.map((chapterId, records) {
      final masteredCount = records.where((r) => r.level >= 3).length;
      return MapEntry(chapterId, masteredCount / records.length);
    });
  }

  /// 시대별 학습 진행률
  Future<Map<String, double>> getEraProgress() async {
    final records = await getAllRecords();
    final eraGroups = <String, List<StudyRecord>>{};

    for (final record in records) {
      eraGroups.putIfAbsent(record.eraId, () => []).add(record);
    }

    return eraGroups.map((eraId, records) {
      final masteredCount = records.where((r) => r.level >= 3).length;
      return MapEntry(eraId, masteredCount / records.length);
    });
  }

  /// 전체 정답률 계산
  Future<double> getOverallAccuracy() async {
    final records = await getAllRecords();
    if (records.isEmpty) return 0.0;

    int totalCorrect = 0;
    int totalAttempts = 0;

    for (final record in records) {
      totalCorrect += record.correctCount;
      totalAttempts += record.correctCount + record.wrongCount;
    }

    if (totalAttempts == 0) return 0.0;
    return totalCorrect / totalAttempts;
  }

  /// 레벨별 문제 수 통계
  Future<Map<int, int>> getLevelDistribution() async {
    final records = await getAllRecords();
    final distribution = <int, int>{};

    for (int i = 0; i <= StudyConstants.masteryLevel; i++) {
      distribution[i] = 0;
    }

    for (final record in records) {
      distribution[record.level] = (distribution[record.level] ?? 0) + 1;
    }

    return distribution;
  }

  /// 오늘 학습한 문제 수
  Future<int> getTodayStudiedCount() async {
    final today = DebugUtils.now; // 디버그 모드 지원
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final query = select(studyRecords)
      ..where((t) =>
          t.lastStudiedAt.isBiggerOrEqualValue(startOfDay) &
          t.lastStudiedAt.isSmallerThanValue(endOfDay));

    final records = await query.get();
    return records.length;
  }

  /// 오늘 신규 학습한 챕터 수 (오늘 처음 생성된 레코드의 고유 챕터 ID 기준)
  /// 복습은 제외하고 신규 학습만 카운트
  Future<int> getTodayStudiedChapterCount() async {
    final today = DebugUtils.now; // 디버그 모드 지원
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final query = select(studyRecords)
      ..where((t) =>
          t.createdAt.isBiggerOrEqualValue(startOfDay) &
          t.createdAt.isSmallerThanValue(endOfDay));

    final records = await query.get();

    // 고유한 챕터 ID 수 반환
    final uniqueChapters = records.map((r) => r.chapterId).toSet();
    return uniqueChapters.length;
  }
}
