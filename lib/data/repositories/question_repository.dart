// lib/data/repositories/question_repository.dart

import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/question.dart';

/// 시대 ID 상수
class EraIds {
  EraIds._();

  static const prehistoric = 'prehistoric';
  static const gojoseon = 'gojoseon';
  static const threeKingdoms = 'three_kingdoms';
  static const northSouthStates = 'north_south_states';
  static const goryeo = 'goryeo';
  static const joseonEarly = 'joseon_early';
  static const joseonLate = 'joseon_late';
  static const modern = 'modern';
  static const japaneseOccupation = 'japanese_occupation';
  static const contemporary = 'contemporary';

  static const List<String> all = [
    prehistoric,
    gojoseon,
    threeKingdoms,
    northSouthStates,
    goryeo,
    joseonEarly,
    joseonLate,
    modern,
    japaneseOccupation,
    contemporary,
  ];

  /// 시대 순서 (1부터 시작)
  static const Map<String, int> order = {
    prehistoric: 1,
    gojoseon: 2,
    threeKingdoms: 3,
    northSouthStates: 4,
    goryeo: 5,
    joseonEarly: 6,
    joseonLate: 7,
    modern: 8,
    japaneseOccupation: 9,
    contemporary: 10,
  };
}

class QuestionRepository {
  // 시대별 메타데이터 캐시
  final Map<String, List<QuestionMeta>> _metaCache = {};
  // 전체 메타데이터 캐시 (정렬됨)
  List<QuestionMeta>? _allMetaCache;
  // 시대별 콘텐츠 캐시: {locale: {eraId: {questionId: content}}}
  final Map<String, Map<String, Map<String, QuestionContent>>> _contentCache =
      {};

  /// chapterId에서 시대 ID 추출 (ch_prehistoric_01 → prehistoric)
  static String extractEraFromChapterId(String chapterId) {
    final withoutPrefix = chapterId.replaceFirst('ch_', '');
    final lastUnderscoreIndex = withoutPrefix.lastIndexOf('_');
    if (lastUnderscoreIndex > 0) {
      return withoutPrefix.substring(0, lastUnderscoreIndex);
    }
    return withoutPrefix;
  }

  /// questionId에서 시대 ID 추출 (q_prehistoric_01_001 → prehistoric)
  static String extractEraFromQuestionId(String questionId) {
    final withoutPrefix = questionId.replaceFirst('q_', '');
    final parts = withoutPrefix.split('_');
    if (parts.length >= 3) {
      return parts.sublist(0, parts.length - 2).join('_');
    }
    return withoutPrefix;
  }

  // ============================================================
  // 시대별 메타데이터 로딩
  // ============================================================

  /// 특정 시대의 메타데이터 로드
  Future<List<QuestionMeta>> loadMetaByEra(String eraId) async {
    if (_metaCache.containsKey(eraId)) {
      return _metaCache[eraId]!;
    }

    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/questions/meta/$eraId.json',
      );
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      final questionsList = jsonData['questions'] as List<dynamic>;

      final metaList = questionsList
          .map((q) => QuestionMeta.fromJson(q as Map<String, dynamic>))
          .toList();

      // 챕터 순서 → 문제 순서로 정렬
      metaList.sort((a, b) {
        final chapterCompare = a.chapterId.compareTo(b.chapterId);
        if (chapterCompare != 0) return chapterCompare;
        return a.order.compareTo(b.order);
      });

