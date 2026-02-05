import 'dart:io';

import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

/// 진동 피드백 타입 정의
enum HapticType {
  /// 가벼운 진동 (버튼 탭 등)
  light,

  /// 중간 진동 (일반 피드백)
  medium,

  /// 강한 진동 (중요 알림)
  heavy,

  /// 성공 진동 (짧은 2회)
  success,

  /// 에러 진동 (긴 1회)
  error,

  /// 경고 진동 (빠른 3회)
  warning,

  /// 선택 변경 진동 (미세한 클릭감)
  selection,
}

/// 진동 피드백 서비스
///
/// Singleton 패턴으로 전역에서 동일 인스턴스 사용
class HapticService {
  // Singleton 인스턴스
  static final HapticService _instance = HapticService._internal();
  factory HapticService() => _instance;
  HapticService._internal();

  // 활성화 상태 (설정에서 제어)
  bool _enabled = true;

  // 기기 진동 지원 여부 캐시
  bool? _hasVibrator;

  /// 진동 활성화/비활성화 설정
  void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  /// 현재 활성화 상태 반환
  bool get isEnabled => _enabled;

  /// 진동 기기 지원 여부 확인 (초기화 시 1회 호출 권장)
  Future<bool> checkVibrationSupport() async {
    _hasVibrator ??= await Vibration.hasVibrator();
    return _hasVibrator ?? false;
  }

  /// 진동 피드백 트리거
  Future<void> trigger(HapticType type) async {
    if (!_enabled) return;

    // 진동 지원 여부 확인
    _hasVibrator ??= await Vibration.hasVibrator();
    if (_hasVibrator != true) return;

    switch (type) {
      case HapticType.light:
        await HapticFeedback.lightImpact();

      case HapticType.medium:
        await HapticFeedback.mediumImpact();

      case HapticType.heavy:
        await HapticFeedback.heavyImpact();

      case HapticType.success:
        // iOS는 커스텀 패턴 미지원, HapticFeedback 사용
        if (Platform.isIOS) {
          await HapticFeedback.mediumImpact();
          await Future.delayed(const Duration(milliseconds: 100));
          await HapticFeedback.mediumImpact();
        } else {
          // Android: 짧은 2회 진동 패턴
          await Vibration.vibrate(pattern: [0, 50, 50, 50]);
        }

      case HapticType.error:
        // iOS는 HapticFeedback 사용
        if (Platform.isIOS) {
          await HapticFeedback.heavyImpact();
        } else {
          // Android: 긴 1회 진동
          await Vibration.vibrate(duration: 200);
        }

      case HapticType.warning:
        // iOS는 HapticFeedback 사용
        if (Platform.isIOS) {
          await HapticFeedback.heavyImpact();
        } else {
          // Android: 빠른 3회 진동 패턴
          await Vibration.vibrate(pattern: [0, 30, 30, 30, 30, 30]);
        }

      case HapticType.selection:
        await HapticFeedback.selectionClick();
    }
  }

  /// 진동 취소
  Future<void> cancel() async {
    await Vibration.cancel();
  }
}
