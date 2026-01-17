// lib/features/settings/widgets/notification_settings_tile.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:korean_history_bite/l10n/app_localizations.dart';
import '../../../data/providers/notification_providers.dart';

/// 알림 설정 타일 위젯
class NotificationSettingsTile extends ConsumerWidget {
  const NotificationSettingsTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final enabledAsync = ref.watch(notificationEnabledProvider);
    final timeAsync = ref.watch(notificationTimeProvider);
    final settingsState = ref.watch(notificationSettingsNotifierProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 알림 ON/OFF 스위치
        enabledAsync.when(
          loading: () => ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: Text(l10n.studyNotification),
            trailing: const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          error: (e, _) => ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: Text(l10n.studyNotification),
            subtitle: Text(
              l10n.error(e.toString()),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
          data: (enabled) => SwitchListTile(
            secondary: Icon(
              enabled
                  ? Icons.notifications_active
                  : Icons.notifications_outlined,
              color: enabled ? Theme.of(context).colorScheme.primary : null,
            ),
            title: Text(l10n.studyNotification),
            subtitle: Text(enabled ? l10n.dailyNotification : l10n.notificationOff),
            value: enabled,
            onChanged: settingsState.isLoading
                ? null
                : (value) {
                    ref
                        .read(notificationSettingsNotifierProvider.notifier)
                        .setEnabled(value);
                  },
          ),
        ),

        // 알림 시간 설정 (알림이 켜진 경우에만 표시)
        enabledAsync.maybeWhen(
          data: (enabled) {
            if (!enabled) return const SizedBox.shrink();

            return timeAsync.when(
              loading: () => ListTile(
                leading: const SizedBox(width: 24),
                title: Text(l10n.notificationTime),
                trailing: const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (e, _) => ListTile(
                leading: const SizedBox(width: 24),
                title: Text(l10n.notificationTime),
                subtitle: Text(
                  l10n.error(e.toString()),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
              data: (time) => ListTile(
                leading: const SizedBox(width: 24), // 인덴트
                title: Text(l10n.notificationTime),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(time, l10n),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                onTap: settingsState.isLoading
                    ? null
                    : () => _showTimePicker(context, ref, time, l10n),
              ),
            );
          },
          orElse: () => const SizedBox.shrink(),
        ),

        // 에러 메시지 표시
        if (settingsState.error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 16,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    settingsState.error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: () {
                    ref
                        .read(notificationSettingsNotifierProvider.notifier)
                        .clearError();
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// 시간 포맷팅
  String _formatTime(TimeOfDay time, AppLocalizations l10n) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');

    if (hour == 0) {
      return l10n.amTime(12, minute);
    } else if (hour < 12) {
      return l10n.amTime(hour, minute);
    } else if (hour == 12) {
      return l10n.pmTime(12, minute);
    } else {
      return l10n.pmTime(hour - 12, minute);
    }
  }

  /// 시간 선택 다이얼로그 표시
  Future<void> _showTimePicker(
    BuildContext context,
    WidgetRef ref,
    TimeOfDay currentTime,
    AppLocalizations l10n,
  ) async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: currentTime,
      helpText: l10n.selectNotificationTime,
      cancelText: l10n.cancel,
      confirmText: l10n.confirm,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (selectedTime != null && selectedTime != currentTime) {
      ref
          .read(notificationSettingsNotifierProvider.notifier)
          .setTime(selectedTime);
    }
  }
}
