// lib/features/settings/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:korean_history_bite/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/config/setting_keys.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/collapsing_app_bar_scaffold.dart';
import '../../data/providers/chapter_providers.dart';
import '../../data/providers/database_providers.dart';
import '../../data/providers/study_providers.dart';
import '../../core/services/feedback_service.dart';
import '../wrong_answers/wrong_answers_screen.dart';
import 'widgets/notification_settings_tile.dart';
import 'widgets/premium_tile.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  // 문서 URL (호스팅 도메인에 맞게 수정)
  static const String _baseDocsUrl = 'https://wearablock.github.io/korean-history-bite';
  static const String _termsUrl = '$_baseDocsUrl/terms.html';
  static const String _privacyUrl = '$_baseDocsUrl/privacy.html';
  static const String _supportUrl = '$_baseDocsUrl/support.html';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return CollapsingAppBarScaffold(
      title: l10n.settings,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
          // === 프리미엄 섹션 ===
          _buildSectionCard(
            context,
            title: l10n.premium,
            icon: Icons.workspace_premium_outlined,
            children: const [
              PremiumTile(),
            ],
          ),

          const SizedBox(height: 12),

          // === 학습 섹션 ===
          _buildSectionCard(
            context,
            title: l10n.study,
            icon: Icons.school_outlined,
            children: [
              _DailyGoalTile(),
            ],
          ),

          const SizedBox(height: 12),

          // === 알림 섹션 ===
          _buildSectionCard(
            context,
            title: l10n.notifications,
            icon: Icons.notifications_outlined,
            children: const [
              NotificationSettingsTile(),
            ],
          ),

          const SizedBox(height: 12),

          // === 앱 설정 섹션 ===
          _buildSectionCard(
            context,
            title: l10n.appSettings,
            icon: Icons.tune_outlined,
            children: [
              _LanguageTile(),
              _ThemeModeTile(),
            ],
          ),

          const SizedBox(height: 12),

          // === 사운드 & 진동 섹션 ===
          _buildSectionCard(
            context,
            title: l10n.soundAndVibration,
            icon: Icons.volume_up_outlined,
            children: [
              _SoundToggleTile(),
              _VibrationToggleTile(),
            ],
          ),

          const SizedBox(height: 12),

          // === 정보 섹션 ===
          _buildSectionCard(
            context,
            title: l10n.info,
            icon: Icons.info_outline,
            children: [
              _buildInfoTile(
                context,
                icon: Icons.verified_outlined,
                title: l10n.appVersion,
                value: '1.0.0',
              ),
            ],
          ),

          const SizedBox(height: 12),

          // === 약관 섹션 ===
          _buildSectionCard(
            context,
            title: l10n.termsAndPolicies,
            icon: Icons.description_outlined,
            children: [
              _buildLinkTile(
                context,
                icon: Icons.article_outlined,
                title: l10n.termsOfService,
                onTap: () => _openUrl(context, _termsUrl),
              ),
              _buildLinkTile(
                context,
                icon: Icons.privacy_tip_outlined,
                title: l10n.privacyPolicy,
                onTap: () => _openUrl(context, _privacyUrl),
              ),
              _buildLinkTile(
                context,
                icon: Icons.support_agent_outlined,
                title: l10n.support,
                onTap: () => _openUrl(context, _supportUrl),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // === 데이터 섹션 ===
          _buildSectionCard(
            context,
            title: l10n.data,
            icon: Icons.storage_outlined,
            children: [
              _buildActionTile(
                context,
                icon: Icons.refresh,
                title: l10n.resetStudyRecords,
                subtitle: l10n.resetStudyRecordsDesc,
                onTap: () => _showResetConfirmDialog(context, ref),
                isDestructive: true,
              ),
            ],
          ),

          const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 헤더
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),

          // 구분선
          const Divider(height: 1),

          // 설정 항목들
          ...children.asMap().entries.map((entry) {
            final index = entry.key;
            final child = entry.value;
            final isLast = index == children.length - 1;

            return Column(
              children: [
                child,
                if (!isLast) const Divider(height: 1, indent: 56),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondaryLight),
      title: Text(title),
      trailing: Text(
        value,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondaryLight,
            ),
      ),
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
    final color = isDestructive ? AppColors.wrong : null;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: isDestructive
                    ? color?.withValues(alpha: 0.7)
                    : AppColors.textSecondaryLight,
              ),
            )
          : null,
      trailing: Icon(Icons.chevron_right, color: color),
      onTap: onTap,
    );
  }

  Widget _buildLinkTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondaryLight),
      title: Text(title),
      trailing: const Icon(
        Icons.open_in_new,
        size: 18,
        color: AppColors.textSecondaryLight,
      ),
      onTap: onTap,
    );
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    final l10n = AppLocalizations.of(context)!;
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.cannotOpenLink)),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.cannotOpenLink)),
        );
      }
    }
  }

  Future<void> _showResetConfirmDialog(
      BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetStudyRecords),
        content: Text(l10n.resetStudyRecordsConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.wrong,
            ),
            child: Text(l10n.reset),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final db = ref.read(appDatabaseProvider);
      await db.studyRecordsDao.deleteAll();
      await db.dailyStatsDao.deleteAll();
      await db.wrongAnswersDao.deleteAll();

      // 관련 Provider 갱신 (홈 화면 등 UI 업데이트)
      ref.invalidate(appStatsProvider);
      ref.invalidate(todaySummaryProvider);
      ref.invalidate(overallProgressProvider);
      ref.invalidate(eraProgressProvider);
      ref.invalidate(reviewDueCountProvider);
      ref.invalidate(masteredQuestionsProvider);
      ref.invalidate(masteredCountProvider);
      ref.invalidate(todayStatsProvider);
      ref.invalidate(currentStreakProvider);
      ref.invalidate(levelDistributionProvider);
      // 오답 노트 갱신
      final locale = ref.read(currentLocaleProvider);
      ref.invalidate(wrongAnswersWithQuestionsProvider(locale));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.studyRecordsReset)),
        );
      }
    }
  }
}

