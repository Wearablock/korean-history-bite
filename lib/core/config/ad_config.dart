import 'dart:io';

import 'package:flutter/foundation.dart';

/// 광고 설정
class AdConfig {
  AdConfig._();

  /// 스크린샷 모드 (true: 광고/디버그패널 숨김)
  static const bool screenshotMode = false;

  /// 광고 활성화 여부
  static bool get adsEnabled => !screenshotMode;

  /// 테스트 모드 여부 (릴리즈 빌드 시 자동으로 false)
  static bool get isTestMode => kDebugMode;

  // ============================================================
  // 전면 광고 (Interstitial) 설정
  // ============================================================

  /// 전면 광고 최소 간격 (초)
  static const int interstitialMinIntervalSeconds = 60;

  // ============================================================
  // 배너 광고 (Banner) 설정
  // ============================================================

  /// 홈 화면 배너 표시 여부
  static const bool showBannerOnHome = true;

  /// 진행률 화면 배너 표시 여부
  static const bool showBannerOnProgress = true;

  /// 설정 화면 배너 표시 여부
  static const bool showBannerOnSettings = true;

  // ============================================================
  // 보상형 광고 (Rewarded) 설정
  // ============================================================

  /// 보상형 광고 시청 시 추가 문제 수
  static const int rewardedAdBonusQuestions = 5;

  // ============================================================
  // 테스트 광고 ID (Google 공식 테스트 ID)
  // ============================================================

  // 배너 광고
  static const String _testBannerAdUnitIdAndroid =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _testBannerAdUnitIdIOS =
      'ca-app-pub-3940256099942544/2934735716';

  // 전면 광고
  static const String _testInterstitialAdUnitIdAndroid =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testInterstitialAdUnitIdIOS =
      'ca-app-pub-3940256099942544/4411468910';

  // 보상형 광고
  static const String _testRewardedAdUnitIdAndroid =
      'ca-app-pub-3940256099942544/5224354917';
  static const String _testRewardedAdUnitIdIOS =
      'ca-app-pub-3940256099942544/1712485313';

  // ============================================================
  // 실제 광고 ID (배포 시 교체)
  // ============================================================

  // 배너 광고
  static const String _prodBannerAdUnitIdAndroid =
      'ca-app-pub-8841058711613546/7463447570';
  static const String _prodBannerAdUnitIdIOS =
      'ca-app-pub-8841058711613546/7995776523';

  // 전면 광고
  static const String _prodInterstitialAdUnitIdAndroid =
      'ca-app-pub-8841058711613546/3388471192';
  static const String _prodInterstitialAdUnitIdIOS =
      'ca-app-pub-8841058711613546/3617547811';

  // 보상형 광고
  static const String _prodRewardedAdUnitIdAndroid =
      'ca-app-pub-8841058711613546/7424737361';
  static const String _prodRewardedAdUnitIdIOS =
      'ca-app-pub-8841058711613546/3436572659';

  // ============================================================
  // 광고 ID Getter (플랫폼 & 모드 자동 판별)
  // ============================================================

  /// 배너 광고 ID
  static String get bannerAdUnitId {
    if (isTestMode) {
      return Platform.isAndroid
          ? _testBannerAdUnitIdAndroid
          : _testBannerAdUnitIdIOS;
    }
    return Platform.isAndroid
        ? _prodBannerAdUnitIdAndroid
        : _prodBannerAdUnitIdIOS;
  }

  /// 전면 광고 ID
  static String get interstitialAdUnitId {
    if (isTestMode) {
      return Platform.isAndroid
          ? _testInterstitialAdUnitIdAndroid
          : _testInterstitialAdUnitIdIOS;
    }
    return Platform.isAndroid
        ? _prodInterstitialAdUnitIdAndroid
        : _prodInterstitialAdUnitIdIOS;
  }

  /// 보상형 광고 ID
  static String get rewardedAdUnitId {
    if (isTestMode) {
      return Platform.isAndroid
          ? _testRewardedAdUnitIdAndroid
          : _testRewardedAdUnitIdIOS;
    }
    return Platform.isAndroid
        ? _prodRewardedAdUnitIdAndroid
        : _prodRewardedAdUnitIdIOS;
  }
}
