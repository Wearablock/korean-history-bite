import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

import 'core/theme/app_theme.dart';

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

      // 홈 화면
      home: const Placeholder(), // TODO: HomeScreen으로 교체
    );
  }
}
