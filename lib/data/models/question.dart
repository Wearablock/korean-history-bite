// lib/data/models/question.dart

/// 문제 유형
enum QuestionType {
  text,   // 일반 텍스트 문제
  image,  // 이미지 기반 문제
  source, // 사료 기반 문제
}

/// 문제 메타데이터 (구조 정보)
class QuestionMeta {
  final String id;
  final String chapterId;
  final int order;
  final int difficulty;    // 1: 쉬움, 2: 보통, 3: 어려움
  final QuestionType type;
  final String? imageId;   // 이미지형 문제의 경우

  const QuestionMeta({
    required this.id,
    required this.chapterId,
    required this.order,
    required this.difficulty,
    required this.type,
    this.imageId,
  });

  factory QuestionMeta.fromJson(Map<String, dynamic> json) {
    return QuestionMeta(
      id: json['id'] as String,
      chapterId: json['chapter_id'] as String,
      order: json['order'] as int,
      difficulty: json['difficulty'] as int,
      type: QuestionType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => QuestionType.text,
      ),
      imageId: json['image_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chapter_id': chapterId,
      'order': order,
      'difficulty': difficulty,
      'type': type.name,
      'image_id': imageId,
    };
  }

  @override
  String toString() {
    return 'QuestionMeta(id: $id, chapterId: $chapterId, order: $order)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuestionMeta && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 문제 콘텐츠 (언어별 텍스트)
class QuestionContent {
  final String question;
  final String correct;
  final List<String> wrong;  // 4개의 오답
  final String explanation;
  final String? source;      // 사료형 문제의 경우

  const QuestionContent({
    required this.question,
    required this.correct,
    required this.wrong,
    required this.explanation,
    this.source,
  });

  factory QuestionContent.fromJson(Map<String, dynamic> json) {
    return QuestionContent(
      question: json['question'] as String,
      correct: json['correct'] as String,
      wrong: List<String>.from(json['wrong'] as List),
      explanation: json['explanation'] as String,
      source: json['source'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'correct': correct,
      'wrong': wrong,
      'explanation': explanation,
      if (source != null) 'source': source,
    };
  }

  /// 빈 콘텐츠 (fallback용)
  static const empty = QuestionContent(
    question: '',
    correct: '',
    wrong: [],
    explanation: '',
  );

  @override
  String toString() {
    return 'QuestionContent(question: ${question.substring(0, question.length > 30 ? 30 : question.length)}...)';
  }
}

/// 문제 (메타 + 콘텐츠 통합, 런타임용)
class Question {
  final String id;
  final String chapterId;
  final int order;
  final int difficulty;
  final QuestionType type;
  final String? imageId;
  final String question;
  final String correct;
  final List<String> wrong;
  final String explanation;
  final String? source;

  const Question({
    required this.id,
    required this.chapterId,
    required this.order,
    required this.difficulty,
    required this.type,
    this.imageId,
    required this.question,
    required this.correct,
    required this.wrong,
    required this.explanation,
    this.source,
  });

  /// 메타데이터와 콘텐츠를 결합하여 생성
  factory Question.fromMetaAndContent(
    QuestionMeta meta,
    QuestionContent content,
  ) {
    return Question(
      id: meta.id,
      chapterId: meta.chapterId,
      order: meta.order,
      difficulty: meta.difficulty,
      type: meta.type,
      imageId: meta.imageId,
      question: content.question,
      correct: content.correct,
      wrong: content.wrong,
      explanation: content.explanation,
      source: content.source,
    );
  }

  /// 콘텐츠 없이 메타만으로 생성 (fallback)
  factory Question.fromMetaOnly(QuestionMeta meta) {
    return Question(
      id: meta.id,
      chapterId: meta.chapterId,
      order: meta.order,
      difficulty: meta.difficulty,
      type: meta.type,
      imageId: meta.imageId,
      question: meta.id,
      correct: '',
      wrong: [],
      explanation: '',
    );
  }

  /// QuestionMeta 추출
  QuestionMeta get meta => QuestionMeta(
        id: id,
        chapterId: chapterId,
        order: order,
        difficulty: difficulty,
        type: type,
        imageId: imageId,
      );

  /// QuestionContent 추출
  QuestionContent get content => QuestionContent(
        question: question,
        correct: correct,
        wrong: wrong,
        explanation: explanation,
        source: source,
      );

  /// 선지 섞어서 반환 (매번 다른 순서)
  List<String> getShuffledOptions() {
    final options = [correct, ...wrong];
    options.shuffle();
    return options;
  }

  /// 정답 인덱스 반환 (섞인 선지 기준)
  int getCorrectIndex(List<String> shuffledOptions) {
    return shuffledOptions.indexOf(correct);
  }

  /// 사료형 문제 여부
  bool get hasSource => source != null && source!.isNotEmpty;

  /// 이미지형 문제 여부
  bool get hasImage => imageId != null && imageId!.isNotEmpty;

  @override
  String toString() {
    return 'Question(id: $id, chapterId: $chapterId, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Question && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
