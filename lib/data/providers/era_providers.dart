// lib/data/providers/era_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/era.dart';
import '../repositories/era_repository.dart';

/// EraRepository 인스턴스 제공
final eraRepositoryProvider = Provider<EraRepository>((ref) {
  return EraRepository();
});

/// 전체 시대 목록
final erasProvider = FutureProvider<List<Era>>((ref) async {
  final repository = ref.watch(eraRepositoryProvider);
  return repository.loadEras();
});

/// 특정 시대 조회
final eraByIdProvider = FutureProvider.family<Era?, String>(
  (ref, eraId) async {
    final repository = ref.watch(eraRepositoryProvider);
    return repository.getEraById(eraId);
  },
);

/// 전체 시대 수
final eraCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(eraRepositoryProvider);
  return repository.getEraCount();
});
