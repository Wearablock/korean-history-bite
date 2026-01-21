// lib/services/iap_service.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 인앱 결제 서비스
class IAPService {
  static final IAPService _instance = IAPService._internal();
  factory IAPService() => _instance;
  IAPService._internal();

  // ============================================================
  // 상수
  // ============================================================

  /// 광고 제거 상품 ID
  static const String removeAdsProductId = 'korean_history_bite_remove_ads';

  /// 프리미엄 상태 저장 키
  static const String _premiumKey = 'is_premium';

  // ============================================================
  // 상태
  // ============================================================

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  bool _available = false;
  List<ProductDetails> _products = [];
  bool _isPremium = false;
  bool _isLoading = false;

  /// IAP 사용 가능 여부
  bool get isAvailable => _available;

  /// 상품 목록
  List<ProductDetails> get products => _products;

  /// 프리미엄 여부
  bool get isPremium => _isPremium;

  /// 로딩 중 여부
  bool get isLoading => _isLoading;

  /// 광고 제거 상품
  ProductDetails? get removeAdsProduct {
    try {
      return _products.firstWhere((p) => p.id == removeAdsProductId);
    } catch (_) {
      return null;
    }
  }

  /// 프리미엄 상태 변경 콜백
  void Function(bool isPremium)? onPremiumStatusChanged;

  // ============================================================
  // 초기화
  // ============================================================

  /// IAP 초기화
  Future<void> initialize() async {
    // 저장된 프리미엄 상태 로드
    await _loadPremiumStatus();

    // IAP 사용 가능 여부 확인
    _available = await _iap.isAvailable();
    if (!_available) {
      debugPrint('IAP를 사용할 수 없습니다.');
      return;
    }

    // 구매 스트림 구독
    _subscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (error) {
        debugPrint('구매 스트림 오류: $error');
      },
    );

    // 상품 정보 로드
    await _loadProducts();

    // 이전 구매 복원 (앱 시작 시 자동)
    await restorePurchases();
  }

  /// 상품 정보 로드
  Future<void> _loadProducts() async {
    const Set<String> productIds = {removeAdsProductId};

    try {
      final response = await _iap.queryProductDetails(productIds);

      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('찾을 수 없는 상품: ${response.notFoundIDs}');
      }

      _products = response.productDetails;
      debugPrint('로드된 상품: ${_products.map((p) => p.id).toList()}');
    } catch (e) {
      debugPrint('상품 로드 실패: $e');
    }
  }

  /// 저장된 프리미엄 상태 로드
  Future<void> _loadPremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool(_premiumKey) ?? false;
    onPremiumStatusChanged?.call(_isPremium);
  }

  /// 프리미엄 상태 저장
  Future<void> _savePremiumStatus(bool isPremium) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumKey, isPremium);
    _isPremium = isPremium;
    onPremiumStatusChanged?.call(_isPremium);
  }

  // ============================================================
  // 구매
  // ============================================================

  /// 광고 제거 구매
  Future<bool> purchaseRemoveAds() async {
    final product = removeAdsProduct;
    if (product == null) {
      debugPrint('광고 제거 상품을 찾을 수 없습니다.');
      return false;
    }

    try {
      _isLoading = true;
      final purchaseParam = PurchaseParam(productDetails: product);
      return await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      debugPrint('구매 시작 실패: $e');
      return false;
    } finally {
      _isLoading = false;
    }
  }

  /// 구매 업데이트 처리
  Future<void> _handlePurchaseUpdates(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (final purchase in purchaseDetailsList) {
      await _handlePurchase(purchase);
    }
  }

  /// 개별 구매 처리
  Future<void> _handlePurchase(PurchaseDetails purchase) async {
    if (purchase.status == PurchaseStatus.pending) {
      // 결제 대기 중
      _isLoading = true;
      debugPrint('구매 대기 중: ${purchase.productID}');
    } else if (purchase.status == PurchaseStatus.error) {
      // 구매 오류
      _isLoading = false;
      debugPrint('구매 오류: ${purchase.error}');
    } else if (purchase.status == PurchaseStatus.purchased ||
        purchase.status == PurchaseStatus.restored) {
      // 구매 완료 또는 복원
      _isLoading = false;
      if (purchase.productID == removeAdsProductId) {
        await _savePremiumStatus(true);
        debugPrint('광고 제거 활성화됨');
      }
    } else if (purchase.status == PurchaseStatus.canceled) {
      // 구매 취소
      _isLoading = false;
      debugPrint('구매 취소됨: ${purchase.productID}');
    }

    // 구매 완료 처리 (필수!)
    if (purchase.pendingCompletePurchase) {
      await _iap.completePurchase(purchase);
    }
  }

  // ============================================================
  // 복원
  // ============================================================

  /// 이전 구매 복원
  Future<void> restorePurchases() async {
    try {
      _isLoading = true;
      await _iap.restorePurchases();
      debugPrint('구매 복원 요청됨');
    } catch (e) {
      debugPrint('구매 복원 실패: $e');
    } finally {
      _isLoading = false;
    }
  }

  // ============================================================
  // 정리
  // ============================================================

  /// 리소스 정리
  void dispose() {
    _subscription?.cancel();
  }
}
