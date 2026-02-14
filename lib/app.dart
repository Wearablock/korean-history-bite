import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:upgrader/upgrader.dart';
import 'l10n/app_localizations.dart';

import 'core/theme/app_theme.dart';
import 'data/providers/chapter_providers.dart';
import 'data/providers/database_providers.dart';
import 'features/main/main_shell.dart';
import 'features/onboarding/daily_goal_onboarding_screen.dart';
import 'services/ad_service.dart';
import 'services/notification_service.dart';

class KoreanHistoryApp extends ConsumerWidget {
  const KoreanHistoryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 테마 모드 가져오기 (로딩 중에는 시스템 테마 사용)
    final themeMode = ref.watch(themeModeProvider).when(
      data: (mode) => mode,
      loading: () => ThemeMode.system,
      error: (_, __) => ThemeMode.system,
    );

    // 언어 설정 가져오기 (null이면 시스템 설정 사용)
    final appLocale = ref.watch(appLocaleProvider).when(
      data: (locale) => locale,
      loading: () => null,
      error: (_, __) => null,
    );

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)?.appTitle ?? 'Korean History Bite',
      debugShowCheckedModeBanner: false,

      // 테마
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,

      // 다국어 설정
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko'),
        Locale('en'),
        Locale('ja'),
        Locale('zh'),
        Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
        Locale('es'),
        Locale('pt'),
      ],
      // 사용자가 선택한 언어가 있으면 해당 언어 사용
      locale: appLocale,

      // 로케일 동기화를 위한 builder
      builder: (context, child) {
        // 앱의 실제 로케일을 provider에 동기화
        _syncLocale(context, ref);
        return child ?? const SizedBox.shrink();
      },

      // 온보딩 체크 후 메인 쉘 또는 온보딩 화면
      home: const _AppHome(),
    );
  }

  /// 앱의 로케일을 currentLocaleProvider에 동기화
  void _syncLocale(BuildContext context, WidgetRef ref) {
    final locale = Localizations.localeOf(context);
    final currentLocale = ref.read(currentLocaleProvider);

    // 지원하는 로케일인지 확인
    String targetLocale;
    switch (locale.languageCode) {
      case 'ko':
        targetLocale = 'ko';
        break;
      case 'ja':
        targetLocale = 'ja';
        break;
      case 'zh':
        // 번체 중국어 (Hant 스크립트 또는 TW/HK/MO 지역)
        if (locale.scriptCode == 'Hant' ||
            locale.countryCode == 'TW' ||
            locale.countryCode == 'HK' ||
            locale.countryCode == 'MO') {
          targetLocale = 'zh-Hant';
        } else {
          // 간체 중국어 (기본)
          targetLocale = 'zh-Hans';
        }
        break;
      case 'es':
        targetLocale = 'es';
        break;
      case 'pt':
        targetLocale = 'pt';
        break;
      default:
        // 기타 언어는 영어로 fallback
        targetLocale = 'en';
    }

    // 변경이 필요한 경우에만 업데이트
    if (currentLocale != targetLocale) {
      // build 중에는 직접 상태 변경 불가, 다음 프레임에서 처리
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(currentLocaleProvider.notifier).state = targetLocale;
      });
    }

    // 알림 서비스에 로컬라이즈된 문자열 설정
    final l10n = AppLocalizations.of(context);
    if (l10n != null) {
      NotificationService().setLocalizedStrings(
        channelName: l10n.notificationChannelName,
        channelDescription: l10n.notificationChannelDesc,
        notificationTitle: l10n.notificationTitle,
        notificationBody: l10n.notificationBody,
      );
    }
  }
}

/// 앱 홈 - 온보딩 완료 여부에 따라 화면 분기
class _AppHome extends ConsumerStatefulWidget {
  const _AppHome();

  @override
  ConsumerState<_AppHome> createState() => _AppHomeState();
}

class _AppHomeState extends ConsumerState<_AppHome> {
  bool? _onboardingCompleted;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
    // UI 렌더링 후 광고 지연 로드 (시작 시 오디오 재생 방지)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        AdService().preloadAds();
      });
    });
  }

  Future<void> _checkOnboardingStatus() async {
    final dao = ref.read(userSettingsDaoProvider);
    final completed = await dao.isOnboardingCompleted();

    if (mounted) {
      setState(() {
        _onboardingCompleted = completed;
      });
    }
  }

  void _onOnboardingComplete() {
    setState(() {
      _onboardingCompleted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 로딩 중
    if (_onboardingCompleted == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 온보딩 미완료 시 온보딩 화면
    if (!_onboardingCompleted!) {
      return UpgradeAlert(
        showIgnore: false,
        showLater: true,
        child: DailyGoalOnboardingScreen(
          onComplete: _onOnboardingComplete,
        ),
      );
    }

    // 온보딩 완료 시 메인 쉘
    return UpgradeAlert(
      showIgnore: false,
      showLater: true,
      child: const MainShell(),
    );
  }
}
