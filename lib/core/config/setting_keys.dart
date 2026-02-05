/// 사용자 설정 키 상수
/// 오타 방지 및 자동완성 지원
abstract class SettingKeys {
  // 학습 관련
  static const String dailyGoal = 'daily_goal';
  static const String reviewPriority = 'review_priority';
  static const String shuffleOptions = 'shuffle_options';
  static const String showExplanation = 'show_explanation';

  // 알림 관련
  static const String notificationEnabled = 'notification_enabled';
  static const String notificationHour = 'notification_hour';
  static const String notificationMinute = 'notification_minute';
  static const String streakReminder = 'streak_reminder';

  // 테마
  static const String themeMode = 'theme_mode';

  // 언어
  static const String locale = 'locale';
  static const String contentLocale = 'content_locale';

  // 프리미엄
  static const String isPremium = 'is_premium';
  static const String premiumPurchasedAt = 'premium_purchased_at';

  // 기타
  static const String firstLaunchDate = 'first_launch_date';
  static const String lastReviewPrompt = 'last_review_prompt';
  static const String reviewPromptCount = 'review_prompt_count';
  static const String onboardingCompleted = 'onboarding_completed';
}

/// 일일 학습 목표 옵션 (챕터 기준)
enum DailyGoalOption {
  oneChapter(1, '1챕터'),
  twoChapters(2, '2챕터'),
  threeChapters(3, '3챕터');

  final int chapterCount;
  final String label;

  const DailyGoalOption(this.chapterCount, this.label);

  static DailyGoalOption? fromValue(int value) {
    for (final option in DailyGoalOption.values) {
      if (option.chapterCount == value) {
        return option;
      }
    }
    return null; // 커스텀 값인 경우 null 반환
  }
}

/// 테마 모드 옵션
enum ThemeModeOption {
  system('system', '시스템 설정'),
  light('light', '라이트 모드'),
  dark('dark', '다크 모드');

  final String value;
  final String label;

  const ThemeModeOption(this.value, this.label);

  static ThemeModeOption fromValue(String value) {
    return ThemeModeOption.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ThemeModeOption.system,
    );
  }
}

/// 언어 옵션
enum LanguageOption {
  system('system', '시스템 설정', null),
  korean('ko', '한국어', 'ko'),
  english('en', 'English', 'en'),
  japanese('ja', '日本語', 'ja'),
  chineseSimplified('zh-Hans', '简体中文', 'zh-Hans'),
  chineseTraditional('zh-Hant', '繁體中文', 'zh-Hant');

  final String value;
  final String label;
  final String? localeCode; // null for system

  const LanguageOption(this.value, this.label, this.localeCode);

  static LanguageOption fromValue(String value) {
    return LanguageOption.values.firstWhere(
      (e) => e.value == value,
      orElse: () => LanguageOption.system,
    );
  }
}
