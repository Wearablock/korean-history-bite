import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/chapter.dart';

class ChapterRepository {
  // 캐시
  List<ChapterMeta>? _cachedMeta;
  final Map<String, Map<String, ChapterContent>> _cachedContent = {};

  // 현재 로드된 로케일의 통합 챕터 목록
  List<Chapter>? _cachedChapters;
  String? _cachedLocale;

  /// 메타데이터 로드 (앱 시작 시 1회)
  Future<List<ChapterMeta>> loadMeta() async {
    if (_cachedMeta != null) return _cachedMeta!;

    final jsonString = await rootBundle.loadString(
      'assets/data/chapters/chapters_meta.json',
    );
    final jsonData = json.decode(jsonString) as Map<String, dynamic>;
    final chaptersJson = jsonData['chapters'] as List<dynamic>;

    _cachedMeta = chaptersJson
        .map((e) => ChapterMeta.fromJson(e as Map<String, dynamic>))
        .toList();

    // order 순 정렬
    _cachedMeta!.sort((a, b) {
      final eraCompare = a.eraId.compareTo(b.eraId);
      if (eraCompare != 0) return eraCompare;
      return a.order.compareTo(b.order);
    });

    return _cachedMeta!;
  }

  /// 콘텐츠 로드 (로케일별)
  Future<Map<String, ChapterContent>> loadContent(String locale) async {
    // 캐시 확인
    if (_cachedContent.containsKey(locale)) {
      return _cachedContent[locale]!;
    }

    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/chapters/chapters_$locale.json',
      );
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;

      final content = <String, ChapterContent>{};
      jsonData.forEach((key, value) {
        content[key] = ChapterContent.fromJson(value as Map<String, dynamic>);
      });

      _cachedContent[locale] = content;
      return content;
    } catch (e) {
      // 파일이 없으면 빈 맵 반환
      return {};
    }
  }

  /// 콘텐츠 로드 (fallback 적용: locale → en → ko)
  Future<Map<String, ChapterContent>> loadContentWithFallback(
    String locale,
  ) async {
    // 1. 요청된 로케일 시도
    var content = await loadContent(locale);
    if (content.isNotEmpty) return content;

    // 2. 영어 fallback
    if (locale != 'en') {
      content = await loadContent('en');
      if (content.isNotEmpty) return content;
    }

    // 3. 한국어 fallback
    if (locale != 'ko') {
      content = await loadContent('ko');
    }

    return content;
  }

  /// 챕터 목록 로드 (메타 + 콘텐츠 병합)
  Future<List<Chapter>> loadChapters(String locale) async {
    // 같은 로케일 캐시가 있으면 반환
    if (_cachedChapters != null && _cachedLocale == locale) {
      return _cachedChapters!;
    }

    final meta = await loadMeta();
    final content = await loadContentWithFallback(locale);

    _cachedChapters = meta.map((m) {
      final c = content[m.id] ?? ChapterContent.empty;
      return Chapter.fromMetaAndContent(m, c);
    }).toList();

    _cachedLocale = locale;
    return _cachedChapters!;
  }

  /// ID로 챕터 조회
  Future<Chapter?> getChapterById(String id, String locale) async {
    final chapters = await loadChapters(locale);
    try {
      return chapters.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// 시대별 챕터 목록 조회
  Future<List<Chapter>> getChaptersByEra(String eraId, String locale) async {
    final chapters = await loadChapters(locale);
    return chapters.where((c) => c.eraId == eraId).toList();
  }

  /// 전체 챕터 수 (메타만으로 가능)
  Future<int> getChapterCount() async {
    final meta = await loadMeta();
    return meta.length;
  }

  /// 시대별 챕터 수
  Future<int> getChapterCountByEra(String eraId) async {
    final meta = await loadMeta();
    return meta.where((m) => m.eraId == eraId).length;
  }

  /// 전체 문제 수
  Future<int> getTotalQuestionCount() async {
    final meta = await loadMeta();
    return meta.fold<int>(0, (sum, m) => sum + m.questionCount);
  }

  /// 시대별 문제 수
  Future<int> getTotalQuestionCountByEra(String eraId) async {
    final meta = await loadMeta();
    return meta
        .where((m) => m.eraId == eraId)
        .fold<int>(0, (sum, m) => sum + m.questionCount);
  }

  /// 메타데이터만 필요한 경우 (진행률 계산 등)
  Future<List<ChapterMeta>> getMetaByEra(String eraId) async {
    final meta = await loadMeta();
    return meta.where((m) => m.eraId == eraId).toList();
  }

  /// 캐시 초기화
  void clearCache() {
    _cachedMeta = null;
    _cachedContent.clear();
    _cachedChapters = null;
    _cachedLocale = null;
  }

  /// 콘텐츠 캐시만 초기화 (언어 변경 시)
  void clearContentCache() {
    _cachedContent.clear();
    _cachedChapters = null;
    _cachedLocale = null;
  }
}
