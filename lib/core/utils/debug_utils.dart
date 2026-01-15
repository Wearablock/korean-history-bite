// lib/core/utils/debug_utils.dart

import 'package:flutter/foundation.dart';

/// 디버그용 유틸리티 클래스
/// 시뮬레이터에서 망각곡선 복습 테스트를 위한 시간 조작 기능 제공
class DebugUtils {
  DebugUtils._();

  /// 현재 시간 오버라이드 (테스트용)
  static DateTime? _overrideNow;

  /// 현재 시간 반환 (오버라이드 있으면 오버라이드 값, 없으면 실제 시간)
  static DateTime get now => _overrideNow ?? DateTime.now();

  /// 시간 점프 (n일 후로 이동)
  /// 릴리스 빌드에서는 동작하지 않음
  static void jumpDays(int days) {
    if (kDebugMode) {
      _overrideNow = DateTime.now().add(Duration(days: days));
      debugPrint('[DebugUtils] 시간 점프: $days일 후 (${_overrideNow})');
    }
  }

  /// 특정 날짜로 설정
  static void setDate(DateTime date) {
    if (kDebugMode) {
      _overrideNow = date;
      debugPrint('[DebugUtils] 날짜 설정: $_overrideNow');
    }
  }

  /// 시간 리셋 (실제 시간으로 복귀)
  static void resetTime() {
    if (kDebugMode) {
      _overrideNow = null;
      debugPrint('[DebugUtils] 시간 리셋: 실제 시간으로 복귀');
    }
  }

  /// 현재 오버라이드 상태 확인
  static bool get isTimeOverridden => _overrideNow != null;

  /// 오버라이드된 시간 (없으면 null)
  static DateTime? get overriddenTime => _overrideNow;

  /// 디버그 정보 문자열
  static String get debugInfo {
    if (_overrideNow == null) {
      return '실제 시간 사용 중';
    }
    final diff = _overrideNow!.difference(DateTime.now());
    return '${diff.inDays}일 후로 설정됨 ($_overrideNow)';
  }
}
