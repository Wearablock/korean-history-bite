// lib/data/repositories/question_repository.dart

import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/question.dart';

class QuestionRepository {
  // 캐시
  List<QuestionMeta>? _metaCache;
  final Map<String, Map<String, QuestionContent>> _contentCache = {};

  // 시대 순서 매핑 (eras.json 기준)
  static const _eraOrder = {
    'prehistoric': 1,
    'gojoseon': 2,
    'three_kingdoms': 3,
    'north_south_states': 4,
    'goryeo': 5,
    'joseon_early': 6,
    'joseon_late': 7,
    'modern': 8,
    'japanese_occupation': 9,
    'contemporary': 10,
  };

  /// chapterId에서 시대 ID 추출 (ch_prehistoric_01 → prehistoric)
  static String _extractEraFromChapterId(String chapterId) {
    // ch_ 제거 후 마지막 _숫자 부분 제거
    final withoutPrefix = chapterId.replaceFirst('ch_', '');
    final lastUnderscoreIndex = withoutPrefix.lastIndexOf('_');
    if (lastUnderscoreIndex > 0) {
      return withoutPrefix.substring(0, lastUnderscoreIndex);
    }
    return withoutPrefix;
  }

  /// 메타데이터 로드 (questions_meta.json)
  Future<List<QuestionMeta>> loadMeta() async {
    if (_metaCache != null) return _metaCache!;

    final jsonString = await rootBundle.loadString(
      'assets/data/questions/questions_meta.json',
    );
    final jsonData = json.decode(jsonString) as Map<String, dynamic>;
    final questionsList = jsonData['questions'] as List<dynamic>;

    _metaCache = questionsList
        .map((q) => QuestionMeta.fromJson(q as Map<String, dynamic>))
        .toList();

    // 시대 순서 → 챕터 순서 → 문제 순서로 정렬
    _metaCache!.sort((a, b) {
      final eraA = _extractEraFromChapterId(a.chapterId);
      final eraB = _extractEraFromChapterId(b.chapterId);
      final eraOrderA = _eraOrder[eraA] ?? 99;
      final eraOrderB = _eraOrder[eraB] ?? 99;

      if (eraOrderA != eraOrderB) return eraOrderA.compareTo(eraOrderB);

      final chapterCompare = a.chapterId.compareTo(b.chapterId);
      if (chapterCompare != 0) return chapterCompare;

      return a.order.compareTo(b.order);
    });

    return _metaCache!;
  }

  /// 콘텐츠 로드 (questions_[locale].json)
  Future<Map<String, QuestionContent>> loadContent(String locale) async {
    if (_contentCache.containsKey(locale)) {
      return _contentCache[locale]!;
    }

    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/questions/questions_$locale.json',
      );
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;

      final contentMap = <String, QuestionContent>{};
      jsonData.forEach((key, value) {
        contentMap[key] =
            QuestionContent.fromJson(value as Map<String, dynamic>);
      });

      _contentCache[locale] = contentMap;
      return contentMap;
    } catch (e) {
      // 파일이 없는 경우 빈 맵 반환
      return {};
    }
  }

  /// 콘텐츠 로드 (fallback 포함: locale -> en -> ko)
  Future<Map<String, QuestionContent>> loadContentWithFallback(
    String locale,
  ) async {
    // 요청된 로케일 시도
    var content = await loadContent(locale);
    if (content.isNotEmpty) return content;

    // 영어 fallback
    if (locale != 'en') {
      content = await loadContent('en');
      if (content.isNotEmpty) return content;
    }

    // 한국어 fallback
    if (locale != 'ko') {
      content = await loadContent('ko');
    }

    return content;
  }

  /// 전체 문제 로드 (메타 + 콘텐츠 결합)
  Future<List<Question>> loadQuestions(String locale) async {
    final metaList = await loadMeta();
    final contentMap = await loadContentWithFallback(locale);

    return metaList.map((meta) {
      final content = contentMap[meta.id];
      if (content != null) {
        return Question.fromMetaAndContent(meta, content);
      } else {
        return Question.fromMetaOnly(meta);
      }
    }).toList();
  }

  /// 특정 문제 ID로 조회
  Future<Question?> getQuestionById(String questionId, String locale) async {
    final questions = await loadQuestions(locale);
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
    final questions = await loadQuestions(locale);
    return questions.where((q) => q.chapterId == chapterId).toList();
  }

  /// 챕터별 문제 ID 목록 조회 (메타만 사용)
  Future<List<String>> getQuestionIdsByChapter(String chapterId) async {
    final metaList = await loadMeta();
    return metaList
        .where((m) => m.chapterId == chapterId)
        .map((m) => m.id)
        .toList();
  }

  /// 여러 문제 ID로 조회
  Future<List<Question>> getQuestionsByIds(
    List<String> questionIds,
    String locale,
  ) async {
    final questions = await loadQuestions(locale);
    final idSet = questionIds.toSet();
    return questions.where((q) => idSet.contains(q.id)).toList();
  }

  /// 전체 문제 수
  Future<int> getTotalQuestionCount() async {
    final metaList = await loadMeta();
    return metaList.length;
  }

  /// 챕터별 문제 수
  Future<int> getQuestionCountByChapter(String chapterId) async {
    final metaList = await loadMeta();
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

  /// 캐시 클리어
  void clearCache() {
    _metaCache = null;
    _contentCache.clear();
  }
}
