import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/chapter.dart';
import '../repositories/chapter_repository.dart';

/// ChapterRepository 인스턴스 제공
final chapterRepositoryProvider = Provider<ChapterRepository>((ref) {
  return ChapterRepository();
});

/// 현재 로케일 (settings에서 관리, 여기선 기본값)
final currentLocaleProvider = StateProvider<String>((ref) => 'ko');

/// 전체 챕터 목록 (현재 로케일 기준)
final chaptersProvider = FutureProvider<List<Chapter>>((ref) async {
  final repository = ref.watch(chapterRepositoryProvider);
  final locale = ref.watch(currentLocaleProvider);
  return repository.loadChapters(locale);
});

/// 시대별 챕터 목록
final chaptersByEraProvider = FutureProvider.family<List<Chapter>, String>(
  (ref, eraId) async {
    final repository = ref.watch(chapterRepositoryProvider);
    final locale = ref.watch(currentLocaleProvider);
    return repository.getChaptersByEra(eraId, locale);
  },
);

/// 특정 챕터
final chapterByIdProvider = FutureProvider.family<Chapter?, String>(
  (ref, chapterId) async {
    final repository = ref.watch(chapterRepositoryProvider);
    final locale = ref.watch(currentLocaleProvider);
    return repository.getChapterById(chapterId, locale);
  },
);

/// 메타데이터만 (진행률 등, 로케일 무관)
final chapterMetaProvider = FutureProvider<List<ChapterMeta>>((ref) async {
  final repository = ref.watch(chapterRepositoryProvider);
  return repository.loadMeta();
});

/// 전체 챕터 수
final chapterCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(chapterRepositoryProvider);
  return repository.getChapterCount();
});

/// 전체 문제 수
final totalQuestionCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(chapterRepositoryProvider);
  return repository.getTotalQuestionCount();
});

/// 시대별 챕터 수
final chapterCountByEraProvider = FutureProvider.family<int, String>(
  (ref, eraId) async {
    final repository = ref.watch(chapterRepositoryProvider);
    return repository.getChapterCountByEra(eraId);
  },
);

/// 시대별 문제 수
final questionCountByEraProvider = FutureProvider.family<int, String>(
  (ref, eraId) async {
    final repository = ref.watch(chapterRepositoryProvider);
    return repository.getTotalQuestionCountByEra(eraId);
  },
);