/// 일일 학습 목표 설정 타일 (챕터 기준)
class _DailyGoalTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final dao = ref.watch(userSettingsDaoProvider);

    return FutureBuilder<int>(
      future: dao.getDailyGoal(),
      builder: (context, snapshot) {
        final currentGoal = snapshot.data ?? 1;

        return ListTile(
          leading: const Icon(Icons.flag_outlined, color: AppColors.textSecondaryLight),
          title: Text(l10n.dailyStudyAmount),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  l10n.chaptersUnit(currentGoal),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: AppColors.textSecondaryLight),
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
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.dailyStudyAmount),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 기본 옵션들
          ...DailyGoalOption.values.map((option) {
            return RadioListTile<int>(
              value: option.chapterCount,
              groupValue: _isCustom ? -1 : _selectedGoal,
              title: Text(l10n.chaptersUnit(option.chapterCount)),
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
            title: Text(l10n.customSetting),
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
                      label: l10n.chaptersUnit(_selectedGoal),
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
              l10n.chaptersUnit(_selectedGoal),
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
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _selectedGoal),
          child: Text(l10n.confirm),
        ),
      ],
    );
  }
}

/// 테마 모드 설정 타일
class _ThemeModeTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final dao = ref.watch(userSettingsDaoProvider);

    return FutureBuilder<String>(
      future: dao.getThemeMode(),
      builder: (context, snapshot) {
        final currentMode = snapshot.data ?? 'system';
        final option = ThemeModeOption.fromValue(currentMode);

        return ListTile(
          leading: Icon(
            _getThemeIcon(currentMode),
            color: AppColors.textSecondaryLight,
          ),
          title: Text(l10n.theme),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getThemeLabel(option, l10n),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: AppColors.textSecondaryLight),
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
        return Icons.light_mode_outlined;
      case 'dark':
        return Icons.dark_mode_outlined;
      default:
        return Icons.brightness_auto_outlined;
    }
  }

  String _getThemeLabel(ThemeModeOption option, AppLocalizations l10n) {
    switch (option) {
      case ThemeModeOption.system:
        return l10n.themeSystem;
      case ThemeModeOption.light:
        return l10n.themeLight;
      case ThemeModeOption.dark:
        return l10n.themeDark;
    }
  }

  Future<void> _showThemeModeDialog(
    BuildContext context,
    WidgetRef ref,
    String currentMode,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    final selectedMode = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(l10n.selectTheme),
        children: ThemeModeOption.values.map((option) {
          final isSelected = option.value == currentMode;
          return RadioListTile<String>(
            value: option.value,
            groupValue: currentMode,
            title: Text(_getThemeLabel(option, l10n)),
            secondary: Icon(_getThemeIcon(option.value)),
            selected: isSelected,
            onChanged: (value) => Navigator.pop(dialogContext, value),
          );
        }).toList(),
      ),
    );

    if (selectedMode != null && selectedMode != currentMode) {
      final dao = ref.read(userSettingsDaoProvider);
      await dao.setThemeMode(selectedMode);
      // 강제 리빌드 (테마 모드 프로바이더도 갱신)
      ref.invalidate(userSettingsDaoProvider);
      ref.invalidate(themeModeProvider);
    }
  }
}

