// lib/data/providers/image_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/image_meta.dart';
import '../repositories/image_repository.dart';

/// ImageRepository 인스턴스 제공
final imageRepositoryProvider = Provider<ImageRepository>((ref) {
  return ImageRepository();
});

/// 전체 이미지 메타 맵
final imageMetaMapProvider = FutureProvider<Map<String, ImageMeta>>((ref) async {
  final repository = ref.watch(imageRepositoryProvider);
  return repository.loadImageMeta();
});

/// ID로 이미지 조회
final imageByIdProvider = FutureProvider.family<ImageMeta?, String>(
  (ref, imageId) async {
    final repository = ref.watch(imageRepositoryProvider);
    return repository.getImageById(imageId);
  },
);

/// 여러 ID로 이미지 목록 조회
final imagesByIdsProvider = FutureProvider.family<List<ImageMeta>, List<String>>(
  (ref, imageIds) async {
    final repository = ref.watch(imageRepositoryProvider);
    return repository.getImagesByIds(imageIds);
  },
);

/// 시대별 이미지 조회
final imagesByEraProvider = FutureProvider.family<List<ImageMeta>, String>(
  (ref, era) async {
    final repository = ref.watch(imageRepositoryProvider);
    return repository.getImagesByEra(era);
  },
);

/// 카테고리별 이미지 조회
final imagesByCategoryProvider = FutureProvider.family<List<ImageMeta>, String>(
  (ref, category) async {
    final repository = ref.watch(imageRepositoryProvider);
    return repository.getImagesByCategory(category);
  },
);
