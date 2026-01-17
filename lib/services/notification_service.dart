import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// 학습 리마인더 알림 서비스
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // 알림 채널 ID (Android)
  static const String _channelId = 'study_reminder';

  // 알림 텍스트 (l10n에서 설정)
  String _channelName = 'Study Reminder';
  String _channelDescription = 'Daily study time reminders';
  String _notificationTitle = 'Korean History Bite';
  String _notificationBody = 'Time to start today\'s study!';

  // 고정 알림 ID
  static const int _dailyReminderId = 1;

  bool _isInitialized = false;

  /// 초기화 여부 확인
  bool get isInitialized => _isInitialized;

  /// l10n 문자열 설정 (앱 시작 시 또는 언어 변경 시 호출)
  void setLocalizedStrings({
    required String channelName,
    required String channelDescription,
    required String notificationTitle,
    required String notificationBody,
  }) {
    _channelName = channelName;
    _channelDescription = channelDescription;
    _notificationTitle = notificationTitle;
    _notificationBody = notificationBody;
  }

  /// 알림 서비스 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    // 시간대 초기화
    tz.initializeTimeZones();
    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      // flutter_timezone 5.x returns TimezoneInfo object with identifier property
      final String timeZoneName = timezoneInfo.identifier;
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      // 시간대를 가져올 수 없는 경우 기본값 사용
      debugPrint('시간대 설정 실패, 기본값 사용: $e');
      tz.setLocalLocation(tz.getLocation('Asia/Seoul'));
    }

    // Android 설정
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS 설정
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Android 알림 채널 생성
    await _createNotificationChannel();

    _isInitialized = true;
    debugPrint('NotificationService 초기화 완료');
  }

  /// Android 알림 채널 생성
  Future<void> _createNotificationChannel() async {
    final androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  /// 알림 권한 요청
  Future<bool> requestPermission() async {
    if (Platform.isIOS) {
      final iosPlugin = _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      final granted = await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    if (Platform.isAndroid) {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      // Android 13+ 권한 요청
      final granted = await androidPlugin?.requestNotificationsPermission();
      return granted ?? true; // Android 12 이하는 권한 불필요
    }

    return true;
  }

  /// 알림 권한 확인
  Future<bool> hasPermission() async {
    if (Platform.isIOS) {
      final iosPlugin = _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      final settings = await iosPlugin?.checkPermissions();
      return settings?.isEnabled ?? false;
    }

    if (Platform.isAndroid) {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final granted = await androidPlugin?.areNotificationsEnabled();
      return granted ?? true;
    }

    return true;
  }

  /// 매일 반복 알림 스케줄링
  ///
  /// [hour] 알림 시간 (0-23)
  /// [minute] 알림 분 (0-59)
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    if (!_isInitialized) {
      debugPrint('NotificationService가 초기화되지 않았습니다');
      return;
    }

    // 기존 알림 취소
    await cancelDailyReminder();

    // 알림 상세 설정
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // 다음 알림 시간 계산
    final scheduledTime = _nextInstanceOfTime(hour, minute);

    // 매일 반복 알림 스케줄링
    await _notifications.zonedSchedule(
      _dailyReminderId,
      _notificationTitle,
      _notificationBody,
      scheduledTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // 매일 같은 시간에 반복
    );

    debugPrint('알림 스케줄됨: $hour:$minute (다음 알림: $scheduledTime)');
  }

  /// 매일 알림 취소
  Future<void> cancelDailyReminder() async {
    await _notifications.cancel(_dailyReminderId);
    debugPrint('알림 취소됨');
  }

  /// 모든 알림 취소
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  /// 다음 알림 시간 계산
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // 이미 지난 시간이면 다음 날로 설정
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// 알림 탭 처리
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('알림 탭됨: ${response.payload}');
    // TODO: 앱 내 특정 화면으로 이동 (필요시 구현)
  }

  /// 테스트용 즉시 알림
  Future<void> showTestNotification() async {
    if (!_isInitialized) {
      debugPrint('NotificationService가 초기화되지 않았습니다');
      return;
    }

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      0,
      _notificationTitle,
      _notificationBody,
      notificationDetails,
    );
  }

  /// 예약된 알림 목록 조회 (디버그용)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
