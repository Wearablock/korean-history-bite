import 'package:drift/drift.dart';
import '../../../core/utils/debug_utils.dart';
import '../app_database.dart';
import '../tables/daily_stats.dart';

part 'daily_stats_dao.g.dart';

@DriftAccessor(tables: [DailyStats])
class DailyStatsDao extends DatabaseAccessor<AppDatabase>
    with _$DailyStatsDaoMixin {
  DailyStatsDao(super.db);

  // ============================================================
  // 기본 CRUD 연산
  // ============================================================

  /// 모든 통계 조회
  Future<List<DailyStat>> getAllStats() => select(dailyStats).get();

  /// 특정 날짜 통계 조회
  Future<DailyStat?> getByDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return (select(dailyStats)..where((t) => t.date.equals(dateOnly)))
        .getSingleOrNull();
  }

  /// 오늘 통계 조회
  Future<DailyStat?> getToday() {
    return getByDate(DebugUtils.now);
  }

  /// 통계 생성 또는 업데이트 (Upsert)
  Future<void> upsertStat(DailyStatsCompanion stat) {
    return into(dailyStats).insertOnConflictUpdate(stat);
  }

  /// 통계 삭제
  Future<int> deleteByDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return (delete(dailyStats)..where((t) => t.date.equals(dateOnly))).go();
  }

  /// 모든 통계 삭제 (초기화)
  Future<int> deleteAll() => delete(dailyStats).go();

  // ============================================================
  // 오늘 통계 관리
  // ============================================================

  /// 오늘 통계 가져오기 (없으면 생성)
  Future<DailyStat> getOrCreateToday({int dailyGoal = 15}) async {
    final today = DebugUtils.now;
    final dateOnly = DateTime(today.year, today.month, today.day);

    var stat = await getByDate(dateOnly);
    if (stat == null) {
      await upsertStat(DailyStatsCompanion.insert(
        date: dateOnly,
        dailyGoal: Value(dailyGoal),
      ));
      stat = await getByDate(dateOnly);
    }
    return stat!;
  }

  /// 문제 풀이 기록 (정답)
  Future<void> recordCorrectAnswer({bool isNewQuestion = false}) async {
    final stat = await getOrCreateToday();
    await upsertStat(DailyStatsCompanion(
      id: Value(stat.id),
      date: Value(stat.date),
      questionsStudied: Value(stat.questionsStudied + 1),
      correctAnswers: Value(stat.correctAnswers + 1),
      newQuestions: Value(stat.newQuestions + (isNewQuestion ? 1 : 0)),
      reviewQuestions: Value(stat.reviewQuestions + (isNewQuestion ? 0 : 1)),
      goalAchieved: Value(stat.questionsStudied + 1 >= stat.dailyGoal),
      updatedAt: Value(DebugUtils.now),
    ));
  }

  /// 문제 풀이 기록 (오답)
  Future<void> recordWrongAnswer({bool isNewQuestion = false}) async {
    final stat = await getOrCreateToday();
    await upsertStat(DailyStatsCompanion(
      id: Value(stat.id),
      date: Value(stat.date),
      questionsStudied: Value(stat.questionsStudied + 1),
      newQuestions: Value(stat.newQuestions + (isNewQuestion ? 1 : 0)),
      reviewQuestions: Value(stat.reviewQuestions + (isNewQuestion ? 0 : 1)),
      goalAchieved: Value(stat.questionsStudied + 1 >= stat.dailyGoal),
      updatedAt: Value(DebugUtils.now),
    ));
  }

  /// 학습 시간 추가
  Future<void> addStudyTime(int seconds) async {
    final stat = await getOrCreateToday();
    await upsertStat(DailyStatsCompanion(
      id: Value(stat.id),
      date: Value(stat.date),
      studyTimeSec: Value(stat.studyTimeSec + seconds),
      updatedAt: Value(DebugUtils.now),
    ));
  }

  // ============================================================
  // 기간별 조회
  // ============================================================

  /// 최근 N일 통계 조회
  Future<List<DailyStat>> getRecentStats(int days) {
    final startDate = DebugUtils.now.subtract(Duration(days: days));
    return (select(dailyStats)
          ..where((t) => t.date.isBiggerOrEqualValue(startDate))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  /// 이번 주 통계 조회
  Future<List<DailyStat>> getThisWeekStats() {
    final now = DebugUtils.now;
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startDate =
        DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

    return (select(dailyStats)
          ..where((t) => t.date.isBiggerOrEqualValue(startDate))
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .get();
  }

  /// 이번 달 통계 조회
  Future<List<DailyStat>> getThisMonthStats() {
    final now = DebugUtils.now;
    final startDate = DateTime(now.year, now.month, 1);

    return (select(dailyStats)
          ..where((t) => t.date.isBiggerOrEqualValue(startDate))
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .get();
  }

  /// 특정 기간 통계 조회
  Future<List<DailyStat>> getStatsBetween(DateTime start, DateTime end) {
    return (select(dailyStats)
          ..where((t) =>
              t.date.isBiggerOrEqualValue(start) &
              t.date.isSmallerOrEqualValue(end))
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .get();
  }

  // ============================================================
  // 스트릭 계산
  // ============================================================

  /// 현재 스트릭 계산
  Future<int> getCurrentStreak() async {
    final stats = await (select(dailyStats)
          ..where((t) => t.goalAchieved.equals(true))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();

    if (stats.isEmpty) return 0;

    int streak = 0;
    DateTime? expectedDate = DebugUtils.now;
    expectedDate =
        DateTime(expectedDate.year, expectedDate.month, expectedDate.day);

    for (final stat in stats) {
      final statDate =
          DateTime(stat.date.year, stat.date.month, stat.date.day);

      // 오늘 또는 어제부터 연속인지 확인
      if (streak == 0) {
        final diff = expectedDate!.difference(statDate).inDays;
        if (diff > 1) return 0; // 오늘/어제가 아니면 스트릭 없음
        if (diff == 1) {
          expectedDate = expectedDate.subtract(const Duration(days: 1));
        }
      }

      if (statDate == expectedDate) {
        streak++;
        expectedDate = expectedDate!.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  /// 최장 스트릭 계산
  Future<int> getLongestStreak() async {
    final stats = await (select(dailyStats)
          ..where((t) => t.goalAchieved.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .get();

    if (stats.isEmpty) return 0;

    int longestStreak = 1;
    int currentStreak = 1;
    DateTime? prevDate;

    for (final stat in stats) {
      final statDate =
          DateTime(stat.date.year, stat.date.month, stat.date.day);

      if (prevDate != null) {
        final diff = statDate.difference(prevDate).inDays;
        if (diff == 1) {
          currentStreak++;
          longestStreak =
              currentStreak > longestStreak ? currentStreak : longestStreak;
        } else {
          currentStreak = 1;
        }
      }
      prevDate = statDate;
    }

    return longestStreak;
  }

  // ============================================================
  // 통계 집계
  // ============================================================

  /// 전체 통계 요약
  Future<Map<String, dynamic>> getOverallSummary() async {
    final stats = await getAllStats();

    if (stats.isEmpty) {
      return {
        'totalDays': 0,
        'totalQuestions': 0,
        'totalCorrect': 0,
        'totalStudyTime': 0,
        'averageAccuracy': 0.0,
        'currentStreak': 0,
        'longestStreak': 0,
      };
    }

    int totalQuestions = 0;
    int totalCorrect = 0;
    int totalStudyTime = 0;

    for (final stat in stats) {
      totalQuestions += stat.questionsStudied;
      totalCorrect += stat.correctAnswers;
      totalStudyTime += stat.studyTimeSec;
    }

    return {
      'totalDays': stats.length,
      'totalQuestions': totalQuestions,
      'totalCorrect': totalCorrect,
      'totalStudyTime': totalStudyTime,
      'averageAccuracy':
          totalQuestions > 0 ? totalCorrect / totalQuestions : 0.0,
      'currentStreak': await getCurrentStreak(),
      'longestStreak': await getLongestStreak(),
    };
  }

  /// 주간 통계 요약
  Future<Map<String, dynamic>> getWeeklySummary() async {
    final stats = await getThisWeekStats();

    int totalQuestions = 0;
    int totalCorrect = 0;
    int daysStudied = 0;

    for (final stat in stats) {
      if (stat.questionsStudied > 0) daysStudied++;
      totalQuestions += stat.questionsStudied;
      totalCorrect += stat.correctAnswers;
    }

    return {
      'daysStudied': daysStudied,
      'totalQuestions': totalQuestions,
      'totalCorrect': totalCorrect,
      'averageAccuracy':
          totalQuestions > 0 ? totalCorrect / totalQuestions : 0.0,
      'averagePerDay': daysStudied > 0 ? totalQuestions / daysStudied : 0.0,
    };
  }

  /// 오늘 목표 달성률
  Future<double> getTodayProgress() async {
    final stat = await getToday();
    if (stat == null || stat.dailyGoal == 0) return 0.0;
    return stat.questionsStudied / stat.dailyGoal;
  }

  // ============================================================
  // Stream (실시간 감지)
  // ============================================================

  /// 오늘 통계 변경 감지
  Stream<DailyStat?> watchToday() {
    final today = DebugUtils.now;
    final dateOnly = DateTime(today.year, today.month, today.day);
    return (select(dailyStats)..where((t) => t.date.equals(dateOnly)))
        .watchSingleOrNull();
  }

  /// 최근 통계 변경 감지
  Stream<List<DailyStat>> watchRecentStats(int days) {
    final startDate = DebugUtils.now.subtract(Duration(days: days));
    return (select(dailyStats)
          ..where((t) => t.date.isBiggerOrEqualValue(startDate))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }
}
