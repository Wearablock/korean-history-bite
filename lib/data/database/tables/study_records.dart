import 'package:drift/drift.dart';

/// 학습 기록 테이블
/// 각 문제별 학습 상태와 스페이스드 리피티션 정보를 저장
@DataClassName('StudyRecord')
class StudyRecords extends Table {
  /// 레코드 고유 ID (Auto Increment)
  IntColumn get id => integer().autoIncrement()();

  /// 문제 ID (questions_meta.json의 id와 일치)
  TextColumn get questionId => text()();

  /// 챕터 ID (역정규화, 조회 최적화용)
  TextColumn get chapterId => text()();

  /// 시대 ID (역정규화, 통계용)
  TextColumn get eraId => text()();

  /// 학습 레벨 (0: 신규, 1-4: 학습중, 5: 완전습득)
  IntColumn get level => integer().withDefault(const Constant(0))();

  /// 누적 정답 횟수
  IntColumn get correctCount => integer().withDefault(const Constant(0))();

  /// 누적 오답 횟수
  IntColumn get wrongCount => integer().withDefault(const Constant(0))();

  /// 마지막 학습 시간
  DateTimeColumn get lastStudiedAt => dateTime().nullable()();

  /// 다음 복습 예정 시간
  DateTimeColumn get nextReviewAt => dateTime().nullable()();

  /// 레코드 생성 시간
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// 레코드 수정 시간
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {questionId},
      ];
}
