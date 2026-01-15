import 'package:drift/drift.dart';

/// 오답 기록 테이블
/// 틀린 문제의 상세 정보를 저장
@DataClassName('WrongAnswer')
class WrongAnswers extends Table {
  /// 레코드 고유 ID (Auto Increment)
  IntColumn get id => integer().autoIncrement()();

  /// 문제 ID (고유)
  TextColumn get questionId => text()();

  /// 챕터 ID (역정규화)
  TextColumn get chapterId => text()();

  /// 시대 ID (역정규화)
  TextColumn get eraId => text()();

  /// 틀린 총 횟수
  IntColumn get wrongCount => integer().withDefault(const Constant(1))();

  /// 마지막으로 선택한 오답
  TextColumn get lastWrongAnswer => text().nullable()();

  /// 마지막으로 틀린 시간
  DateTimeColumn get wrongAt => dateTime()();

  /// 정답으로 맞춘 시간 (복습 완료)
  DateTimeColumn get correctedAt => dateTime().nullable()();

  /// 최초 오답 등록 시간
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// 레코드 수정 시간
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {questionId},
      ];
}
