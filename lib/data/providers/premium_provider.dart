// lib/data/providers/premium_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../services/iap_service.dart';

/// 프리미엄 구매 여부 (광고 제거)
final isPremiumProvider = StateProvider<bool>((ref) {
  return IAPService().isPremium;
});

/// IAP 서비스 Provider
final iapServiceProvider = Provider<IAPService>((ref) {
  final service = IAPService();

  // 프리미엄 상태 변경 시 Provider 업데이트
  service.onPremiumStatusChanged = (isPremium) {
    ref.read(isPremiumProvider.notifier).state = isPremium;
  };

  return service;
});

/// 광고 제거 상품 정보
final removeAdsProductProvider = Provider<ProductDetails?>((ref) {
  ref.watch(iapServiceProvider);
  return IAPService().removeAdsProduct;
});

/// IAP 사용 가능 여부
final isIAPAvailableProvider = Provider<bool>((ref) {
  ref.watch(iapServiceProvider);
  return IAPService().isAvailable;
});
