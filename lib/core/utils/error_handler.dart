// lib/core/utils/error_handler.dart

import 'package:flutter/foundation.dart';

/// 에러 핸들링 유틸리티
class ErrorHandler {
  ErrorHandler._();

  /// 에러 로깅 (debug 모드에서만)
  static void log(String context, Object error, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('Error in $context: $error');
      if (stackTrace != null) {
        debugPrint('$stackTrace');
      }
    }
  }

  /// 안전하게 비동기 작업 실행 (에러 시 기본값 반환)
  static Future<T> runSafe<T>({
    required String context,
    required Future<T> Function() action,
    required T fallback,
  }) async {
    try {
      return await action();
    } catch (e, stackTrace) {
      log(context, e, stackTrace);
      return fallback;
    }
  }

  /// 안전하게 동기 작업 실행 (에러 시 기본값 반환)
  static T runSafeSync<T>({
    required String context,
    required T Function() action,
    required T fallback,
  }) {
    try {
      return action();
    } catch (e, stackTrace) {
      log(context, e, stackTrace);
      return fallback;
    }
  }
}
