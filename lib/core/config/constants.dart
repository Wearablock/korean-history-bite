/// 학습 관련 상수
class StudyConstants {
  StudyConstants._();

  /// 일일 목표 옵션
  static const List<int> dailyGoalOptions = [15, 30, 50];
  static const int defaultDailyGoal = 30;

  /// 복습 간격 (레벨별, 일 단위)
  static const List<int> reviewIntervals = [1, 1, 3, 7, 14, 30];

  /// 오답 시 레벨 감소량
  static const int wrongAnswerPenalty = 2;

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

  /// 패딩
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  /// 보더 라디우스
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
}
