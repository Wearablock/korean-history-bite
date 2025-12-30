// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '한국사 한입';

  @override
  String get home => '홈';

  @override
  String get progress => '진행률';

  @override
  String get settings => '설정';

  @override
  String get startStudy => '오늘의 학습 시작하기';

  @override
  String get continueStudy => '학습 이어하기';

  @override
  String get todayStudy => '오늘의 학습';

  @override
  String questionsCompleted(int completed, int total) {
    return '$completed문제 중 $total문제 완료';
  }

  @override
  String streakDays(int days) {
    return '연속 $days일째 학습 중!';
  }

  @override
  String get wrongReview => '오답 복습';

  @override
  String get spacedReview => '복습';

  @override
  String get newLearning => '신규';

  @override
  String get correct => '정답';

  @override
  String get wrong => '오답';

  @override
  String get nextQuestion => '다음 문제';

  @override
  String get sessionComplete => '오늘의 학습 완료!';

  @override
  String accuracyRate(int rate) {
    return '정답률 $rate%';
  }

  @override
  String get goHome => '홈으로 돌아가기';

  @override
  String get additionalStudy => '추가 학습하기';
}
