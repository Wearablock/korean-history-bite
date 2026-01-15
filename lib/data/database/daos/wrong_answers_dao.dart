import 'package:drift/drift.dart';
import '../../../core/utils/debug_utils.dart';
import '../app_database.dart';
import '../tables/wrong_answers.dart';

part 'wrong_answers_dao.g.dart';

@DriftAccessor(tables: [WrongAnswers])
class WrongAnswersDao extends DatabaseAccessor<AppDatabase>
    with _$WrongAnswersDaoMixin {
  WrongAnswersDao(super.db);

  // ============================================================
  // 기본 CRUD 연산
  // ============================================================

  /// 모든 오답 조회
  Future<List<WrongAnswer>> getAllWrongAnswers() => select(wrongAnswers).get();

  /// 문제 ID로 오답 조회
  Future<WrongAnswer?> getByQuestionId(String questionId) {
    return (select(wrongAnswers)
          ..where((t) => t.questionId.equals(questionId)))
        .getSingleOrNull();
  }

  /// 오답 기록 생성 또는 업데이트 (Upsert)
  Future<void> upsertWrongAnswer(WrongAnswersCompanion record) {
    return into(wrongAnswers).insertOnConflictUpdate(record);
  }

  /// 오답 삭제 (정답 맞춤)
  Future<int> deleteByQuestionId(String questionId) {
    return (delete(wrongAnswers)
          ..where((t) => t.questionId.equals(questionId)))
        .go();
  }

  /// 모든 오답 삭제 (초기화)
  Future<int> deleteAll() => delete(wrongAnswers).go();

  // ============================================================
  // 오답 기록 관리
  // ============================================================

  /// 오답 등록 (새로 틀렸을 때)
  Future<void> recordWrongAnswer({
    required String questionId,
    required String chapterId,
    required String eraId,
    required String selectedAnswer,
  }) async {
    final existing = await getByQuestionId(questionId);
    final now = DebugUtils.now; // 디버그 모드 지원

    if (existing == null) {
      // 새 오답 등록
      await upsertWrongAnswer(WrongAnswersCompanion.insert(
        questionId: questionId,
        chapterId: chapterId,
        eraId: eraId,
        wrongCount: const Value(1),
        lastWrongAnswer: Value(selectedAnswer),
        wrongAt: now,
      ));
    } else {
      // 기존 오답 업데이트 (횟수 증가)
      await upsertWrongAnswer(WrongAnswersCompanion(
        id: Value(existing.id),
        questionId: Value(questionId),
        chapterId: Value(chapterId),
        eraId: Value(eraId),
        wrongCount: Value(existing.wrongCount + 1),
        lastWrongAnswer: Value(selectedAnswer),
        wrongAt: Value(now),
        correctedAt: const Value(null), // 다시 틀렸으므로 리셋
        updatedAt: Value(now),
      ));
    }
  }

  /// 정답 맞춤 (복습 성공)
  Future<void> markCorrected(String questionId) async {
    final now = DebugUtils.now; // 디버그 모드 지원
    await (update(wrongAnswers)..where((t) => t.questionId.equals(questionId)))
        .write(WrongAnswersCompanion(
      correctedAt: Value(now),
      updatedAt: Value(now),
    ));
  }

  /// 오답 완전 삭제 (레벨 3 이상 도달 시)
  Future<void> removeFromWrongPool(String questionId) async {
    await deleteByQuestionId(questionId);
  }

  // ============================================================
  // 오답 조회 (복습용)
  // ============================================================

  /// 미해결 오답 조회 (correctedAt이 null이고, 오늘 복습하지 않은 것)
  Future<List<WrongAnswer>> getUncorrectedWrongAnswers({int? limit}) {
    final today = DebugUtils.now; // 디버그 모드 지원
    final startOfDay = DateTime(today.year, today.month, today.day);

    final query = select(wrongAnswers)
      ..where((t) =>
          t.correctedAt.isNull() &
          // 오늘 업데이트(복습)한 문제는 제외 - 내일 다시 복습
          t.updatedAt.isSmallerThanValue(startOfDay))
      ..orderBy([
        (t) => OrderingTerm.desc(t.wrongCount), // 많이 틀린 순
        (t) => OrderingTerm.desc(t.wrongAt), // 최근 틀린 순
      ]);

    if (limit != null) {
      query.limit(limit);
    }

    return query.get();
  }

  /// 최근 틀린 문제 조회
  Future<List<WrongAnswer>> getRecentWrongAnswers({int limit = 10}) {
    return (select(wrongAnswers)
          ..orderBy([(t) => OrderingTerm.desc(t.wrongAt)])
          ..limit(limit))
        .get();
  }

  /// 가장 많이 틀린 문제 조회
  Future<List<WrongAnswer>> getMostWrongAnswers({int limit = 10}) {
    return (select(wrongAnswers)
          ..orderBy([(t) => OrderingTerm.desc(t.wrongCount)])
          ..limit(limit))
        .get();
  }

  /// 복습 완료된 오답 조회
  Future<List<WrongAnswer>> getCorrectedWrongAnswers() {
    return (select(wrongAnswers)
          ..where((t) => t.correctedAt.isNotNull())
          ..orderBy([(t) => OrderingTerm.desc(t.correctedAt)]))
        .get();
  }

  // ============================================================
  // 챕터/시대별 조회
  // ============================================================

  /// 챕터별 오답 조회
  Future<List<WrongAnswer>> getByChapterId(String chapterId) {
    return (select(wrongAnswers)
          ..where((t) => t.chapterId.equals(chapterId))
          ..orderBy([(t) => OrderingTerm.desc(t.wrongCount)]))
        .get();
  }

  /// 시대별 오답 조회
  Future<List<WrongAnswer>> getByEraId(String eraId) {
    return (select(wrongAnswers)
          ..where((t) => t.eraId.equals(eraId))
          ..orderBy([(t) => OrderingTerm.desc(t.wrongCount)]))
        .get();
  }

  // ============================================================
  // 통계
  // ============================================================

  /// 전체 오답 수
  Future<int> getTotalWrongCount() async {
    final count = wrongAnswers.id.count();
    final query = selectOnly(wrongAnswers)..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  /// 미해결 오답 수 (오늘 복습한 것 제외)
  Future<int> getUncorrectedCount() async {
    final today = DebugUtils.now; // 디버그 모드 지원
    final startOfDay = DateTime(today.year, today.month, today.day);

    final query = select(wrongAnswers)
      ..where((t) =>
          t.correctedAt.isNull() &
          t.updatedAt.isSmallerThanValue(startOfDay));
    final results = await query.get();
    return results.length;
  }

  /// 챕터별 오답 통계
  Future<Map<String, int>> getWrongCountByChapter() async {
    final all = await getAllWrongAnswers();
    final result = <String, int>{};

    for (final item in all) {
      result[item.chapterId] = (result[item.chapterId] ?? 0) + 1;
    }

    return result;
  }

  /// 시대별 오답 통계
  Future<Map<String, int>> getWrongCountByEra() async {
    final all = await getAllWrongAnswers();
    final result = <String, int>{};

    for (final item in all) {
      result[item.eraId] = (result[item.eraId] ?? 0) + 1;
    }

    return result;
  }

  /// 오답률 높은 챕터 TOP N
  Future<List<MapEntry<String, int>>> getTopWrongChapters(
      {int limit = 5}) async {
    final byChapter = await getWrongCountByChapter();
    final sorted = byChapter.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).toList();
  }

  // ============================================================
  // Stream (실시간 감지)
  // ============================================================

  /// 미해결 오답 변경 감지
  Stream<List<WrongAnswer>> watchUncorrectedWrongAnswers() {
    return (select(wrongAnswers)
          ..where((t) => t.correctedAt.isNull())
          ..orderBy([
            (t) => OrderingTerm.desc(t.wrongCount),
            (t) => OrderingTerm.desc(t.wrongAt),
          ]))
        .watch();
  }

  /// 오답 수 변경 감지
  Stream<int> watchWrongCount() {
    return select(wrongAnswers).watch().map((list) => list.length);
  }
}
