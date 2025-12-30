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

  /// No description provided for @startStudy.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 학습 시작하기'**
  String get startStudy;

  /// No description provided for @continueStudy.
  ///
  /// In ko, this message translates to:
  /// **'학습 이어하기'**
  String get continueStudy;

  /// No description provided for @todayStudy.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 학습'**
  String get todayStudy;

  /// No description provided for @questionsCompleted.
  ///
  /// In ko, this message translates to:
  /// **'{completed}문제 중 {total}문제 완료'**
  String questionsCompleted(int completed, int total);

  /// No description provided for @streakDays.
  ///
  /// In ko, this message translates to:
  /// **'연속 {days}일째 학습 중!'**
  String streakDays(int days);

  /// No description provided for @wrongReview.
  ///
  /// In ko, this message translates to:
  /// **'오답 복습'**
  String get wrongReview;

  /// No description provided for @spacedReview.
  ///
  /// In ko, this message translates to:
  /// **'복습'**
  String get spacedReview;

  /// No description provided for @newLearning.
  ///
  /// In ko, this message translates to:
  /// **'신규'**
  String get newLearning;

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

  /// No description provided for @accuracyRate.
  ///
  /// In ko, this message translates to:
  /// **'정답률 {rate}%'**
  String accuracyRate(int rate);

  /// No description provided for @goHome.
  ///
  /// In ko, this message translates to:
  /// **'홈으로 돌아가기'**
  String get goHome;

  /// No description provided for @additionalStudy.
  ///
  /// In ko, this message translates to:
  /// **'추가 학습하기'**
  String get additionalStudy;
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
