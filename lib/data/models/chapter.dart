// lib/data/models/chapter.dart

/// 챕터 메타데이터 (구조 정보)
class ChapterMeta {
  final String id;
  final String eraId;
  final int order;
  final int questionCount;
  final List<String> images;

  const ChapterMeta({
    required this.id,
    required this.eraId,
    required this.order,
    required this.questionCount,
    this.images = const [],
  });

  factory ChapterMeta.fromJson(Map<String, dynamic> json) {
    return ChapterMeta(
      id: json['id'] as String,
      eraId: json['era_id'] as String,
      order: json['order'] as int,
      questionCount: json['question_count'] as int,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'era_id': eraId,
      'order': order,
      'question_count': questionCount,
      'images': images,
    };
  }

  @override
  String toString() {
    return 'ChapterMeta(id: $id, eraId: $eraId, order: $order)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChapterMeta && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 챕터 콘텐츠 (언어별 텍스트)
class ChapterContent {
  final String title;
  final String theory;

  const ChapterContent({
    required this.title,
    required this.theory,
  });

  factory ChapterContent.fromJson(Map<String, dynamic> json) {
    return ChapterContent(
      title: json['title'] as String,
      theory: json['theory'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'theory': theory,
    };
  }

  /// 빈 콘텐츠 (fallback용)
  static const empty = ChapterContent(title: '', theory: '');

  @override
  String toString() {
    return 'ChapterContent(title: $title)';
  }
}

/// 챕터 (메타 + 콘텐츠 통합, 런타임용)
class Chapter {
  final String id;
  final String eraId;
  final int order;
  final int questionCount;
  final String title;
  final String theory;
  final List<String> images;

  const Chapter({
    required this.id,
    required this.eraId,
    required this.order,
    required this.questionCount,
    required this.title,
    required this.theory,
    this.images = const [],
  });

  /// 메타데이터와 콘텐츠를 결합하여 생성
  factory Chapter.fromMetaAndContent(
    ChapterMeta meta,
    ChapterContent content,
  ) {
    return Chapter(
      id: meta.id,
      eraId: meta.eraId,
      order: meta.order,
      questionCount: meta.questionCount,
      title: content.title.isNotEmpty ? content.title : meta.id,
      theory: content.theory,
      images: meta.images,
    );
  }

  /// 콘텐츠 없이 메타만으로 생성 (fallback)
  factory Chapter.fromMetaOnly(ChapterMeta meta) {
    return Chapter(
      id: meta.id,
      eraId: meta.eraId,
      order: meta.order,
      questionCount: meta.questionCount,
      title: meta.id,
      theory: '',
      images: meta.images,
    );
  }

  /// ChapterMeta 추출 (저장/비교용)
  ChapterMeta get meta => ChapterMeta(
        id: id,
        eraId: eraId,
        order: order,
        questionCount: questionCount,
        images: images,
      );

  /// ChapterContent 추출
  ChapterContent get content => ChapterContent(
        title: title,
        theory: theory,
      );

  @override
  String toString() {
    return 'Chapter(id: $id, eraId: $eraId, order: $order, title: $title)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Chapter && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
