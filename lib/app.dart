import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'l10n/app_localizations.dart';

import 'core/theme/app_theme.dart';
import 'data/providers/database_providers.dart';
import 'features/main/main_shell.dart';
import 'features/onboarding/daily_goal_onboarding_screen.dart';

class KoreanHistoryApp extends StatelessWidget {
  const KoreanHistoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '한국사 한입',
      debugShowCheckedModeBanner: false,

      // 테마
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,

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

      // 온보딩 체크 후 메인 쉘 또는 온보딩 화면
      home: const _AppHome(),
    );
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
