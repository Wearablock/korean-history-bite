import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko')
  ];

  /// 앱 제목
  ///
  /// In ko, this message translates to:
  /// **'한국사 한입'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In ko, this message translates to:
  /// **'홈'**
  String get home;

  /// No description provided for @progress.
  ///
  /// In ko, this message translates to:
  /// **'진행률'**
  String get progress;

  /// No description provided for @settings.
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get settings;

  /// No description provided for @wrongAnswers.
  ///
  /// In ko, this message translates to:
  /// **'오답노트'**
  String get wrongAnswers;

  /// No description provided for @error.
  ///
  /// In ko, this message translates to:
  /// **'오류: {message}'**
  String error(String message);

  /// No description provided for @startStudy.
  ///
  /// In ko, this message translates to:
  /// **'학습 시작하기'**
  String get startStudy;

  /// No description provided for @continueStudy.
  ///
  /// In ko, this message translates to:
  /// **'학습 이어하기'**
  String get continueStudy;

  /// No description provided for @startReview.
  ///
  /// In ko, this message translates to:
  /// **'복습하기'**
  String get startReview;

  /// No description provided for @todayStudy.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 학습'**
  String get todayStudy;

  /// No description provided for @allChaptersCompleted.
  ///
  /// In ko, this message translates to:
  /// **'모든 챕터 학습 완료!'**
  String get allChaptersCompleted;

  /// No description provided for @reviewEncouragement.
  ///
  /// In ko, this message translates to:
  /// **'복습을 통해 실력을 더욱 쌓아보세요.'**
  String get reviewEncouragement;

  /// No description provided for @nextChapter.
  ///
  /// In ko, this message translates to:
  /// **'다음 챕터'**
  String get nextChapter;

  /// No description provided for @questionsCount.
  ///
  /// In ko, this message translates to:
  /// **'{count}문제'**
  String questionsCount(int count);

  /// No description provided for @todayQuestionsCompleted.
  ///
  /// In ko, this message translates to:
  /// **'오늘 {count}문제 학습 완료'**
  String todayQuestionsCompleted(int count);

  /// No description provided for @todayGoal.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 목표'**
  String get todayGoal;

  /// No description provided for @chaptersProgress.
  ///
  /// In ko, this message translates to:
  /// **'{studied}/{goal} 챕터'**
  String chaptersProgress(int studied, int goal);

  /// No description provided for @streakDays.
  ///
  /// In ko, this message translates to:
  /// **'연속 {days}일째 학습 중!'**
  String streakDays(int days);

  /// No description provided for @overallProgress.
  ///
  /// In ko, this message translates to:
  /// **'전체 진행률'**
  String get overallProgress;

  /// No description provided for @mastered.
  ///
  /// In ko, this message translates to:
  /// **'완전 습득'**
  String get mastered;

  /// No description provided for @studiedOnce.
  ///
  /// In ko, this message translates to:
  /// **'1회 이상 학습'**
  String get studiedOnce;

  /// No description provided for @totalQuestions.
  ///
  /// In ko, this message translates to:
  /// **'총 {count}문제'**
  String totalQuestions(int count);

  /// No description provided for @questionsMastered.
  ///
  /// In ko, this message translates to:
  /// **'{count} / {total} 문제 완전 습득'**
  String questionsMastered(int count, int total);

  /// No description provided for @study.
  ///
  /// In ko, this message translates to:
  /// **'학습'**
  String get study;

  /// No description provided for @notifications.
  ///
  /// In ko, this message translates to:
  /// **'알림'**
  String get notifications;

  /// No description provided for @appSettings.
  ///
  /// In ko, this message translates to:
  /// **'앱 설정'**
  String get appSettings;

  /// No description provided for @info.
  ///
  /// In ko, this message translates to:
  /// **'정보'**
  String get info;

  /// No description provided for @appVersion.
  ///
  /// In ko, this message translates to:
  /// **'앱 버전'**
  String get appVersion;

  /// No description provided for @termsAndPolicies.
  ///
  /// In ko, this message translates to:
  /// **'약관 및 정책'**
  String get termsAndPolicies;

  /// No description provided for @termsOfService.
  ///
  /// In ko, this message translates to:
  /// **'이용약관'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In ko, this message translates to:
  /// **'개인정보 처리방침'**
  String get privacyPolicy;

  /// No description provided for @data.
  ///
  /// In ko, this message translates to:
  /// **'데이터'**
  String get data;

  /// No description provided for @resetStudyRecords.
  ///
  /// In ko, this message translates to:
  /// **'학습 기록 초기화'**
  String get resetStudyRecords;

  /// No description provided for @resetStudyRecordsDesc.
  ///
  /// In ko, this message translates to:
  /// **'모든 학습 기록을 삭제합니다'**
  String get resetStudyRecordsDesc;

  /// No description provided for @resetStudyRecordsConfirm.
  ///
  /// In ko, this message translates to:
  /// **'모든 학습 기록이 삭제됩니다.\n이 작업은 되돌릴 수 없습니다.'**
  String get resetStudyRecordsConfirm;

  /// No description provided for @cannotOpenLink.
  ///
  /// In ko, this message translates to:
  /// **'링크를 열 수 없습니다.'**
  String get cannotOpenLink;

  /// No description provided for @cancel.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get cancel;

  /// No description provided for @reset.
  ///
  /// In ko, this message translates to:
  /// **'초기화'**
  String get reset;

  /// No description provided for @confirm.
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get confirm;

  /// No description provided for @studyRecordsReset.
  ///
  /// In ko, this message translates to:
  /// **'학습 기록이 초기화되었습니다.'**
  String get studyRecordsReset;

  /// No description provided for @dailyStudyAmount.
  ///
  /// In ko, this message translates to:
  /// **'일일 학습량'**
  String get dailyStudyAmount;

  /// No description provided for @chaptersUnit.
  ///
  /// In ko, this message translates to:
  /// **'{count}챕터'**
  String chaptersUnit(int count);

  /// No description provided for @customSetting.
  ///
  /// In ko, this message translates to:
  /// **'직접 설정'**
  String get customSetting;

  /// No description provided for @theme.
  ///
  /// In ko, this message translates to:
  /// **'테마'**
  String get theme;

  /// No description provided for @selectTheme.
  ///
  /// In ko, this message translates to:
  /// **'테마 선택'**
  String get selectTheme;

  /// No description provided for @studyComplete.
  ///
  /// In ko, this message translates to:
  /// **'학습 완료'**
  String get studyComplete;

  /// No description provided for @goodJob.
  ///
  /// In ko, this message translates to:
  /// **'수고하셨습니다'**
  String get goodJob;

  /// No description provided for @continueReviewWithCount.
  ///
  /// In ko, this message translates to:
  /// **'이어서 복습하기 ({count}개 남음)'**
  String continueReviewWithCount(int count);

  /// No description provided for @goHome.
  ///
  /// In ko, this message translates to:
  /// **'홈으로'**
  String get goHome;

  /// No description provided for @additionalStudy.
  ///
  /// In ko, this message translates to:
  /// **'추가 학습하기'**
  String get additionalStudy;

  /// No description provided for @todayStudyCompleteMessage.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 학습이 완료되었어요!'**
  String get todayStudyCompleteMessage;

  /// No description provided for @excellentComplete.
  ///
  /// In ko, this message translates to:
  /// **'훌륭해요!\n오늘의 학습을 완료했어요!'**
  String get excellentComplete;

  /// No description provided for @goodComplete.
  ///
  /// In ko, this message translates to:
  /// **'잘했어요!\n오늘의 학습을 완료했어요!'**
  String get goodComplete;

  /// No description provided for @accuracy.
  ///
  /// In ko, this message translates to:
  /// **'정답률'**
  String get accuracy;

  /// No description provided for @correct.
  ///
  /// In ko, this message translates to:
  /// **'정답'**
  String get correct;

  /// No description provided for @wrong.
  ///
  /// In ko, this message translates to:
  /// **'오답'**
  String get wrong;

  /// No description provided for @timeSpent.
  ///
  /// In ko, this message translates to:
  /// **'소요 시간'**
  String get timeSpent;

  /// No description provided for @phaseResults.
  ///
  /// In ko, this message translates to:
  /// **'단계별 결과'**
  String get phaseResults;

  /// No description provided for @wrongReview.
  ///
  /// In ko, this message translates to:
  /// **'오답 복습'**
  String get wrongReview;

  /// No description provided for @spacedReview.
  ///
  /// In ko, this message translates to:
  /// **'망각곡선 복습'**
  String get spacedReview;

  /// No description provided for @newLearning.
  ///
  /// In ko, this message translates to:
  /// **'신규 학습'**
  String get newLearning;

  /// No description provided for @errorOccurred.
  ///
  /// In ko, this message translates to:
  /// **'오류가 발생했습니다'**
  String get errorOccurred;

  /// No description provided for @retry.
  ///
  /// In ko, this message translates to:
  /// **'다시 시도'**
  String get retry;

  /// No description provided for @stopStudy.
  ///
  /// In ko, this message translates to:
  /// **'학습 중단'**
  String get stopStudy;

  /// No description provided for @stopStudyConfirm.
  ///
  /// In ko, this message translates to:
  /// **'학습을 중단하시겠습니까?\n현재까지의 진행 상황은 저장됩니다.'**
  String get stopStudyConfirm;

  /// No description provided for @continueStudyButton.
  ///
  /// In ko, this message translates to:
  /// **'계속 학습'**
  String get continueStudyButton;

  /// No description provided for @stop.
  ///
  /// In ko, this message translates to:
  /// **'중단'**
  String get stop;

  /// No description provided for @chapterNotFound.
  ///
  /// In ko, this message translates to:
  /// **'챕터를 찾을 수 없습니다.'**
  String get chapterNotFound;

  /// No description provided for @eraProgress.
  ///
  /// In ko, this message translates to:
  /// **'시대별 진행률'**
  String get eraProgress;

  /// No description provided for @reviewAvailable.
  ///
  /// In ko, this message translates to:
  /// **'복습할 문제가 있어요!'**
  String get reviewAvailable;

  /// No description provided for @reviewWaiting.
  ///
  /// In ko, this message translates to:
  /// **'{count}개의 문제가 복습을 기다려요'**
  String reviewWaiting(int count);

  /// No description provided for @welcome.
  ///
  /// In ko, this message translates to:
  /// **'환영합니다!'**
  String get welcome;

  /// No description provided for @howManyChapters.
  ///
  /// In ko, this message translates to:
  /// **'하루에 몇 챕터를 공부할까요?'**
  String get howManyChapters;

  /// No description provided for @canChangeInSettings.
  ///
  /// In ko, this message translates to:
  /// **'나중에 설정에서 변경할 수 있어요'**
  String get canChangeInSettings;

  /// No description provided for @start.
  ///
  /// In ko, this message translates to:
  /// **'시작하기'**
  String get start;

  /// No description provided for @lightStart.
  ///
  /// In ko, this message translates to:
  /// **'가볍게 시작하기'**
  String get lightStart;

  /// No description provided for @moderateAmount.
  ///
  /// In ko, this message translates to:
  /// **'적당한 학습량'**
  String get moderateAmount;

  /// No description provided for @intensiveStudy.
  ///
  /// In ko, this message translates to:
  /// **'집중 학습'**
  String get intensiveStudy;

  /// No description provided for @settingsSaveError.
  ///
  /// In ko, this message translates to:
  /// **'설정 저장 중 오류가 발생했습니다: {error}'**
  String settingsSaveError(String error);

  /// No description provided for @overallStudyStats.
  ///
  /// In ko, this message translates to:
  /// **'전체 학습 통계'**
  String get overallStudyStats;

  /// No description provided for @totalStudy.
  ///
  /// In ko, this message translates to:
  /// **'총 학습'**
  String get totalStudy;

  /// No description provided for @accuracyRate.
  ///
  /// In ko, this message translates to:
  /// **'정답률'**
  String get accuracyRate;

  /// No description provided for @studyDays.
  ///
  /// In ko, this message translates to:
  /// **'학습일'**
  String get studyDays;

  /// No description provided for @daysCount.
  ///
  /// In ko, this message translates to:
  /// **'{count}일'**
  String daysCount(int count);

  /// No description provided for @studyTime.
  ///
  /// In ko, this message translates to:
  /// **'학습시간'**
  String get studyTime;

  /// No description provided for @streakRecord.
  ///
  /// In ko, this message translates to:
  /// **'연속 학습 기록'**
  String get streakRecord;

  /// No description provided for @currentStreak.
  ///
  /// In ko, this message translates to:
  /// **'현재 스트릭'**
  String get currentStreak;

  /// No description provided for @longestStreak.
  ///
  /// In ko, this message translates to:
  /// **'최장 스트릭'**
  String get longestStreak;

  /// No description provided for @newRecord.
  ///
  /// In ko, this message translates to:
  /// **'새로운 기록을 세우고 있어요!'**
  String get newRecord;

  /// No description provided for @weekStreak.
  ///
  /// In ko, this message translates to:
  /// **'일주일 연속! 대단해요!'**
  String get weekStreak;

  /// No description provided for @keepItUp.
  ///
  /// In ko, this message translates to:
  /// **'꾸준히 잘하고 있어요!'**
  String get keepItUp;

  /// No description provided for @todayComplete.
  ///
  /// In ko, this message translates to:
  /// **'오늘도 학습 완료!'**
  String get todayComplete;

  /// No description provided for @levelDistribution.
  ///
  /// In ko, this message translates to:
  /// **'학습 수준 분포'**
  String get levelDistribution;

  /// No description provided for @fullyMastered.
  ///
  /// In ko, this message translates to:
  /// **'완전습득'**
  String get fullyMastered;

  /// No description provided for @reviewLevel4.
  ///
  /// In ko, this message translates to:
  /// **'복습 4단계'**
  String get reviewLevel4;

  /// No description provided for @reviewLevel3.
  ///
  /// In ko, this message translates to:
  /// **'복습 3단계'**
  String get reviewLevel3;

  /// No description provided for @reviewLevel2.
  ///
  /// In ko, this message translates to:
  /// **'복습 2단계'**
  String get reviewLevel2;

  /// No description provided for @reviewLevel1.
  ///
  /// In ko, this message translates to:
  /// **'복습 1단계'**
  String get reviewLevel1;

  /// No description provided for @wrongOrReset.
  ///
  /// In ko, this message translates to:
  /// **'오답/리셋'**
  String get wrongOrReset;

  /// No description provided for @unknown.
  ///
  /// In ko, this message translates to:
  /// **'알 수 없음'**
  String get unknown;

  /// No description provided for @unstudied.
  ///
  /// In ko, this message translates to:
  /// **'미학습'**
  String get unstudied;

  /// No description provided for @learning.
  ///
  /// In ko, this message translates to:
  /// **'학습중'**
  String get learning;

  /// No description provided for @studyNotification.
  ///
  /// In ko, this message translates to:
  /// **'학습 알림'**
  String get studyNotification;

  /// No description provided for @dailyNotification.
  ///
  /// In ko, this message translates to:
  /// **'매일 정해진 시간에 알림'**
  String get dailyNotification;

  /// No description provided for @notificationOff.
  ///
  /// In ko, this message translates to:
  /// **'알림 꺼짐'**
  String get notificationOff;

  /// No description provided for @notificationTime.
  ///
  /// In ko, this message translates to:
  /// **'알림 시간'**
  String get notificationTime;

  /// No description provided for @selectNotificationTime.
  ///
  /// In ko, this message translates to:
  /// **'알림 시간 선택'**
  String get selectNotificationTime;

  /// No description provided for @amTime.
  ///
  /// In ko, this message translates to:
  /// **'오전 {hour}:{minute}'**
  String amTime(int hour, String minute);

  /// No description provided for @pmTime.
  ///
  /// In ko, this message translates to:
  /// **'오후 {hour}:{minute}'**
  String pmTime(int hour, String minute);

  /// No description provided for @wrongAnswersComingSoon.
  ///
  /// In ko, this message translates to:
  /// **'오답노트 화면 (구현 예정)'**
  String get wrongAnswersComingSoon;

  /// No description provided for @nextQuestion.
  ///
  /// In ko, this message translates to:
  /// **'다음 문제'**
  String get nextQuestion;

  /// No description provided for @sessionComplete.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 학습 완료!'**
  String get sessionComplete;

  /// No description provided for @questionsCompleted.
  ///
  /// In ko, this message translates to:
  /// **'{completed}문제 중 {total}문제 완료'**
  String questionsCompleted(int completed, int total);

  /// No description provided for @eraPrehistoric.
  ///
  /// In ko, this message translates to:
  /// **'선사시대'**
  String get eraPrehistoric;

  /// No description provided for @eraGojoseon.
  ///
  /// In ko, this message translates to:
  /// **'고조선'**
  String get eraGojoseon;

  /// No description provided for @eraThreeKingdoms.
  ///
  /// In ko, this message translates to:
  /// **'삼국시대'**
  String get eraThreeKingdoms;

  /// No description provided for @eraNorthSouthStates.
  ///
  /// In ko, this message translates to:
  /// **'남북국시대'**
  String get eraNorthSouthStates;

  /// No description provided for @eraGoryeo.
  ///
  /// In ko, this message translates to:
  /// **'고려'**
  String get eraGoryeo;

  /// No description provided for @eraJoseonEarly.
  ///
  /// In ko, this message translates to:
  /// **'조선 전기'**
  String get eraJoseonEarly;

  /// No description provided for @eraJoseonLate.
  ///
  /// In ko, this message translates to:
  /// **'조선 후기'**
  String get eraJoseonLate;

  /// No description provided for @eraModern.
  ///
  /// In ko, this message translates to:
  /// **'근대'**
  String get eraModern;

  /// No description provided for @eraJapaneseOccupation.
  ///
  /// In ko, this message translates to:
  /// **'일제강점기'**
  String get eraJapaneseOccupation;

  /// No description provided for @eraContemporary.
  ///
  /// In ko, this message translates to:
  /// **'현대'**
  String get eraContemporary;

  /// No description provided for @studied.
  ///
  /// In ko, this message translates to:
  /// **'학습'**
  String get studied;

  /// No description provided for @masteredShort.
  ///
  /// In ko, this message translates to:
  /// **'완전습득'**
  String get masteredShort;

  /// No description provided for @studiedStats.
  ///
  /// In ko, this message translates to:
  /// **'학습 {studied}/{total} · 완전습득 {mastered}'**
  String studiedStats(int studied, int total, int mastered);

  /// No description provided for @questionNotFound.
  ///
  /// In ko, this message translates to:
  /// **'문제를 찾을 수 없습니다.'**
  String get questionNotFound;

  /// No description provided for @review.
  ///
  /// In ko, this message translates to:
  /// **'복습'**
  String get review;

  /// No description provided for @theoryLearning.
  ///
  /// In ko, this message translates to:
  /// **'이론 학습'**
  String get theoryLearning;

  /// No description provided for @learningComplete.
  ///
  /// In ko, this message translates to:
  /// **'학습 완료'**
  String get learningComplete;

  /// No description provided for @correctAnswer.
  ///
  /// In ko, this message translates to:
  /// **'정답입니다!'**
  String get correctAnswer;

  /// No description provided for @wrongAnswer.
  ///
  /// In ko, this message translates to:
  /// **'오답입니다'**
  String get wrongAnswer;

  /// No description provided for @quiz.
  ///
  /// In ko, this message translates to:
  /// **'퀴즈'**
  String get quiz;

  /// No description provided for @showHint.
  ///
  /// In ko, this message translates to:
  /// **'힌트 보기'**
  String get showHint;

  /// No description provided for @imageLoadFailed.
  ///
  /// In ko, this message translates to:
  /// **'이미지 로드 실패'**
  String get imageLoadFailed;

  /// No description provided for @sourceDocument.
  ///
  /// In ko, this message translates to:
  /// **'사료'**
  String get sourceDocument;

  /// No description provided for @newShort.
  ///
  /// In ko, this message translates to:
  /// **'신규'**
  String get newShort;

  /// No description provided for @itemCount.
  ///
  /// In ko, this message translates to:
  /// **'{count}개'**
  String itemCount(int count);

  /// No description provided for @premium.
  ///
  /// In ko, this message translates to:
  /// **'프리미엄'**
  String get premium;

  /// No description provided for @removeAds.
  ///
  /// In ko, this message translates to:
  /// **'광고 제거'**
  String get removeAds;

  /// No description provided for @premiumActivated.
  ///
  /// In ko, this message translates to:
  /// **'프리미엄이 활성화되었습니다'**
  String get premiumActivated;

  /// No description provided for @purchase.
  ///
  /// In ko, this message translates to:
  /// **'구매'**
  String get purchase;

  /// No description provided for @restorePurchases.
  ///
  /// In ko, this message translates to:
  /// **'구매 복원'**
  String get restorePurchases;

  /// No description provided for @purchaseFailed.
  ///
  /// In ko, this message translates to:
  /// **'구매에 실패했습니다'**
  String get purchaseFailed;

  /// No description provided for @purchasesRestored.
  ///
  /// In ko, this message translates to:
  /// **'구매 복원이 완료되었습니다'**
  String get purchasesRestored;

  /// No description provided for @productNotAvailable.
  ///
  /// In ko, this message translates to:
  /// **'상품을 불러올 수 없습니다'**
  String get productNotAvailable;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
