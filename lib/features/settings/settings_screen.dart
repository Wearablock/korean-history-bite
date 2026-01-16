// lib/features/settings/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/setting_keys.dart';
import '../../core/widgets/collapsing_app_bar_scaffold.dart';
import '../../data/providers/database_providers.dart';
import 'widgets/notification_settings_tile.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CollapsingAppBarScaffold(
      title: '설정',
      body: Column(
        children: [
          // === 학습 섹션 ===
          _buildSectionHeader(context, '학습'),
          _DailyGoalTile(),
          const Divider(height: 1),

          // === 알림 섹션 ===
          _buildSectionHeader(context, '알림'),
          const NotificationSettingsTile(),
          const Divider(height: 1),

          // === 앱 설정 섹션 ===
          _buildSectionHeader(context, '앱 설정'),
          _ThemeModeTile(),
          const Divider(height: 1),

          // === 정보 섹션 ===
          _buildSectionHeader(context, '정보'),
          _buildInfoTile(
            context,
            icon: Icons.info_outline,
            title: '앱 버전',
            trailing: const Text('1.0.0'),
          ),
          const Divider(height: 1),

          // === 데이터 섹션 ===
          _buildSectionHeader(context, '데이터'),
          _buildActionTile(
            context,
            icon: Icons.refresh,
            title: '학습 기록 초기화',
            subtitle: '모든 학습 기록을 삭제합니다',
            onTap: () => _showResetConfirmDialog(context, ref),
            isDestructive: true,
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget trailing,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: trailing,
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? Theme.of(context).colorScheme.error : null;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Future<void> _showResetConfirmDialog(
      BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('학습 기록 초기화'),
        content: const Text(
          '모든 학습 기록이 삭제됩니다.\n이 작업은 되돌릴 수 없습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('초기화'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // TODO: 학습 기록 초기화 로직 구현
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('학습 기록이 초기화되었습니다.')),
      );
    }
  }
}

/// 일일 학습 목표 설정 타일 (챕터 기준)
class _DailyGoalTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dao = ref.watch(userSettingsDaoProvider);

    return FutureBuilder<int>(
      future: dao.getDailyGoal(),
      builder: (context, snapshot) {
        final currentGoal = snapshot.data ?? 1;

        return ListTile(
          leading: const Icon(Icons.flag_outlined),
          title: const Text('일일 학습량'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$currentGoal챕터',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right),
            ],
          ),
          onTap: () => _showDailyGoalDialog(context, ref, currentGoal),
        );
      },
    );
  }

  Future<void> _showDailyGoalDialog(
    BuildContext context,
    WidgetRef ref,
    int currentGoal,
  ) async {
    final selectedGoal = await showDialog<int>(
      context: context,
      builder: (context) => _DailyGoalDialog(currentGoal: currentGoal),
    );

    if (selectedGoal != null && selectedGoal != currentGoal) {
      final dao = ref.read(userSettingsDaoProvider);
      await dao.setDailyGoal(selectedGoal);
      // 강제 리빌드
      ref.invalidate(userSettingsDaoProvider);
    }
  }
}

/// 일일 학습량 선택 다이얼로그
class _DailyGoalDialog extends StatefulWidget {
  final int currentGoal;

  const _DailyGoalDialog({required this.currentGoal});

  @override
  State<_DailyGoalDialog> createState() => _DailyGoalDialogState();
}

class _DailyGoalDialogState extends State<_DailyGoalDialog> {
  late int _selectedGoal;
  bool _isCustom = false;

  @override
  void initState() {
    super.initState();
    _selectedGoal = widget.currentGoal;
    // 기본 옵션에 없으면 커스텀으로 표시
    _isCustom = DailyGoalOption.fromValue(widget.currentGoal) == null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('일일 학습량'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 기본 옵션들
          ...DailyGoalOption.values.map((option) {
            return RadioListTile<int>(
              value: option.chapterCount,
              groupValue: _isCustom ? -1 : _selectedGoal,
              title: Text(option.label),
              dense: true,
              onChanged: (value) {
                setState(() {
                  _selectedGoal = value!;
                  _isCustom = false;
                });
              },
            );
          }),

          // 커스텀 옵션
          RadioListTile<int>(
            value: -1, // 커스텀 식별자
            groupValue: _isCustom ? -1 : _selectedGoal,
            title: const Text('직접 설정'),
            dense: true,
            onChanged: (value) {
              setState(() {
                _isCustom = true;
                if (_selectedGoal < 1 || _selectedGoal > 5) {
                  _selectedGoal = 1;
                }
              });
            },
          ),

          // 커스텀 슬라이더
          if (_isCustom) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text('1'),
                  Expanded(
                    child: Slider(
                      value: _selectedGoal.toDouble(),
                      min: 1,
                      max: 5,
                      divisions: 4,
                      label: '$_selectedGoal챕터',
                      onChanged: (value) {
                        setState(() {
                          _selectedGoal = value.round();
                        });
                      },
                    ),
                  ),
                  const Text('5'),
                ],
              ),
            ),
            Text(
              '$_selectedGoal챕터',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _selectedGoal),
          child: const Text('확인'),
        ),
      ],
    );
  }
}

/// 테마 모드 설정 타일
class _ThemeModeTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dao = ref.watch(userSettingsDaoProvider);

    return FutureBuilder<String>(
      future: dao.getThemeMode(),
      builder: (context, snapshot) {
        final currentMode = snapshot.data ?? 'system';
        final option = ThemeModeOption.fromValue(currentMode);

        return ListTile(
          leading: Icon(_getThemeIcon(currentMode)),
          title: const Text('테마'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                option.label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right),
            ],
          ),
          onTap: () => _showThemeModeDialog(context, ref, currentMode),
        );
      },
    );
  }

  IconData _getThemeIcon(String mode) {
    switch (mode) {
      case 'light':
        return Icons.light_mode;
      case 'dark':
        return Icons.dark_mode;
      default:
        return Icons.brightness_auto;
    }
  }

  Future<void> _showThemeModeDialog(
    BuildContext context,
    WidgetRef ref,
    String currentMode,
  ) async {
    final selectedMode = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('테마 선택'),
        children: ThemeModeOption.values.map((option) {
          final isSelected = option.value == currentMode;
          return RadioListTile<String>(
            value: option.value,
            groupValue: currentMode,
            title: Text(option.label),
            secondary: Icon(_getThemeIcon(option.value)),
            selected: isSelected,
            onChanged: (value) => Navigator.pop(context, value),
          );
        }).toList(),
      ),
    );

    if (selectedMode != null && selectedMode != currentMode) {
      final dao = ref.read(userSettingsDaoProvider);
      await dao.setThemeMode(selectedMode);
      // 강제 리빌드
      ref.invalidate(userSettingsDaoProvider);
    }
  }
}
