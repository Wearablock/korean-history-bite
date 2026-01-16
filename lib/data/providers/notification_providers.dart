// lib/data/providers/notification_providers.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/notification_service.dart';
import 'database_providers.dart';

// ============================================================
// 알림 서비스 Provider
// ============================================================

/// NotificationService 싱글톤 인스턴스
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// ============================================================
// 알림 설정 상태 Providers
// ============================================================

/// 알림 활성화 상태
final notificationEnabledProvider = FutureProvider<bool>((ref) async {
  final dao = ref.watch(userSettingsDaoProvider);
  return dao.getNotificationEnabled();
});

/// 알림 시간
final notificationTimeProvider = FutureProvider<TimeOfDay>((ref) async {
  final dao = ref.watch(userSettingsDaoProvider);
  return dao.getNotificationTime();
});

/// 알림 권한 상태
final notificationPermissionProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(notificationServiceProvider);
  return service.hasPermission();
});

// ============================================================
// 알림 설정 상태 클래스
// ============================================================

/// 알림 설정 상태
@immutable
class NotificationSettingsState {
  final bool isLoading;
  final String? error;

  const NotificationSettingsState({
    this.isLoading = false,
    this.error,
  });

  NotificationSettingsState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return NotificationSettingsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ============================================================
// 알림 설정 Notifier
// ============================================================

/// 알림 설정 관리 Notifier
class NotificationSettingsNotifier extends Notifier<NotificationSettingsState> {
  @override
  NotificationSettingsState build() {
    return const NotificationSettingsState();
  }

  /// 알림 활성화/비활성화
  Future<bool> setEnabled(bool enabled) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final dao = ref.read(userSettingsDaoProvider);
      final notificationService = ref.read(notificationServiceProvider);

      if (enabled) {
        // 권한 요청
        final hasPermission = await notificationService.requestPermission();
        if (!hasPermission) {
          state = state.copyWith(
            isLoading: false,
            error: '알림 권한이 필요합니다. 설정에서 알림을 허용해주세요.',
          );
          return false;
        }

        // 알림 스케줄링
        final time = await dao.getNotificationTime();
        await notificationService.scheduleDailyReminder(
          hour: time.hour,
          minute: time.minute,
        );
      } else {
        // 알림 취소
        await notificationService.cancelDailyReminder();
      }

      // 설정 저장
      await dao.setNotificationEnabled(enabled);

      // Provider 갱신
      ref.invalidate(notificationEnabledProvider);
      ref.invalidate(notificationPermissionProvider);

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '알림 설정 중 오류가 발생했습니다.',
      );
      return false;
    }
  }

  /// 알림 시간 변경
  Future<bool> setTime(TimeOfDay time) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final dao = ref.read(userSettingsDaoProvider);
      final notificationService = ref.read(notificationServiceProvider);

      // 설정 저장
      await dao.setNotificationTime(time);

      // 알림이 활성화된 경우에만 재스케줄링
      final enabled = await dao.getNotificationEnabled();
      if (enabled) {
        await notificationService.scheduleDailyReminder(
          hour: time.hour,
          minute: time.minute,
        );
      }

      // Provider 갱신
      ref.invalidate(notificationTimeProvider);

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '알림 시간 설정 중 오류가 발생했습니다.',
      );
      return false;
    }
  }

  /// 테스트 알림 전송
  Future<void> sendTestNotification() async {
    final notificationService = ref.read(notificationServiceProvider);
    await notificationService.showTestNotification();
  }

  /// 에러 초기화
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// 알림 설정 Notifier Provider
final notificationSettingsNotifierProvider =
    NotifierProvider<NotificationSettingsNotifier, NotificationSettingsState>(
  NotificationSettingsNotifier.new,
);
