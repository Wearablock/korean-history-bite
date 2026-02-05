import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'data/database/app_database.dart';
import 'firebase_options.dart';
import 'services/ad_service.dart';
import 'services/iap_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Crashlytics 설정
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  // ATT 권한 요청 (iOS 14.5+) - AdMob 초기화 전에 호출해야 함
  if (Platform.isIOS) {
    await Future.delayed(const Duration(milliseconds: 200));
    await AppTrackingTransparency.requestTrackingAuthorization();
  }

  // AdMob 초기화
  await MobileAds.instance.initialize();

  // 전면/보상형 광고 미리 로드
  AdService().preloadAds();

  // IAP 초기화
  await IAPService().initialize();

  // 앱 설정 초기화 (버전 정보 등)
  await AppConfig.initialize();

  // 알림 서비스 초기화
  await NotificationService().initialize();

  // 저장된 알림 설정 복원
  await _restoreNotificationSettings();

  runApp(
    const ProviderScope(
      child: KoreanHistoryApp(),
    ),
  );
}

/// 저장된 알림 설정 복원 (앱 재시작 시)
Future<void> _restoreNotificationSettings() async {
  try {
    final db = AppDatabase();
    final enabled = await db.userSettingsDao.getNotificationEnabled();

    if (enabled) {
      final time = await db.userSettingsDao.getNotificationTime();
      await NotificationService().scheduleDailyReminder(
        hour: time.hour,
        minute: time.minute,
      );
      debugPrint('알림 설정 복원 완료: ${time.hour}:${time.minute}');
    }
  } catch (e) {
    debugPrint('알림 설정 복원 실패: $e');
  }
}
