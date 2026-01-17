// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Korean History Bite';

  @override
  String get home => 'Home';

  @override
  String get progress => 'Progress';

  @override
  String get settings => 'Settings';

  @override
  String get wrongAnswers => 'Wrong Answers';

  @override
  String error(String message) {
    return 'Error: $message';
  }

  @override
  String get startStudy => 'Start Study';

  @override
  String get continueStudy => 'Continue Study';

  @override
  String get startReview => 'Start Review';

  @override
  String get todayStudy => 'Today\'s Study';

  @override
  String get allChaptersCompleted => 'All Chapters Completed!';

  @override
  String get reviewEncouragement =>
      'Keep practicing with reviews to master the content.';

  @override
  String get nextChapter => 'Next Chapter';

  @override
  String questionsCount(int count) {
    return '$count questions';
  }

  @override
  String todayQuestionsCompleted(int count) {
    return '$count questions completed today';
  }

  @override
  String get todayGoal => 'Today\'s Goal';

  @override
  String chaptersProgress(int studied, int goal) {
    return '$studied/$goal chapters';
  }

  @override
  String streakDays(int days) {
    return '$days day streak!';
  }

  @override
  String get overallProgress => 'Overall Progress';

  @override
  String get mastered => 'Mastered';

  @override
  String get studiedOnce => 'Studied Once';

  @override
  String totalQuestions(int count) {
    return 'Total $count questions';
  }

  @override
  String questionsMastered(int count, int total) {
    return '$count / $total questions mastered';
  }

  @override
  String get study => 'Study';

  @override
  String get notifications => 'Notifications';

  @override
  String get appSettings => 'App Settings';

  @override
  String get info => 'Info';

  @override
  String get appVersion => 'App Version';

  @override
  String get termsAndPolicies => 'Terms & Policies';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get data => 'Data';

  @override
  String get resetStudyRecords => 'Reset Study Records';

  @override
  String get resetStudyRecordsDesc => 'Delete all study records';

  @override
  String get resetStudyRecordsConfirm =>
      'All study records will be deleted.\nThis action cannot be undone.';

  @override
  String get cannotOpenLink => 'Cannot open link.';

  @override
  String get cancel => 'Cancel';

  @override
  String get reset => 'Reset';

  @override
  String get confirm => 'Confirm';

  @override
  String get studyRecordsReset => 'Study records have been reset.';

  @override
  String get dailyStudyAmount => 'Daily Study Amount';

  @override
  String chaptersUnit(int count) {
    return '$count chapters';
  }

  @override
  String get customSetting => 'Custom';

  @override
  String get theme => 'Theme';

  @override
  String get selectTheme => 'Select Theme';

  @override
  String get studyComplete => 'Study Complete';

  @override
  String get goodJob => 'Good job!';

  @override
  String continueReviewWithCount(int count) {
    return 'Continue Review ($count remaining)';
  }

  @override
  String get goHome => 'Go Home';

  @override
  String get additionalStudy => 'Study More';

  @override
  String get todayStudyCompleteMessage => 'Today\'s study is complete!';

  @override
  String get excellentComplete =>
      'Excellent!\nYou\'ve completed today\'s study!';

  @override
  String get goodComplete => 'Great job!\nYou\'ve completed today\'s study!';

  @override
  String get accuracy => 'Accuracy';

  @override
  String get correct => 'Correct';

  @override
  String get wrong => 'Wrong';

  @override
  String get timeSpent => 'Time Spent';

  @override
  String get phaseResults => 'Results by Phase';

  @override
  String get wrongReview => 'Wrong Review';

  @override
  String get spacedReview => 'Spaced Review';

  @override
  String get newLearning => 'New Learning';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get retry => 'Retry';

  @override
  String get stopStudy => 'Stop Study';

  @override
  String get stopStudyConfirm =>
      'Do you want to stop studying?\nYour progress will be saved.';

  @override
  String get continueStudyButton => 'Continue';

  @override
  String get stop => 'Stop';

  @override
  String get chapterNotFound => 'Chapter not found.';

  @override
  String get eraProgress => 'Progress by Era';

  @override
  String get reviewAvailable => 'You have questions to review!';

  @override
  String reviewWaiting(int count) {
    return '$count questions waiting for review';
  }

  @override
  String get welcome => 'Welcome!';

  @override
  String get howManyChapters => 'How many chapters per day?';

  @override
  String get canChangeInSettings => 'You can change this in settings later';

  @override
  String get start => 'Start';

  @override
  String get lightStart => 'Light start';

  @override
  String get moderateAmount => 'Moderate amount';

  @override
  String get intensiveStudy => 'Intensive study';

  @override
  String settingsSaveError(String error) {
    return 'Error saving settings: $error';
  }

  @override
  String get overallStudyStats => 'Overall Study Stats';

  @override
  String get totalStudy => 'Total Study';

  @override
  String get accuracyRate => 'Accuracy';

  @override
  String get studyDays => 'Study Days';

  @override
  String daysCount(int count) {
    return '$count days';
  }

  @override
  String get studyTime => 'Study Time';

  @override
  String get streakRecord => 'Streak Record';

  @override
  String get currentStreak => 'Current Streak';

  @override
  String get longestStreak => 'Longest Streak';

  @override
  String get newRecord => 'You\'re setting a new record!';

  @override
  String get weekStreak => 'One week streak! Amazing!';

  @override
  String get keepItUp => 'Keep it up!';

  @override
  String get todayComplete => 'Today\'s study complete!';

  @override
  String get levelDistribution => 'Level Distribution';

  @override
  String get fullyMastered => 'Mastered';

  @override
  String get reviewLevel4 => 'Review Level 4';

  @override
  String get reviewLevel3 => 'Review Level 3';

  @override
  String get reviewLevel2 => 'Review Level 2';

  @override
  String get reviewLevel1 => 'Review Level 1';

  @override
  String get wrongOrReset => 'Wrong/Reset';

  @override
  String get unknown => 'Unknown';

  @override
  String get unstudied => 'Unstudied';

  @override
  String get learning => 'Learning';

  @override
  String get studyNotification => 'Study Notification';

  @override
  String get dailyNotification => 'Daily reminder at set time';

  @override
  String get notificationOff => 'Notification off';

  @override
  String get notificationTime => 'Notification Time';

  @override
  String get selectNotificationTime => 'Select notification time';

  @override
  String amTime(int hour, String minute) {
    return '$hour:$minute AM';
  }

  @override
  String pmTime(int hour, String minute) {
    return '$hour:$minute PM';
  }

  @override
  String get wrongAnswersComingSoon => 'Wrong answers (Coming soon)';

  @override
  String get nextQuestion => 'Next Question';

  @override
  String get sessionComplete => 'Today\'s Study Complete!';

  @override
  String questionsCompleted(int completed, int total) {
    return '$completed of $total questions completed';
  }

  @override
  String get eraPrehistoric => 'Prehistoric';

  @override
  String get eraGojoseon => 'Gojoseon';

  @override
  String get eraThreeKingdoms => 'Three Kingdoms';

  @override
  String get eraNorthSouthStates => 'North-South States';

  @override
  String get eraGoryeo => 'Goryeo';

  @override
  String get eraJoseonEarly => 'Early Joseon';

  @override
  String get eraJoseonLate => 'Late Joseon';

  @override
  String get eraModern => 'Modern Era';

  @override
  String get eraJapaneseOccupation => 'Japanese Occupation';

  @override
  String get eraContemporary => 'Contemporary';

  @override
  String get studied => 'Studied';

  @override
  String get masteredShort => 'Mastered';

  @override
  String studiedStats(int studied, int total, int mastered) {
    return 'Studied $studied/$total · Mastered $mastered';
  }

  @override
  String get questionNotFound => 'Question not found.';

  @override
  String get review => 'Review';

  @override
  String get theoryLearning => 'Theory';

  @override
  String get learningComplete => 'Complete';

  @override
  String get correctAnswer => 'Correct!';

  @override
  String get wrongAnswer => 'Incorrect';

  @override
  String get quiz => 'Quiz';

  @override
  String get showHint => 'Show Hint';

  @override
  String get imageLoadFailed => 'Failed to load image';

  @override
  String get sourceDocument => 'Source';

  @override
  String get newShort => 'New';

  @override
  String itemCount(int count) {
    return '$count';
  }

  @override
  String get premium => 'Premium';

  @override
  String get removeAds => 'Remove Ads';

  @override
  String get premiumActivated => 'Premium activated';

  @override
  String get purchase => 'Purchase';

  @override
  String get restorePurchases => 'Restore Purchases';

  @override
  String get purchaseFailed => 'Purchase failed';

  @override
  String get purchasesRestored => 'Purchases restored';

  @override
  String get productNotAvailable => 'Product not available';
}
