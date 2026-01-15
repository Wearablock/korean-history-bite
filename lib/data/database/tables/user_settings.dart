import 'package:drift/drift.dart';

/// 사용자 설정 테이블
/// Key-Value 형식으로 앱 설정을 저장
@DataClassName('UserSetting')
class UserSettings extends Table {
  /// 설정 키 (Primary Key)
  TextColumn get key => text()();

  /// 설정 값 (문자열, JSON 등)
  TextColumn get value => text().nullable()();

  /// 마지막 수정 시간
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {key};
}
