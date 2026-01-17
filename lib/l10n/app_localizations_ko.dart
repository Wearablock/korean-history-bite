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
  String get wrongAnswers => '오답노트';

  @override
  String error(String message) {
    return '오류: $message';
  }

  @override
  String get startStudy => '학습 시작하기';

  @override
  String get continueStudy => '학습 이어하기';

  @override
  String get startReview => '복습하기';

  @override
  String get todayStudy => '오늘의 학습';

  @override
  String get allChaptersCompleted => '모든 챕터 학습 완료!';

  @override
  String get reviewEncouragement => '복습을 통해 실력을 더욱 쌓아보세요.';

  @override
  String get nextChapter => '다음 챕터';

  @override
  String questionsCount(int count) {
    return '$count문제';
  }

  @override
  String todayQuestionsCompleted(int count) {
    return '오늘 $count문제 학습 완료';
  }

  @override
  String get todayGoal => '오늘의 목표';

  @override
  String chaptersProgress(int studied, int goal) {
    return '$studied/$goal 챕터';
  }

  @override
  String streakDays(int days) {
    return '연속 $days일째 학습 중!';
  }

  @override
  String get overallProgress => '전체 진행률';

  @override
  String get mastered => '완전 습득';

  @override
  String get studiedOnce => '1회 이상 학습';

  @override
  String totalQuestions(int count) {
    return '총 $count문제';
  }

  @override
  String questionsMastered(int count, int total) {
    return '$count / $total 문제 완전 습득';
  }

  @override
  String get study => '학습';

  @override
  String get notifications => '알림';

  @override
  String get appSettings => '앱 설정';

  @override
  String get info => '정보';

  @override
  String get appVersion => '앱 버전';

  @override
  String get termsAndPolicies => '약관 및 정책';

  @override
  String get termsOfService => '이용약관';

  @override
  String get privacyPolicy => '개인정보 처리방침';

  @override
  String get data => '데이터';

  @override
  String get resetStudyRecords => '학습 기록 초기화';

  @override
  String get resetStudyRecordsDesc => '모든 학습 기록을 삭제합니다';

  @override
  String get resetStudyRecordsConfirm => '모든 학습 기록이 삭제됩니다.\n이 작업은 되돌릴 수 없습니다.';

  @override
  String get cannotOpenLink => '링크를 열 수 없습니다.';

  @override
  String get cancel => '취소';

  @override
  String get reset => '초기화';

  @override
  String get confirm => '확인';

  @override
  String get studyRecordsReset => '학습 기록이 초기화되었습니다.';

  @override
  String get dailyStudyAmount => '일일 학습량';

  @override
  String chaptersUnit(int count) {
    return '$count챕터';
  }

  @override
  String get customSetting => '직접 설정';

  @override
  String get theme => '테마';

  @override
  String get selectTheme => '테마 선택';

  @override
  String get studyComplete => '학습 완료';

  @override
  String get goodJob => '수고하셨습니다';

  @override
  String continueReviewWithCount(int count) {
    return '이어서 복습하기 ($count개 남음)';
  }

  @override
  String get goHome => '홈으로';

  @override
  String get additionalStudy => '추가 학습하기';

  @override
  String get todayStudyCompleteMessage => '오늘의 학습이 완료되었어요!';

  @override
  String get excellentComplete => '훌륭해요!\n오늘의 학습을 완료했어요!';

  @override
  String get goodComplete => '잘했어요!\n오늘의 학습을 완료했어요!';

  @override
  String get accuracy => '정답률';

  @override
  String get correct => '정답';

  @override
  String get wrong => '오답';

  @override
  String get timeSpent => '소요 시간';

  @override
  String get phaseResults => '단계별 결과';

  @override
  String get wrongReview => '오답 복습';

  @override
  String get spacedReview => '망각곡선 복습';

  @override
  String get newLearning => '신규 학습';

  @override
  String get errorOccurred => '오류가 발생했습니다';

  @override
  String get retry => '다시 시도';

  @override
  String get stopStudy => '학습 중단';

  @override
  String get stopStudyConfirm => '학습을 중단하시겠습니까?\n현재까지의 진행 상황은 저장됩니다.';

  @override
  String get continueStudyButton => '계속 학습';

  @override
  String get stop => '중단';

  @override
  String get chapterNotFound => '챕터를 찾을 수 없습니다.';

  @override
  String get eraProgress => '시대별 진행률';

  @override
  String get reviewAvailable => '복습할 문제가 있어요!';

  @override
  String reviewWaiting(int count) {
    return '$count개의 문제가 복습을 기다려요';
  }

  @override
  String get welcome => '환영합니다!';

  @override
  String get howManyChapters => '하루에 몇 챕터를 공부할까요?';

  @override
  String get canChangeInSettings => '나중에 설정에서 변경할 수 있어요';

  @override
  String get start => '시작하기';

  @override
  String get lightStart => '가볍게 시작하기';

  @override
  String get moderateAmount => '적당한 학습량';

  @override
  String get intensiveStudy => '집중 학습';

  @override
  String settingsSaveError(String error) {
    return '설정 저장 중 오류가 발생했습니다: $error';
  }

  @override
  String get overallStudyStats => '전체 학습 통계';

  @override
  String get totalStudy => '총 학습';

  @override
  String get accuracyRate => '정답률';

  @override
  String get studyDays => '학습일';

  @override
  String daysCount(int count) {
    return '$count일';
  }

  @override
  String get studyTime => '학습시간';

  @override
  String get streakRecord => '연속 학습 기록';

  @override
  String get currentStreak => '현재 스트릭';

  @override
  String get longestStreak => '최장 스트릭';

  @override
  String get newRecord => '새로운 기록을 세우고 있어요!';

  @override
  String get weekStreak => '일주일 연속! 대단해요!';

  @override
  String get keepItUp => '꾸준히 잘하고 있어요!';

  @override
  String get todayComplete => '오늘도 학습 완료!';

  @override
  String get levelDistribution => '학습 수준 분포';

  @override
  String get fullyMastered => '완전습득';

  @override
  String get reviewLevel4 => '복습 4단계';

  @override
  String get reviewLevel3 => '복습 3단계';

  @override
  String get reviewLevel2 => '복습 2단계';

  @override
  String get reviewLevel1 => '복습 1단계';

  @override
  String get wrongOrReset => '오답/리셋';

  @override
  String get unknown => '알 수 없음';

  @override
  String get unstudied => '미학습';

  @override
  String get learning => '학습중';

  @override
  String get studyNotification => '학습 알림';

  @override
  String get dailyNotification => '매일 정해진 시간에 알림';

  @override
  String get notificationOff => '알림 꺼짐';

  @override
  String get notificationTime => '알림 시간';

  @override
  String get selectNotificationTime => '알림 시간 선택';

  @override
  String amTime(int hour, String minute) {
    return '오전 $hour:$minute';
  }

  @override
  String pmTime(int hour, String minute) {
    return '오후 $hour:$minute';
  }

  @override
  String get wrongAnswersComingSoon => '오답노트 화면 (구현 예정)';

  @override
  String get nextQuestion => '다음 문제';

  @override
  String get sessionComplete => '오늘의 학습 완료!';

  @override
  String questionsCompleted(int completed, int total) {
    return '$completed문제 중 $total문제 완료';
  }

  @override
  String get eraPrehistoric => '선사시대';

  @override
  String get eraGojoseon => '고조선';

  @override
  String get eraThreeKingdoms => '삼국시대';

  @override
  String get eraNorthSouthStates => '남북국시대';

  @override
  String get eraGoryeo => '고려';

  @override
  String get eraJoseonEarly => '조선 전기';

  @override
  String get eraJoseonLate => '조선 후기';

  @override
  String get eraModern => '근대';

  @override
  String get eraJapaneseOccupation => '일제강점기';

  @override
  String get eraContemporary => '현대';

  @override
  String get studied => '학습';

  @override
  String get masteredShort => '완전습득';

  @override
  String studiedStats(int studied, int total, int mastered) {
    return '학습 $studied/$total · 완전습득 $mastered';
  }

  @override
  String get questionNotFound => '문제를 찾을 수 없습니다.';

  @override
  String get review => '복습';

  @override
  String get theoryLearning => '이론 학습';

  @override
  String get learningComplete => '학습 완료';

  @override
  String get correctAnswer => '정답입니다!';

  @override
  String get wrongAnswer => '오답입니다';

  @override
  String get quiz => '퀴즈';

  @override
  String get showHint => '힌트 보기';

  @override
  String get imageLoadFailed => '이미지 로드 실패';

  @override
  String get sourceDocument => '사료';

  @override
  String get newShort => '신규';

  @override
  String itemCount(int count) {
    return '$count개';
  }

  @override
  String get premium => '프리미엄';

  @override
  String get removeAds => '광고 제거';

  @override
  String get premiumActivated => '프리미엄이 활성화되었습니다';

  @override
  String get purchase => '구매';

  @override
  String get restorePurchases => '구매 복원';

  @override
  String get purchaseFailed => '구매에 실패했습니다';

  @override
  String get purchasesRestored => '구매 복원이 완료되었습니다';

  @override
  String get productNotAvailable => '상품을 불러올 수 없습니다';
}
