// lib/core/utils/formatters.dart

/// 텍스트 포맷팅 유틸리티
class Formatters {
  Formatters._();

  /// 초 단위 시간을 읽기 쉬운 형태로 변환
  /// 예: 30 -> "30초", 90 -> "1분", 3700 -> "1h 1m"
  static String formatDuration(int seconds) {
    if (seconds < 60) return '$seconds초';
    if (seconds < 3600) return '${seconds ~/ 60}분';
    final hours = seconds ~/ 3600;
    final mins = (seconds % 3600) ~/ 60;
    if (mins == 0) return '$hours시간';
    return '${hours}h ${mins}m';
  }

  /// 퍼센트 값 포맷팅 (0.0 ~ 1.0 -> "75%")
  static String formatPercent(double value) {
    return '${(value * 100).toInt()}%';
  }

  /// 숫자를 한글 단위로 포맷팅 (1000 -> "1천", 10000 -> "1만")
  static String formatNumberKorean(int number) {
    if (number >= 10000) {
      final man = number ~/ 10000;
      final remainder = number % 10000;
      if (remainder == 0) return '$man만';
      return '$man만 ${formatNumberKorean(remainder)}';
    }
    if (number >= 1000) {
      final cheon = number ~/ 1000;
      final remainder = number % 1000;
      if (remainder == 0) return '$cheon천';
      return '$cheon천 $remainder';
    }
    return '$number';
  }
}
