import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables/study_records.dart';
import 'tables/wrong_answers.dart';
import 'tables/daily_stats.dart';
import 'tables/user_settings.dart';
import 'daos/study_records_dao.dart';
import 'daos/user_settings_dao.dart';
import 'daos/daily_stats_dao.dart';
import 'daos/wrong_answers_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    StudyRecords,
    WrongAnswers,
    DailyStats,
    UserSettings,
  ],
  daos: [
    StudyRecordsDao,
    UserSettingsDao,
    DailyStatsDao,
    WrongAnswersDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  // 싱글톤 인스턴스
  static final AppDatabase _instance = AppDatabase._internal();

  factory AppDatabase() => _instance;

  AppDatabase._internal() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // 향후 스키마 변경 시 마이그레이션 로직 추가
      },
    );
  }

  // DAO 접근자
  @override
  StudyRecordsDao get studyRecordsDao => StudyRecordsDao(this);
  @override
  UserSettingsDao get userSettingsDao => UserSettingsDao(this);
  @override
  DailyStatsDao get dailyStatsDao => DailyStatsDao(this);
  @override
  WrongAnswersDao get wrongAnswersDao => WrongAnswersDao(this);
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'korean_history.db'));
    return NativeDatabase.createInBackground(file);
  });
}
