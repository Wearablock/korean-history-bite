/// 학습 관련 상수
class StudyConstants {
  StudyConstants._();

  /// 일일 목표 옵션 (챕터 수)
  static const List<int> dailyGoalOptions = [1, 2, 3];
  static const int defaultDailyGoal = 1;
  static const int maxDailyGoalChapters = 5; // 커스텀 최대값

  /// 복습 간격 (레벨별, 일 단위)
  static const List<int> reviewIntervals = [1, 1, 3, 7, 14, 30];

  /// 완전 습득 레벨
  static const int masteryLevel = 5;

  /// 세션 내 최대 문제 유형별 할당
  static const int maxWrongReviewCount = 10;
  static const int maxSpacedReviewCount = 10;
  static const int minNewLearningCount = 5;
}

/// UI 관련 상수
class UIConstants {
  UIConstants._();

  /// 애니메이션 지속 시간
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  /// 간격 (Spacing)
  static const double spacing2 = 2.0;
  static const double spacing4 = 4.0;
  static const double spacing6 = 6.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;

  /// 패딩 (Spacing과 동일, 시맨틱 별칭)
  static const double paddingSmall = spacing8;
  static const double paddingMedium = spacing16;
  static const double paddingLarge = spacing24;

  /// 보더 라디우스
  static const double radiusXSmall = 2.0;
  static const double radiusTiny = 4.0;
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  static const double radiusRound = 999.0;

  /// 진행률 바 높이
  static const double progressBarSmall = 4.0;
  static const double progressBarMedium = 8.0;
  static const double progressBarLarge = 12.0;
}
