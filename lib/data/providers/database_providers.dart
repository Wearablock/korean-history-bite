// lib/data/providers/database_providers.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import '../database/daos/study_records_dao.dart';
import '../database/daos/wrong_answers_dao.dart';
import '../database/daos/daily_stats_dao.dart';
import '../database/daos/user_settings_dao.dart';

// ============================================================
// 데이터베이스 & DAO Providers
// ============================================================

/// AppDatabase 싱글톤 인스턴스
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

/// StudyRecordsDao 제공
final studyRecordsDaoProvider = Provider<StudyRecordsDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.studyRecordsDao;
});

/// WrongAnswersDao 제공
final wrongAnswersDaoProvider = Provider<WrongAnswersDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.wrongAnswersDao;
});

/// DailyStatsDao 제공
final dailyStatsDaoProvider = Provider<DailyStatsDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.dailyStatsDao;
});

/// UserSettingsDao 제공
final userSettingsDaoProvider = Provider<UserSettingsDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.userSettingsDao;
});

// ============================================================
// 테마 설정 Provider
// ============================================================

/// 테마 모드 Provider (앱 전역에서 사용)
final themeModeProvider = FutureProvider<ThemeMode>((ref) async {
  final dao = ref.watch(userSettingsDaoProvider);
  final modeString = await dao.getThemeMode();

  switch (modeString) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
});

// ============================================================
// 일일 통계 Providers
// ============================================================

/// 오늘의 통계
final todayStatsProvider = FutureProvider((ref) async {
  final dao = ref.watch(dailyStatsDaoProvider);
  return dao.getToday();
});

/// 현재 스트릭 (연속 학습일)
final currentStreakProvider = FutureProvider<int>((ref) async {
  final dao = ref.watch(dailyStatsDaoProvider);
  return dao.getCurrentStreak();
});

/// 최장 스트릭
final longestStreakProvider = FutureProvider<int>((ref) async {
  final dao = ref.watch(dailyStatsDaoProvider);
  return dao.getLongestStreak();
});

/// 최근 N일 통계
final recentStatsProvider = FutureProvider.family<List<DailyStat>, int>(
  (ref, days) async {
    final dao = ref.watch(dailyStatsDaoProvider);
    return dao.getRecentStats(days);
  },
);

/// 이번 주 통계
final thisWeekStatsProvider = FutureProvider((ref) async {
  final dao = ref.watch(dailyStatsDaoProvider);
  return dao.getThisWeekStats();
});

/// 이번 달 통계
final thisMonthStatsProvider = FutureProvider((ref) async {
  final dao = ref.watch(dailyStatsDaoProvider);
  return dao.getThisMonthStats();
});

// ============================================================
// 학습 기록 Providers
// ============================================================

/// 완전 습득 문제 (레벨 5)
final masteredQuestionsProvider = FutureProvider((ref) async {
  final dao = ref.watch(studyRecordsDaoProvider);
  return dao.getMasteredQuestions();
});

/// 완전 습득 문제 수
final masteredCountProvider = FutureProvider<int>((ref) async {
  final mastered = await ref.watch(masteredQuestionsProvider.future);
  return mastered.length;
});

/// 챕터별 학습 기록
final studyRecordsByChapterProvider =
    FutureProvider.family<List<StudyRecord>, String>(
  (ref, chapterId) async {
    final dao = ref.watch(studyRecordsDaoProvider);
    return dao.getByChapterId(chapterId);
  },
);

/// 시대별 학습 기록
final studyRecordsByEraProvider =
    FutureProvider.family<List<StudyRecord>, String>(
  (ref, eraId) async {
    final dao = ref.watch(studyRecordsDaoProvider);
    return dao.getByEraId(eraId);
  },
);

// ============================================================
// 오답 Providers
// ============================================================

/// 미해결 오답 목록
final uncorrectedWrongAnswersProvider = FutureProvider((ref) async {
  final dao = ref.watch(wrongAnswersDaoProvider);
  return dao.getUncorrectedWrongAnswers();
});

/// 미해결 오답 문제 ID 목록
final uncorrectedWrongAnswerIdsProvider =
    FutureProvider<List<String>>((ref) async {
  final wrongAnswers = await ref.watch(uncorrectedWrongAnswersProvider.future);
  return wrongAnswers.map((w) => w.questionId).toList();
});

/// 미해결 오답 수
final uncorrectedCountProvider = FutureProvider<int>((ref) async {
  final dao = ref.watch(wrongAnswersDaoProvider);
  return dao.getUncorrectedCount();
});

/// 최근 틀린 문제
final recentWrongAnswersProvider = FutureProvider((ref) async {
  final dao = ref.watch(wrongAnswersDaoProvider);
  return dao.getRecentWrongAnswers();
});

/// 가장 많이 틀린 문제
final mostWrongAnswersProvider = FutureProvider((ref) async {
  final dao = ref.watch(wrongAnswersDaoProvider);
  return dao.getMostWrongAnswers();
});

/// 챕터별 오답
final wrongAnswersByChapterProvider =
    FutureProvider.family<List<WrongAnswer>, String>(
  (ref, chapterId) async {
    final dao = ref.watch(wrongAnswersDaoProvider);
    return dao.getByChapterId(chapterId);
  },
);

/// 시대별 오답
final wrongAnswersByEraProvider =
    FutureProvider.family<List<WrongAnswer>, String>(
  (ref, eraId) async {
    final dao = ref.watch(wrongAnswersDaoProvider);
    return dao.getByEraId(eraId);
  },
);
