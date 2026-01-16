import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import '../../../core/config/constants.dart';
import '../../../core/config/setting_keys.dart';
import '../app_database.dart';
import '../tables/user_settings.dart';

part 'user_settings_dao.g.dart';

@DriftAccessor(tables: [UserSettings])
class UserSettingsDao extends DatabaseAccessor<AppDatabase>
    with _$UserSettingsDaoMixin {
  UserSettingsDao(super.db);

  // ============================================================
  // 기본 CRUD 연산
  // ============================================================

  /// 모든 설정 조회
  Future<List<UserSetting>> getAllSettings() => select(userSettings).get();

  /// 특정 키의 설정값 조회
  Future<String?> getValue(String key) async {
    final setting = await (select(userSettings)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return setting?.value;
  }

  /// 설정값 저장 (Upsert)
  Future<void> setValue(String key, String? value) {
    return into(userSettings).insertOnConflictUpdate(
      UserSettingsCompanion(
        key: Value(key),
        value: Value(value),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// 설정 삭제
  Future<int> deleteKey(String key) {
    return (delete(userSettings)..where((t) => t.key.equals(key))).go();
  }

  /// 모든 설정 삭제 (초기화)
  Future<int> deleteAll() => delete(userSettings).go();

  // ============================================================
  // 타입별 Getter/Setter
  // ============================================================

  /// 정수형 설정값 조회
  Future<int> getInt(String key, {int defaultValue = 0}) async {
    final value = await getValue(key);
    if (value == null) return defaultValue;
    return int.tryParse(value) ?? defaultValue;
  }

  /// 정수형 설정값 저장
  Future<void> setInt(String key, int value) {
    return setValue(key, value.toString());
  }

  /// 불린형 설정값 조회
  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    final value = await getValue(key);
    if (value == null) return defaultValue;
    return value.toLowerCase() == 'true';
  }

  /// 불린형 설정값 저장
  Future<void> setBool(String key, bool value) {
    return setValue(key, value.toString());
  }

  /// 문자열 설정값 조회 (기본값 지원)
  Future<String> getString(String key, {String defaultValue = ''}) async {
    final value = await getValue(key);
    return value ?? defaultValue;
  }

  /// 문자열 설정값 저장
  Future<void> setString(String key, String value) {
    return setValue(key, value);
  }

  // ============================================================
  // 학습 설정 전용 메서드
  // ============================================================

  /// 일일 학습 목표 조회 (챕터 수)
  Future<int> getDailyGoal() async {
    return getInt(
        SettingKeys.dailyGoal, defaultValue: StudyConstants.defaultDailyGoal);
  }

  /// 일일 학습 목표 설정 (챕터 수)
  Future<void> setDailyGoal(int chapterCount) {
    // 1~5 챕터 범위로 제한
    final validCount = chapterCount.clamp(1, StudyConstants.maxDailyGoalChapters);
    return setInt(SettingKeys.dailyGoal, validCount);
  }

  /// 복습 우선 설정 조회
  Future<bool> getReviewPriority() async {
    return getBool(SettingKeys.reviewPriority, defaultValue: true);
  }

  /// 복습 우선 설정 변경
  Future<void> setReviewPriority(bool enabled) {
    return setBool(SettingKeys.reviewPriority, enabled);
  }

  // ============================================================
  // 알림 설정 전용 메서드
  // ============================================================

  /// 알림 활성화 여부 조회
  Future<bool> getNotificationEnabled() async {
    return getBool(SettingKeys.notificationEnabled, defaultValue: false);
  }

  /// 알림 활성화 설정
  Future<void> setNotificationEnabled(bool enabled) {
    return setBool(SettingKeys.notificationEnabled, enabled);
  }

  /// 알림 시간 조회 (기본값: 20:00)
  Future<TimeOfDay> getNotificationTime() async {
    final hour = await getInt(SettingKeys.notificationHour, defaultValue: 20);
    final minute =
        await getInt(SettingKeys.notificationMinute, defaultValue: 0);
    return TimeOfDay(hour: hour, minute: minute);
  }

  /// 알림 시간 저장
  Future<void> setNotificationTime(TimeOfDay time) async {
    await setInt(SettingKeys.notificationHour, time.hour);
    await setInt(SettingKeys.notificationMinute, time.minute);
  }

  // ============================================================
  // 테마 설정 전용 메서드
  // ============================================================

  /// 테마 모드 조회
  Future<String> getThemeMode() async {
    return getString(SettingKeys.themeMode, defaultValue: 'system');
  }

  /// 테마 모드 설정
  Future<void> setThemeMode(String mode) {
    // 유효한 값만 허용
    final validMode =
        ['system', 'light', 'dark'].contains(mode) ? mode : 'system';
    return setString(SettingKeys.themeMode, validMode);
  }

  // ============================================================
  // 언어 설정 전용 메서드
  // ============================================================

  /// 앱 언어 조회
  Future<String> getLocale() async {
    return getString(SettingKeys.locale, defaultValue: 'ko');
  }

  /// 앱 언어 설정
  Future<void> setLocale(String locale) {
    return setString(SettingKeys.locale, locale);
  }

  /// 콘텐츠 언어 조회
  Future<String> getContentLocale() async {
    return getString(SettingKeys.contentLocale, defaultValue: 'ko');
  }

  /// 콘텐츠 언어 설정
  Future<void> setContentLocale(String locale) {
    return setString(SettingKeys.contentLocale, locale);
  }

  // ============================================================
  // 프리미엄 관련 메서드
  // ============================================================

  /// 프리미엄 여부 조회
  Future<bool> isPremium() async {
    return getBool(SettingKeys.isPremium, defaultValue: false);
  }

  /// 프리미엄 활성화
  Future<void> activatePremium() async {
    await setBool(SettingKeys.isPremium, true);
    await setString(
        SettingKeys.premiumPurchasedAt, DateTime.now().toIso8601String());
  }

  /// 프리미엄 비활성화 (환불 등)
  Future<void> deactivatePremium() {
    return setBool(SettingKeys.isPremium, false);
  }

  // ============================================================
  // 앱 상태 관련 메서드
  // ============================================================

  /// 최초 실행 여부 확인
  Future<bool> isFirstLaunch() async {
    final date = await getValue(SettingKeys.firstLaunchDate);
    return date == null;
  }

  /// 최초 실행 기록
  Future<void> recordFirstLaunch() {
    return setString(
        SettingKeys.firstLaunchDate, DateTime.now().toIso8601String());
  }

  /// 온보딩 완료 여부 조회
  Future<bool> isOnboardingCompleted() async {
    return getBool(SettingKeys.onboardingCompleted, defaultValue: false);
  }

  /// 온보딩 완료 기록
  Future<void> completeOnboarding() {
    return setBool(SettingKeys.onboardingCompleted, true);
  }

  // ============================================================
  // 리뷰 요청 관련 메서드
  // ============================================================

  /// 리뷰 요청 가능 여부 확인
  Future<bool> canRequestReview() async {
    final lastPrompt = await getValue(SettingKeys.lastReviewPrompt);
    final promptCount =
        await getInt(SettingKeys.reviewPromptCount, defaultValue: 0);

    // 최대 3회까지만 요청
    if (promptCount >= 3) return false;

    // 마지막 요청 후 7일 경과 확인
    if (lastPrompt != null) {
      final lastDate = DateTime.tryParse(lastPrompt);
      if (lastDate != null) {
        final daysSinceLastPrompt = DateTime.now().difference(lastDate).inDays;
        if (daysSinceLastPrompt < 7) return false;
      }
    }

    return true;
  }

  /// 리뷰 요청 기록
  Future<void> recordReviewPrompt() async {
    final currentCount =
        await getInt(SettingKeys.reviewPromptCount, defaultValue: 0);
    await setInt(SettingKeys.reviewPromptCount, currentCount + 1);
    await setString(
        SettingKeys.lastReviewPrompt, DateTime.now().toIso8601String());
  }

  // ============================================================
  // 일괄 설정 관련
  // ============================================================

  /// 기본값으로 초기화
  Future<void> resetToDefaults() async {
    await deleteAll();
    await setInt(SettingKeys.dailyGoal, StudyConstants.defaultDailyGoal);
    await setBool(SettingKeys.reviewPriority, true);
    await setBool(SettingKeys.shuffleOptions, true);
    await setBool(SettingKeys.showExplanation, true);
    await setBool(SettingKeys.notificationEnabled, false);
    await setInt(SettingKeys.notificationHour, 20);
    await setInt(SettingKeys.notificationMinute, 0);
    await setBool(SettingKeys.streakReminder, true);
    await setString(SettingKeys.themeMode, 'system');
    await setString(SettingKeys.locale, 'ko');
    await setString(SettingKeys.contentLocale, 'ko');
  }

  /// 모든 설정을 Map으로 내보내기
  Future<Map<String, String?>> exportSettings() async {
    final settings = await getAllSettings();
    return {for (var s in settings) s.key: s.value};
  }

  /// Map에서 설정 가져오기
  Future<void> importSettings(Map<String, String?> settings) async {
    for (final entry in settings.entries) {
      await setValue(entry.key, entry.value);
    }
  }

  // ============================================================
  // Stream (실시간 감지)
  // ============================================================

  /// 특정 설정 변경 감지
  Stream<String?> watchValue(String key) {
    return (select(userSettings)..where((t) => t.key.equals(key)))
        .watchSingleOrNull()
        .map((setting) => setting?.value);
  }

  /// 테마 모드 변경 감지
  Stream<String> watchThemeMode() {
    return watchValue(SettingKeys.themeMode).map((value) => value ?? 'system');
  }

  /// 언어 변경 감지
  Stream<String> watchLocale() {
    return watchValue(SettingKeys.locale).map((value) => value ?? 'ko');
  }
}
