// lib/services/ad_service.dart

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../core/config/ad_config.dart';

/// 광고 서비스 (전면/보상형 광고 관리)
class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  // ============================================================
  // 전면 광고 (Interstitial)
  // ============================================================

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;
  DateTime? _lastInterstitialShowTime;

  /// 전면 광고 미리 로드
  void loadInterstitialAd() {
    if (!AdConfig.adsEnabled) return;

    InterstitialAd.load(
      adUnitId: AdConfig.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isInterstitialAdReady = false;
              loadInterstitialAd(); // 다음 광고 미리 로드
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('전면 광고 표시 실패: $error');
              ad.dispose();
              _isInterstitialAdReady = false;
              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('전면 광고 로드 실패: $error');
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  /// 전면 광고 표시 (최소 간격 체크)
  Future<void> showInterstitialAd() async {
    // 최소 간격 체크
    if (_lastInterstitialShowTime != null) {
      final elapsed = DateTime.now().difference(_lastInterstitialShowTime!);
      if (elapsed.inSeconds < AdConfig.interstitialMinIntervalSeconds) {
        debugPrint('전면 광고 최소 간격 미충족');
        return;
      }
    }

    if (_isInterstitialAdReady && _interstitialAd != null) {
      _lastInterstitialShowTime = DateTime.now();
      await _interstitialAd!.show();
    } else {
      debugPrint('전면 광고가 준비되지 않음');
    }
  }

  /// 전면 광고 준비 여부
  bool get isInterstitialAdReady => _isInterstitialAdReady;

  // ============================================================
  // 보상형 광고 (Rewarded)
  // ============================================================

  RewardedAd? _rewardedAd;
  bool _isRewardedAdReady = false;

  /// 보상형 광고 미리 로드
  void loadRewardedAd() {
    if (!AdConfig.adsEnabled) return;

    RewardedAd.load(
      adUnitId: AdConfig.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdReady = true;
        },
        onAdFailedToLoad: (error) {
          debugPrint('보상형 광고 로드 실패: $error');
          _isRewardedAdReady = false;
        },
      ),
    );
  }

  /// 보상형 광고 표시 (콜백으로 보상 지급)
  Future<bool> showRewardedAd({
    required Function(RewardItem reward) onRewarded,
  }) async {
    if (!_isRewardedAdReady || _rewardedAd == null) {
      debugPrint('보상형 광고가 준비되지 않음');
      return false;
    }

    bool rewarded = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _isRewardedAdReady = false;
        loadRewardedAd(); // 다음 광고 미리 로드
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('보상형 광고 표시 실패: $error');
        ad.dispose();
        _isRewardedAdReady = false;
        loadRewardedAd();
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        rewarded = true;
        onRewarded(reward);
      },
    );

    return rewarded;
  }

  /// 보상형 광고 준비 여부
  bool get isRewardedAdReady => _isRewardedAdReady;

  // ============================================================
  // 초기화
  // ============================================================

  /// 모든 광고 미리 로드
  void preloadAds() {
    loadInterstitialAd();
    loadRewardedAd();
  }

  /// 리소스 정리
  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
