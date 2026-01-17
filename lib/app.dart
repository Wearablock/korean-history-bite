import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'l10n/app_localizations.dart';

import 'core/theme/app_theme.dart';
import 'data/providers/chapter_providers.dart';
import 'data/providers/database_providers.dart';
import 'features/main/main_shell.dart';
import 'features/onboarding/daily_goal_onboarding_screen.dart';

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

    return MaterialApp(
      title: '한국사 한입',
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
        Locale('zh', 'TW'),
        Locale('es'),
        Locale('de'),
        Locale('fr'),
        Locale('it'),
        Locale('pt'),
        Locale('ar'),
        Locale('th'),
        Locale('id'),
        Locale('vi'),
        Locale('ru'),
      ],

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

    // 지원하는 로케일인지 확인 (ko, en만 데이터 있음)
    String targetLocale;
    if (locale.languageCode == 'ko') {
      targetLocale = 'ko';
    } else {
      // 한국어가 아닌 모든 언어는 영어로 fallback
      targetLocale = 'en';
    }

    // 변경이 필요한 경우에만 업데이트
    if (currentLocale != targetLocale) {
      // build 중에는 직접 상태 변경 불가, 다음 프레임에서 처리
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(currentLocaleProvider.notifier).state = targetLocale;
      });
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
      return DailyGoalOnboardingScreen(
        onComplete: _onOnboardingComplete,
      );
    }

    // 온보딩 완료 시 메인 쉘
    return const MainShell();
  }
}
