import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/era.dart';

class EraRepository {
  List<Era>? _cachedEras;

  /// JSON에서 시대 목록 로드
  Future<List<Era>> loadEras() async {
    // 캐시가 있으면 반환
    if (_cachedEras != null) {
      return _cachedEras!;
    }

    // JSON 파일 로드
    final jsonString = await rootBundle.loadString('assets/data/eras.json');
    final jsonData = json.decode(jsonString) as Map<String, dynamic>;
    final erasJson = jsonData['eras'] as List<dynamic>;

    // 파싱 및 캐싱
    _cachedEras =
        erasJson.map((e) => Era.fromJson(e as Map<String, dynamic>)).toList();

    // order 기준 정렬
    _cachedEras!.sort((a, b) => a.order.compareTo(b.order));

    return _cachedEras!;
  }

  /// ID로 시대 조회
  Future<Era?> getEraById(String id) async {
    final eras = await loadEras();
    try {
      return eras.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  /// 전체 시대 수
  Future<int> getEraCount() async {
    final eras = await loadEras();
    return eras.length;
  }

  /// 캐시 초기화 (필요 시)
  void clearCache() {
    _cachedEras = null;
  }
}
