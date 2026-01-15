// lib/data/models/image_meta.dart

/// 이미지 메타데이터 (JSON에서 로드)
class ImageMeta {
  final String id;
  final String category;
  final String path;
  final String era;
  final Map<String, String> captions;

  const ImageMeta({
    required this.id,
    required this.category,
    required this.path,
    required this.era,
    required this.captions,
  });

  factory ImageMeta.fromJson(String id, Map<String, dynamic> json) {
    final captionJson = json['caption'] as Map<String, dynamic>? ?? {};
    final captions = captionJson.map(
      (key, value) => MapEntry(key, value as String),
    );

    return ImageMeta(
      id: id,
      category: json['category'] as String? ?? '',
      path: json['path'] as String? ?? '',
      era: json['era'] as String? ?? '',
      captions: captions,
    );
  }

  /// 로케일에 맞는 캡션 반환 (fallback: locale → en → ko → id)
  String getCaption(String locale) {
    if (captions.containsKey(locale)) {
      return captions[locale]!;
    }
    if (captions.containsKey('en')) {
      return captions['en']!;
    }
    if (captions.containsKey('ko')) {
      return captions['ko']!;
    }
    return id;
  }

  /// 전체 이미지 경로 (assets 포함)
  String get fullPath => 'assets/images/$path';

  @override
  String toString() {
    return 'ImageMeta(id: $id, path: $path)';
  }
}
