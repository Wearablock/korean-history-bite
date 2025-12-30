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
  String get startStudy => 'Start Today\'s Study';

  @override
  String get continueStudy => 'Continue Study';

  @override
  String get todayStudy => 'Today\'s Study';

  @override
  String questionsCompleted(int completed, int total) {
    return '$completed of $total questions completed';
  }

  @override
  String streakDays(int days) {
    return '$days day streak!';
  }

  @override
  String get wrongReview => 'Wrong Review';

  @override
  String get spacedReview => 'Review';

  @override
  String get newLearning => 'New';

  @override
  String get correct => 'Correct';

  @override
  String get wrong => 'Wrong';

  @override
  String get nextQuestion => 'Next Question';

  @override
  String get sessionComplete => 'Today\'s Study Complete!';

  @override
  String accuracyRate(int rate) {
    return 'Accuracy: $rate%';
  }

  @override
  String get goHome => 'Go Home';

  @override
  String get additionalStudy => 'Study More';
}
