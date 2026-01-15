// lib/data/repositories/image_repository.dart

import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/image_meta.dart';

class ImageRepository {
  // 캐시
  Map<String, ImageMeta>? _cachedImages;

  /// 이미지 메타데이터 로드
  Future<Map<String, ImageMeta>> loadImageMeta() async {
    if (_cachedImages != null) return _cachedImages!;

    final jsonString = await rootBundle.loadString(
      'assets/data/images_meta.json',
    );
    final jsonData = json.decode(jsonString) as Map<String, dynamic>;

    _cachedImages = {};
    jsonData.forEach((key, value) {
      _cachedImages![key] = ImageMeta.fromJson(
        key,
        value as Map<String, dynamic>,
      );
    });

    return _cachedImages!;
  }

  /// ID로 이미지 메타 조회
  Future<ImageMeta?> getImageById(String id) async {
    final images = await loadImageMeta();
    return images[id];
  }

  /// 여러 ID로 이미지 메타 목록 조회
  Future<List<ImageMeta>> getImagesByIds(List<String> ids) async {
    final images = await loadImageMeta();
    return ids
        .where((id) => images.containsKey(id))
        .map((id) => images[id]!)
        .toList();
  }

  /// 시대별 이미지 조회
  Future<List<ImageMeta>> getImagesByEra(String era) async {
    final images = await loadImageMeta();
    return images.values.where((img) => img.era == era).toList();
  }

  /// 카테고리별 이미지 조회
  Future<List<ImageMeta>> getImagesByCategory(String category) async {
    final images = await loadImageMeta();
    return images.values.where((img) => img.category == category).toList();
  }

  /// 캐시 초기화
  void clearCache() {
    _cachedImages = null;
  }
}
