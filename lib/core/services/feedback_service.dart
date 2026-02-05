import 'sound_service.dart';
import 'haptic_service.dart';

/// 사운드와 진동을 통합 관리하는 피드백 서비스
///
/// Singleton 패턴으로 전역에서 동일 인스턴스 사용
///
/// 사용 예시:
/// ```dart
/// final feedback = FeedbackService();
///
/// // 설정에서 활성화/비활성화
/// feedback.setSoundEnabled(true);
/// feedback.setVibrationEnabled(true);
///
/// // 피드백 트리거
/// await feedback.onCorrectAnswer();
/// ```
class FeedbackService {
  // Singleton 인스턴스
  static final FeedbackService _instance = FeedbackService._internal();
  factory FeedbackService() => _instance;
  FeedbackService._internal();

  // 하위 서비스
  final SoundService _sound = SoundService();
  final HapticService _haptic = HapticService();

  // ============================================================
  // 설정 메서드
  // ============================================================

  /// 사운드 활성화/비활성화 설정
  void setSoundEnabled(bool enabled) {
    _sound.setEnabled(enabled);
  }

  /// 진동 활성화/비활성화 설정
  void setVibrationEnabled(bool enabled) {
    _haptic.setEnabled(enabled);
  }

  /// 사운드 볼륨 설정 (0.0 ~ 1.0)
  Future<void> setSoundVolume(double volume) async {
    await _sound.setVolume(volume);
  }

  /// 현재 사운드 활성화 상태
  bool get isSoundEnabled => _sound.isEnabled;

  /// 현재 진동 활성화 상태
  bool get isVibrationEnabled => _haptic.isEnabled;

  // ============================================================
  // 피드백 메서드
  // ============================================================

  /// 정답 피드백 (사운드 + 진동)
  Future<void> onCorrectAnswer() async {
    await Future.wait([
      _sound.play(SoundEffect.correct),
      _haptic.trigger(HapticType.success),
    ]);
  }

  /// 오답 피드백 (사운드 + 진동)
  Future<void> onWrongAnswer() async {
    await Future.wait([
      _sound.play(SoundEffect.wrong),
      _haptic.trigger(HapticType.error),
    ]);
  }

  /// 버튼 탭 피드백 (진동만)
  Future<void> onTap() async {
    await _haptic.trigger(HapticType.light);
  }

  /// 선택 변경 피드백 (진동만)
  Future<void> onSelectionChanged() async {
    await _haptic.trigger(HapticType.selection);
  }

  // ============================================================
  // 리소스 관리
  // ============================================================

  /// 리소스 해제
  void dispose() {
    _sound.dispose();
  }
}