/// 언어 설정 타일
class _LanguageTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final dao = ref.watch(userSettingsDaoProvider);

    return FutureBuilder<String>(
      future: dao.getLocale(),
      builder: (context, snapshot) {
        final currentLocale = snapshot.data ?? 'system';
        final option = LanguageOption.fromValue(currentLocale);

        return ListTile(
          leading: const Icon(
            Icons.language_outlined,
            color: AppColors.textSecondaryLight,
          ),
          title: Text(l10n.language),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getLanguageLabel(option, l10n),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: AppColors.textSecondaryLight),
            ],
          ),
          onTap: () => _showLanguageDialog(context, ref, currentLocale),
        );
      },
    );
  }

  String _getLanguageLabel(LanguageOption option, AppLocalizations l10n) {
    switch (option) {
      case LanguageOption.system:
        return l10n.languageSystem;
      case LanguageOption.korean:
        return l10n.languageKorean;
      case LanguageOption.english:
        return l10n.languageEnglish;
      case LanguageOption.japanese:
        return l10n.languageJapanese;
      case LanguageOption.chineseSimplified:
        return l10n.languageChineseSimplified;
      case LanguageOption.chineseTraditional:
        return l10n.languageChineseTraditional;
      case LanguageOption.spanish:
        return l10n.languageSpanish;
      case LanguageOption.portuguese:
        return l10n.languagePortuguese;
    }
  }

  Future<void> _showLanguageDialog(
    BuildContext context,
    WidgetRef ref,
    String currentLocale,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    // async 전에 context 사용 (showDialog 이전)
    final appLocale = Localizations.localeOf(context);

    final selectedLocale = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(l10n.selectLanguage),
        children: LanguageOption.values.map((option) {
          final isSelected = option.value == currentLocale;
          return RadioListTile<String>(
            value: option.value,
            groupValue: currentLocale,
            title: Text(_getLanguageLabel(option, l10n)),
            secondary: option == LanguageOption.system
                ? const Icon(Icons.phone_android_outlined)
                : null,
            selected: isSelected,
            onChanged: (value) => Navigator.pop(dialogContext, value),
          );
        }).toList(),
      ),
    );

    if (selectedLocale != null && selectedLocale != currentLocale) {

      final dao = ref.read(userSettingsDaoProvider);
      await dao.setLocale(selectedLocale);

      // 퀴즈 데이터 로케일 업데이트
      String dataLocale;
      if (selectedLocale == 'system') {
        // 시스템 설정일 경우 현재 앱 로케일 사용
        switch (appLocale.languageCode) {
          case 'ko':
            dataLocale = 'ko';
            break;
          case 'ja':
            dataLocale = 'ja';
            break;
          case 'zh':
            if (appLocale.scriptCode == 'Hant' ||
                appLocale.countryCode == 'TW' ||
                appLocale.countryCode == 'HK' ||
                appLocale.countryCode == 'MO') {
              dataLocale = 'zh-Hant';
            } else {
              dataLocale = 'zh-Hans';
            }
            break;
          case 'pt':
            dataLocale = 'pt';
            break;
          default:
            dataLocale = 'en';
        }
      } else {
        dataLocale = selectedLocale;
      }
      ref.read(currentLocaleProvider.notifier).state = dataLocale;

      // 레포지토리 캐시 클리어
      ref.read(chapterRepositoryProvider).clearContentCache();

      // 강제 리빌드
      ref.invalidate(userSettingsDaoProvider);
      ref.invalidate(appLocaleProvider);
      ref.invalidate(chaptersProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.languageChangeRestart)),
        );
      }
    }
  }
}

/// 사운드 토글 타일
class _SoundToggleTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final dao = ref.watch(userSettingsDaoProvider);

    return FutureBuilder<bool>(
      future: dao.getSoundEnabled(),
      builder: (context, snapshot) {
        final isEnabled = snapshot.data ?? true;

        return SwitchListTile(
          secondary: Icon(
            isEnabled ? Icons.volume_up : Icons.volume_off,
            color: AppColors.textSecondaryLight,
          ),
          title: Text(l10n.soundEffects),
          subtitle: Text(
            l10n.soundEffectsDesc,
            style: TextStyle(color: AppColors.textSecondaryLight),
          ),
          value: isEnabled,
          onChanged: (value) async {
            await dao.setSoundEnabled(value);
            FeedbackService().setSoundEnabled(value);
            ref.invalidate(userSettingsDaoProvider);
          },
        );
      },
    );
  }
}

/// 진동 토글 타일
class _VibrationToggleTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final dao = ref.watch(userSettingsDaoProvider);

    return FutureBuilder<bool>(
      future: dao.getVibrationEnabled(),
      builder: (context, snapshot) {
        final isEnabled = snapshot.data ?? true;

        return SwitchListTile(
          secondary: Icon(
            isEnabled ? Icons.vibration : Icons.phone_android,
            color: AppColors.textSecondaryLight,
          ),
          title: Text(l10n.vibration),
          subtitle: Text(
            l10n.vibrationDesc,
            style: TextStyle(color: AppColors.textSecondaryLight),
          ),
          value: isEnabled,
          onChanged: (value) async {
            await dao.setVibrationEnabled(value);
            FeedbackService().setVibrationEnabled(value);
            ref.invalidate(userSettingsDaoProvider);
          },
        );
      },
    );
  }
}