      _metaCache[eraId] = metaList;
      return metaList;
    } catch (e) {
      // 파일이 없는 경우 빈 리스트 반환
      return [];
    }
  }

  /// 전체 메타데이터 로드 (모든 시대) - 병렬 로딩
  Future<List<QuestionMeta>> loadMeta() async {
    if (_allMetaCache != null) return _allMetaCache!;

    // 병렬로 모든 시대 메타데이터 로드
    final futures = EraIds.all.map((eraId) => loadMetaByEra(eraId));
    final results = await Future.wait(futures);

    // 시대 순서대로 병합
    final allMeta = <QuestionMeta>[];
    for (final eraMeta in results) {
      allMeta.addAll(eraMeta);
    }

    _allMetaCache = allMeta;
    return _allMetaCache!;
  }

  // ============================================================
  // 시대별 콘텐츠 로딩
  // ============================================================

  /// 특정 시대의 콘텐츠 로드
  Future<Map<String, QuestionContent>> loadContentByEra(
    String eraId,
    String locale,
  ) async {
    _contentCache.putIfAbsent(locale, () => {});

    if (_contentCache[locale]!.containsKey(eraId)) {
      return _contentCache[locale]![eraId]!;
    }

    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/questions/$locale/$eraId.json',
      );
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;

      final contentMap = <String, QuestionContent>{};
      jsonData.forEach((key, value) {
        contentMap[key] =
            QuestionContent.fromJson(value as Map<String, dynamic>);
      });

      _contentCache[locale]![eraId] = contentMap;
      return contentMap;
    } catch (e) {
      // 파일이 없는 경우 빈 맵 반환
      return {};
    }
  }

  /// 특정 시대의 콘텐츠 로드 (fallback 포함)
  Future<Map<String, QuestionContent>> loadContentByEraWithFallback(
    String eraId,
    String locale,
  ) async {
    var content = await loadContentByEra(eraId, locale);
    if (content.isNotEmpty) return content;

    if (locale != 'en') {
      content = await loadContentByEra(eraId, 'en');
      if (content.isNotEmpty) return content;
    }

    if (locale != 'ko') {
      content = await loadContentByEra(eraId, 'ko');
    }

    return content;
  }

  /// 전체 콘텐츠 로드 (모든 시대) - 병렬 로딩
  Future<Map<String, QuestionContent>> loadContent(String locale) async {
    // 병렬로 모든 시대 콘텐츠 로드
    final futures = EraIds.all.map(
      (eraId) => loadContentByEraWithFallback(eraId, locale),
    );
    final results = await Future.wait(futures);

    final allContent = <String, QuestionContent>{};
    for (final eraContent in results) {
      allContent.addAll(eraContent);
    }

    return allContent;
  }

  // ============================================================
  // 문제 로딩 (메타 + 콘텐츠 결합)
  // ============================================================

  /// 특정 시대의 문제 로드
  Future<List<Question>> loadQuestionsByEra(String eraId, String locale) async {
    final metaList = await loadMetaByEra(eraId);
    final contentMap = await loadContentByEraWithFallback(eraId, locale);

    return metaList.map((meta) {
      final content = contentMap[meta.id];
      if (content != null) {
        return Question.fromMetaAndContent(meta, content);
      } else {
        return Question.fromMetaOnly(meta);
      }
    }).toList();
  }

  /// 전체 문제 로드 (모든 시대) - 병렬 로딩
  Future<List<Question>> loadQuestions(String locale) async {
    // 병렬로 모든 시대 문제 로드
    final futures = EraIds.all.map(
      (eraId) => loadQuestionsByEra(eraId, locale),
    );
    final results = await Future.wait(futures);

    final allQuestions = <Question>[];
    for (final eraQuestions in results) {
      allQuestions.addAll(eraQuestions);
    }

    return allQuestions;
  }

  // ============================================================
  // 조회 메서드
  // ============================================================

  /// 특정 문제 ID로 조회
  Future<Question?> getQuestionById(String questionId, String locale) async {
    final eraId = extractEraFromQuestionId(questionId);
    final questions = await loadQuestionsByEra(eraId, locale);

    try {
      return questions.firstWhere((q) => q.id == questionId);
    } catch (e) {
      return null;
    }
  }

  /// 챕터별 문제 조회
  Future<List<Question>> getQuestionsByChapter(
    String chapterId,
    String locale,
  ) async {
    final eraId = extractEraFromChapterId(chapterId);
    final questions = await loadQuestionsByEra(eraId, locale);
    return questions.where((q) => q.chapterId == chapterId).toList();
  }

  /// 챕터별 문제 ID 목록 조회 (메타만 사용)
  Future<List<String>> getQuestionIdsByChapter(String chapterId) async {
    final eraId = extractEraFromChapterId(chapterId);
    final metaList = await loadMetaByEra(eraId);
    return metaList
        .where((m) => m.chapterId == chapterId)
        .map((m) => m.id)
        .toList();
  }

  /// 여러 문제 ID로 조회 - 병렬 로딩
  Future<List<Question>> getQuestionsByIds(
    List<String> questionIds,
    String locale,
  ) async {
    if (questionIds.isEmpty) return [];

    // 시대별로 그룹화하여 효율적으로 로딩
    final idsByEra = <String, Set<String>>{};
    for (final id in questionIds) {
      final eraId = extractEraFromQuestionId(id);
      idsByEra.putIfAbsent(eraId, () => {}).add(id);
    }

    // 병렬로 시대별 문제 로드
    final futures = idsByEra.entries.map((entry) async {
      final questions = await loadQuestionsByEra(entry.key, locale);
      return questions.where((q) => entry.value.contains(q.id)).toList();
    });
    final results = await Future.wait(futures);

    final result = <Question>[];
    for (final questions in results) {
      result.addAll(questions);
    }

    // 원래 순서 유지
    final idOrder = {for (int i = 0; i < questionIds.length; i++) questionIds[i]: i};
    result.sort((a, b) => (idOrder[a.id] ?? 0).compareTo(idOrder[b.id] ?? 0));

    return result;
  }

  // ============================================================
  // 통계 메서드
  // ============================================================

  /// 전체 문제 수
  Future<int> getTotalQuestionCount() async {
    final metaList = await loadMeta();
    return metaList.length;
  }

  /// 시대별 문제 수
  Future<int> getQuestionCountByEra(String eraId) async {
    final metaList = await loadMetaByEra(eraId);
    return metaList.length;
  }

  /// 챕터별 문제 수
  Future<int> getQuestionCountByChapter(String chapterId) async {
    final eraId = extractEraFromChapterId(chapterId);
    final metaList = await loadMetaByEra(eraId);
    return metaList.where((m) => m.chapterId == chapterId).length;
  }

  /// 난이도별 문제 조회
  Future<List<Question>> getQuestionsByDifficulty(
    int difficulty,
    String locale,
  ) async {
    final questions = await loadQuestions(locale);
    return questions.where((q) => q.difficulty == difficulty).toList();
  }

  /// 유형별 문제 조회
  Future<List<Question>> getQuestionsByType(
    QuestionType type,
    String locale,
  ) async {
    final questions = await loadQuestions(locale);
    return questions.where((q) => q.type == type).toList();
  }

  // ============================================================
  // 캐시 관리
  // ============================================================

  /// 전체 캐시 클리어
  void clearCache() {
    _metaCache.clear();
    _allMetaCache = null;
    _contentCache.clear();
  }

  /// 특정 로케일의 콘텐츠 캐시만 클리어
  void clearContentCache(String? locale) {
    if (locale != null) {
      _contentCache.remove(locale);
    } else {
      _contentCache.clear();
    }
  }

  /// 특정 시대의 캐시 클리어
  void clearEraCache(String eraId) {
    _metaCache.remove(eraId);
    _allMetaCache = null;
    for (final localeCache in _contentCache.values) {
      localeCache.remove(eraId);
    }
  }
}
