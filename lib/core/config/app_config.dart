import 'package:package_info_plus/package_info_plus.dart';

/// 앱 전역 설정
class AppConfig {
  AppConfig._();

  static PackageInfo? _packageInfo;

  /// 앱 초기화 시 호출 (main.dart에서)
  static Future<void> initialize() async {
    _packageInfo = await PackageInfo.fromPlatform();
  }

  // ============================================================
  // 앱 정보 (pubspec.yaml에서 자동으로 가져옴)
  // ============================================================

  /// 앱 이름
  static String get appName => _packageInfo?.appName ?? 'Korean History Bite';

  /// 패키지 이름 (com.wearablock.korean_history_bite)
  static String get packageName => _packageInfo?.packageName ?? '';

  /// 버전 (1.0.0)
  static String get version => _packageInfo?.version ?? '1.0.0';

  /// 빌드 번호 (1)
  static String get buildNumber => _packageInfo?.buildNumber ?? '1';

  /// 전체 버전 문자열 (1.0.0+1)
  static String get fullVersion => '$version+$buildNumber';

  // ============================================================
  // 앱 모드 설정
  // ============================================================

  /// 심사 모드 (스토어 심사 시 true로 변경)
  static const bool isReviewMode = false;

  /// 디버그 모드
  static const bool isDebugMode = true;

  // ============================================================
  // 지원 언어
  // ============================================================

  /// 지원 언어 코드 (퀴즈 데이터가 있는 언어)
  static const List<String> supportedLocales = [
    'ko',
    'en',
    'ja',
    'zh-Hans',
    'zh-Hant',
    'es',
  ];
}
