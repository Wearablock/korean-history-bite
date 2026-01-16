// lib/data/providers/question_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/question.dart';
import '../repositories/question_repository.dart';
import 'chapter_providers.dart'; // currentLocaleProvider 사용

/// QuestionRepository 인스턴스 제공
final questionRepositoryProvider = Provider<QuestionRepository>((ref) {
  return QuestionRepository();
});

/// 전체 문제 목록 (현재 로케일 기준)
final questionsProvider = FutureProvider<List<Question>>((ref) async {
  final repository = ref.watch(questionRepositoryProvider);
  final locale = ref.watch(currentLocaleProvider);
  return repository.loadQuestions(locale);
});

/// 시대별 문제 목록
final questionsByEraProvider = FutureProvider.family<List<Question>, String>(
  (ref, eraId) async {
    final repository = ref.watch(questionRepositoryProvider);
    final locale = ref.watch(currentLocaleProvider);
    return repository.loadQuestionsByEra(eraId, locale);
  },
);

/// 시대별 메타데이터
final questionMetaByEraProvider =
    FutureProvider.family<List<QuestionMeta>, String>(
  (ref, eraId) async {
    final repository = ref.watch(questionRepositoryProvider);
    return repository.loadMetaByEra(eraId);
  },
);

/// 시대별 문제 수
final questionCountByEraProvider = FutureProvider.family<int, String>(
  (ref, eraId) async {
    final repository = ref.watch(questionRepositoryProvider);
    return repository.getQuestionCountByEra(eraId);
  },
);

/// 챕터별 문제 목록
final questionsByChapterProvider =
    FutureProvider.family<List<Question>, String>(
  (ref, chapterId) async {
    final repository = ref.watch(questionRepositoryProvider);
    final locale = ref.watch(currentLocaleProvider);
    return repository.getQuestionsByChapter(chapterId, locale);
  },
);

/// 특정 문제 조회
final questionByIdProvider = FutureProvider.family<Question?, String>(
  (ref, questionId) async {
    final repository = ref.watch(questionRepositoryProvider);
    final locale = ref.watch(currentLocaleProvider);
    return repository.getQuestionById(questionId, locale);
  },
);

/// 메타데이터만 (로케일 무관)
final questionMetaProvider = FutureProvider<List<QuestionMeta>>((ref) async {
  final repository = ref.watch(questionRepositoryProvider);
  return repository.loadMeta();
});

/// 전체 문제 수 (QuestionRepository 기준)
final questionCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(questionRepositoryProvider);
  return repository.getTotalQuestionCount();
});

/// 챕터별 문제 수
final questionCountByChapterProvider = FutureProvider.family<int, String>(
  (ref, chapterId) async {
    final repository = ref.watch(questionRepositoryProvider);
    return repository.getQuestionCountByChapter(chapterId);
  },
);

/// 난이도별 문제 목록
final questionsByDifficultyProvider =
    FutureProvider.family<List<Question>, int>(
  (ref, difficulty) async {
    final repository = ref.watch(questionRepositoryProvider);
    final locale = ref.watch(currentLocaleProvider);
    return repository.getQuestionsByDifficulty(difficulty, locale);
  },
);

/// 유형별 문제 목록
final questionsByTypeProvider =
    FutureProvider.family<List<Question>, QuestionType>(
  (ref, type) async {
    final repository = ref.watch(questionRepositoryProvider);
    final locale = ref.watch(currentLocaleProvider);
    return repository.getQuestionsByType(type, locale);
  },
);

/// 여러 문제 ID로 조회
final questionsByIdsProvider =
    FutureProvider.family<List<Question>, List<String>>(
  (ref, questionIds) async {
    final repository = ref.watch(questionRepositoryProvider);
    final locale = ref.watch(currentLocaleProvider);
    return repository.getQuestionsByIds(questionIds, locale);
  },
);
