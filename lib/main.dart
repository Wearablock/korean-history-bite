import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Crashlytics 설정
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  // AdMob 초기화
  await MobileAds.instance.initialize();

  // 앱 설정 초기화 (버전 정보 등)
  await AppConfig.initialize();

  runApp(
    const ProviderScope(
      child: KoreanHistoryApp(),
    ),
  );
}
